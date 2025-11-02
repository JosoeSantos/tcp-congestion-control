#include "ns3/core-module.h"
#include "ns3/applications-module.h"
#include "ns3/error-model.h"
#include "ns3/internet-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/network-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/config-store-module.h"

#include <fstream>
#include <iostream>
#include <string>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("Lab2Part1");

static std::map<uint32_t, bool> firstCwnd;
static std::map<uint32_t, Ptr<OutputStreamWrapper>> cWndStream;
static std::map<uint32_t, uint32_t> cWndValue;
static std::map<uint64_t, uint64_t> totalBytesReceived;

static uint32_t
GetNodeIdFromContext(std::string context)
{
    const std::size_t n1 = context.find_first_of('/', 1);
    const std::size_t n2 = context.find_first_of('/', n1 + 1);
    return std::stoul(context.substr(n1 + 1, n2 - n1 - 1));
}

static void
CwndTracer(std::string context, uint32_t oldval, uint32_t newval)
{
    uint32_t nodeId = GetNodeIdFromContext(context);

    if (firstCwnd[nodeId])
    {
        *cWndStream[nodeId]->GetStream() << "0.0 " << oldval << std::endl;
        firstCwnd[nodeId] = false;
    }
    *cWndStream[nodeId]->GetStream() << Simulator::Now().GetSeconds() << " " << newval << std::endl;
    cWndValue[nodeId] = newval;
}

static void
TraceCwnd(std::string cwnd_tr_file_name, uint32_t nodeId)
{
    AsciiTraceHelper ascii;
    cWndStream[nodeId] = ascii.CreateFileStream(cwnd_tr_file_name);
    Config::Connect("/NodeList/" + std::to_string(nodeId) +
                        "/$ns3::TcpL4Protocol/SocketList/0/CongestionWindow",
                    MakeCallback(&CwndTracer));
}

static void
PacketSinkRxTrace(uint32_t flowId, Ptr<const Packet> packet, const Address& address)
{
    totalBytesReceived[flowId] += packet->GetSize();
}

