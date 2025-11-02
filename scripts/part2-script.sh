#!/bin/bash

cwalgs=("TcpCubic" "TcpNewReno")

results=results/part-2

rm -rf $results/*
mkdir -p $results

./ns3 build

for cwa in "${cwalgs[@]}"; do

    for i in {1..4}; do
        nFlows=$((2*i))
        echo "Running simulation for $cwa, iteration $i with $nFlows flows ..."
        for j in {0..10}; do
            echo "  Run $j/10 ..."
            $(./ns3 run scratch/lab2-part2 -- \
                --transport_prot=$cwa \
                --dataRate=1Mbps \
                --delay=20ms \
                --errorRate=1e-05 \
                --nFlows=$nFlows \
                --run=$j >> $results/goodput-$cwa.data) &
        done
        wait
    done
    wait
    echo "Simulations completed for $cwa. Processing results..."
done
