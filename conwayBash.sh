#!/bin/bash

#SBATCH --job-name="conwayCuda"

#SBATCH --output="conwayCuda.%j.%N.out"

#SBATCH -p gpu

#SBATCH --gres=gpu:k80:4

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=1

#SBATCH --export=ALL

#SBATCH -t 00:10:00



./conwayCuda 500

