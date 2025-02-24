#!/bin/bash
export HF_DATASETS_CACHE="/ocean/projects/cis220031p/ankshah1/huggingface"
export TRANSFORMERS_CACHE="/ocean/projects/cis220031p/ankshah1/huggingface"

cd ../..

export PYTHONPATH=$PYTHONPATH:$PWD

DATA="/ocean/projects/cis220031p/ankshah1/DATA"
TRAINER=BLACKVIP
SHOTS=16
CFG=$1
ptb=vit-mae-base

DATASET=$2
ep=$3

spsa_os=1.0
alpha=0.4
spsa_a=0.01

b1=$4
gamma=$5
spsa_c=$6
p_eps=$7

opt_type='spsa-gc'

for SEED in 1 2 3
do
    DIR=output/${DATASET}/${TRAINER}/${ptb}_${CFG}/shot${SHOTS}_ep${ep}/${opt_type}_b1${b1}/a${alpha}_g${gamma}_sa${spsa_a}_sc${spsa_c}_eps${p_eps}/seed${SEED}
    # if [ -d "$DIR" ]; then
    #     echo "Oops! The results exist at ${DIR} (so skip this job)"
    # else
    python train.py \
    --root ${DATA} \
    --seed ${SEED} \
    --trainer ${TRAINER} \
    --dataset-config-file configs/datasets/${DATASET}.yaml \
    --config-file configs/trainers/${TRAINER}/${CFG}.yaml \
    --output-dir ${DIR} \
    TRAIN.CHECKPOINT_FREQ 500 \
    DATASET.NUM_SHOTS ${SHOTS} \
    DATASET.SUBSAMPLE_CLASSES all \
    OPTIM.MAX_EPOCH $ep \
    TRAINER.BLACKVIP.PT_BACKBONE $ptb \
    TRAINER.BLACKVIP.SPSA_PARAMS [$spsa_os,$spsa_c,$spsa_a,$alpha,$gamma] \
    TRAINER.BLACKVIP.OPT_TYPE $opt_type \
    TRAINER.BLACKVIP.MOMS $b1 \
    TRAINER.BLACKVIP.P_EPS $p_eps \
    TRAINER.BLACKVIP.SRC_DIM 1568
done