#!/bin/bash

NR_SHAPES=${1:-5}


# Generate all permutations
permutations=()
for i in $(seq 0 $NR_SHAPES); do
    for j in $(seq 0 $NR_SHAPES); do
        if [ $i -ne $j ]; then
            for k in $(seq 0 $NR_SHAPES); do
                if [ $k -ne $i ] && [ $k -ne $j ]; then
                    permutations+=("{shape_$i.eps}{shape_$j.eps}{shape_$k.eps}")
                fi
            done
        fi
    done
done

# Get array indices
indices=($(seq 0 $((${#permutations[@]} - 1))))

# Shuffle the indices
indices=($(for i in "${indices[@]}"; do echo $i; done | shuf))


for NR in $(seq 0 99); do
    # Use a permutation
    SHAPE=${permutations[${indices[$NR]}]}
    # Use eval to construct and execute the command
    echo "SHAPE$NR='$SHAPE'"
    # Export the variable
    echo "export SHAPE$NR"
done