int
main(int argc, char* argv[])
{
    std::string transport_prot = "TcpNewReno";
    std::string dataRate = "1Mbps";
    std::string delay = "20ms";
    double errorRate = 0.00001;
    uint32_t nFlows = 1;

    CommandLine cmd(__FILE__);
    cmd.AddValue("transport_prot",
                 "Transport protocol to use: TcpCubic or TcpNewReno",
                 transport_prot);
    cmd.AddValue("dataRate", "Bottleneck link data rate", dataRate);
    cmd.AddValue("delay", "Bottleneck link delay", delay);
    cmd.AddValue("errorRate", "Bottleneck link error rate", errorRate);
    cmd.AddValue("nFlows", "Number of flows (max 20)", nFlows);
    cmd.Parse(argc, argv);

    if (nFlows > 20)
    {
        std::cerr << "Maximum number of flows is 20" << std::endl;
        return 1;
    }

    transport_prot = std::string("ns3::") + transport_prot;

    Config::SetDefault("ns3::TcpL4Protocol::SocketType",
                       TypeIdValue(TypeId::LookupByName(transport_prot)));

    NodeContainer nodes;
    nodes.Create(4);

    Ptr<Node> source = nodes.Get(0);
    Ptr<Node> router1 = nodes.Get(1);
    Ptr<Node> router2 = nodes.Get(2);
    Ptr<Node> dest = nodes.Get(3);

    PointToPointHelper p2pSourceRouter;
    p2pSourceRouter.SetDeviceAttribute("DataRate", StringValue("100Mbps"));
    p2pSourceRouter.SetChannelAttribute("Delay", StringValue("0.01ms"));

    PointToPointHelper p2pBottleneck;
    p2pBottleneck.SetDeviceAttribute("DataRate", StringValue(dataRate));
    p2pBottleneck.SetChannelAttribute("Delay", StringValue(delay));

    PointToPointHelper p2pRouterDest;
    p2pRouterDest.SetDeviceAttribute("DataRate", StringValue("100Mbps"));
    p2pRouterDest.SetChannelAttribute("Delay", StringValue("0.01ms"));

    NetDeviceContainer devicesSourceRouter = p2pSourceRouter.Install(source, router1);
    NetDeviceContainer devicesBottleneck = p2pBottleneck.Install(router1, router2);
    NetDeviceContainer devicesRouterDest = p2pRouterDest.Install(router2, dest);

    Ptr<RateErrorModel> em = CreateObject<RateErrorModel>();
    em->SetAttribute("ErrorRate", DoubleValue(errorRate));
    devicesBottleneck.Get(1)->SetAttribute("ReceiveErrorModel", PointerValue(em));

    InternetStackHelper stack;
    stack.InstallAll();

    Ipv4AddressHelper address;
    address.SetBase("10.1.1.0", "255.255.255.0");
    Ipv4InterfaceContainer interfacesSourceRouter = address.Assign(devicesSourceRouter);

    address.SetBase("10.1.2.0", "255.255.255.0");
    Ipv4InterfaceContainer interfacesBottleneck = address.Assign(devicesBottleneck);

    address.SetBase("10.1.3.0", "255.255.255.0");
    Ipv4InterfaceContainer interfacesRouterDest = address.Assign(devicesRouterDest);

    Ipv4GlobalRoutingHelper::PopulateRoutingTables();

    uint16_t port = 50000;

    for (uint32_t i = 0; i < nFlows; i++)
    {
        uint16_t flowPort = port + i;
        Address destAddress(InetSocketAddress(interfacesRouterDest.GetAddress(1), flowPort));

        PacketSinkHelper sinkHelper("ns3::TcpSocketFactory",
                                    InetSocketAddress(Ipv4Address::GetAny(), flowPort));
        ApplicationContainer sinkApp = sinkHelper.Install(dest);
        sinkApp.Start(Seconds(0.0));
        sinkApp.Stop(Seconds(20.0));

        Ptr<PacketSink> packetSink = DynamicCast<PacketSink>(sinkApp.Get(0));
        packetSink->TraceConnectWithoutContext("Rx",
                                               MakeBoundCallback(&PacketSinkRxTrace, i));

        totalBytesReceived[i] = 0;

        BulkSendHelper bulkSend("ns3::TcpSocketFactory", destAddress);
        bulkSend.SetAttribute("MaxBytes", UintegerValue(0));

        ApplicationContainer sourceApp = bulkSend.Install(source);
        sourceApp.Start(Seconds(1.0));
        sourceApp.Stop(Seconds(20.0));

        std::string flowString;
        if (nFlows > 1)
        {
            flowString = "-flow" + std::to_string(i);
        }


        firstCwnd[i] = true;

        Simulator::Schedule(Seconds(1.00001),
                                &TraceCwnd,
                                "l2p1" + flowString + "-cwnd.data",
                                0);
    }

    Simulator::Stop(Seconds(20.0));

    // used for debugging
    // Config::SetDefault("ns3::ConfigStore::Filename", StringValue("output-attributes.txt"));
    // Config::SetDefault("ns3::ConfigStore::FileFormat", StringValue("RawText"));
    // Config::SetDefault("ns3::ConfigStore::Mode", StringValue ("Save"));
    // ConfigStore outputConfig2;
    // outputConfig2.ConfigureDefaults();
    // outputConfig2.ConfigureAttributes();

    Simulator::Run();

    for (uint32_t i = 0; i < nFlows; i++)
    {
        // flow | goodput in bps |  goodput in Mbps
        double goodput = (totalBytesReceived[i] * 8.0) / (19.0);
        std::cout << i << " " << goodput << " " << goodput / 1000000.0 << std::endl;
    }

    Simulator::Destroy();

    return 0;
}
