#!/usr/bin/env bash

NUM_PROCS=${1:-5}
max_trials=$(( 75 / $NUM_PROCS ))

for BIAS in 0 3 6 9 12 15
do
    config="gauss-deter-search.gin"
    experiment_name="gauss-deter-dim256gpu-bias$BIAS"
    params="Game.bias=$BIAS Gaussian.min_var=1e-2 train.device=\'cuda\'"

    for process in $(seq 1 $NUM_PROCS)
    do
        borgy submit \
            --name $experiment_name \
            --mem 4 \
            --gpu 1 \
            -e HOME=$HOME \
            -i images.borgy.elementai.net/mnoukhov/emergent:latest \
            -v $HOME/emergent-compete:/workspace/emergent-compete:ro \
            -v /mnt/scratch/mnoukhov/emergent:/scratch:rw \
            -- bash -c "cp -r emergent-compete code; cd code; ./scripts/hyperparam_search.sh $max_trials $experiment_name $config $params"
    done
done
