#!/bin/bash

cwalgs=("TcpCubic" "TcpNewReno")
dataRates=("10Mbps" "1Mbps")
delays_b=("50ms" "100ms" "150ms" "200ms" "250ms" "300ms")
nFlows=("1" "2" "4")
errorRates=("1e-05" "5e-05" "1e-04" "5e-04" "1e-03")

./ns3 build

if [ "$1" == "a" ]; then
    ## part a
    rm -rf results/part-a

    for cwa in "${cwalgs[@]}"; do
        mkdir -p results/part-a/$cwa
        ./ns3 run scratch/lab2-part1 -- \
            --transport_prot=$cwa \
            --dataRate=10Mbps \
            --delay=100ms \
            --errorRate=1e-05 \
            --nFlows=1
        mv *.data results/part-a/$cwa/
        cd results/part-a/$cwa
        gnuplot << EOF
            set terminal png size 640,480
            set output "cwnd-$cwa.png"
            plot "l2p1-cwnd.data" using 1:2 title 'Congestion Window for $cwa' with linespoints
            exit
EOF
        cd ../../../
    done
    echo "Part a completed. Results are in results/part-a/ directory."
fi

if [ "$1" == "b" ]; then
    echo "Starting part b..."

    ## part b
    rm -rf results/part-b

    for cwa in "${cwalgs[@]}"; do
        for fe in {0..2}; do
            nFlows=$((2**fe))
            echo "Running simulations for $cwa with 2^$fe = $nFlows flows..."
            for delay_b in "${delays_b[@]}"; do
                echo "Running simulation for $cwa with $nFlows flows and delay $delay_b ..."
                $(./ns3 run scratch/lab2-part1 -- \
                    --transport_prot=$cwa \
                    --dataRate=1Mbps \
                    --delay=$delay_b \
                    --errorRate=1e-05 \
                    --nFlows=$nFlows | sed "s/^/$delay_b /" >> goodput-$cwa-nFlows-$nFlows.data)&
            done
            wait
            mkdir -p results/part-b/$cwa-nFlows-$nFlows
            mv goodput-$cwa-nFlows-$nFlows.data results/part-b/$cwa-nFlows-$nFlows/
            echo "Completed simulations for $cwa with $nFlows flows."
            echo ""
        done
    done

    gnuplot plot-goodput-delay.gnu
    mv *.png results/part-b/
    echo "Part b completed. Results are in results/part-b/ directory."
fi


if [ "$1" == "c" ]; then
    echo "Starting part c..."

    ## part c
    rm -rf results/part-c

    for cwa in "${cwalgs[@]}"; do
        for fe in {0..2}; do
            nFlows=$((2**fe))
            echo "Running simulations for $cwa with 2^$fe = $nFlows flows..."
            for er in "${errorRates[@]}"; do
                echo "Running simulation for $cwa with $nFlows flows and error rate $er ..."
                $(./ns3 run scratch/lab2-part1 -- \
                    --transport_prot=$cwa \
                    --dataRate=1Mbps \
                    --delay=100ms \
                    --errorRate=$er \
                    --nFlows=$nFlows | sed "s/^/$er /" >> goodput-$cwa-nFlows-$nFlows.data)&
            done
            wait
            mkdir -p results/part-c/$cwa-nFlows-$nFlows
            mv goodput-$cwa-nFlows-$nFlows.data results/part-c/$cwa-nFlows-$nFlows/
            echo "Completed simulations for $cwa with $nFlows flows."
            echo ""
        done
    done

    gnuplot plot-goodput-errorrate_log.gnu
    gnuplot plot-goodput-errorrate_linear.gnu
    mv *.png results/part-c/
    echo "Part c completed. Results are in results/part-c/ directory."
fi
