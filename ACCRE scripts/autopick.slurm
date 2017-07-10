#!/bin/bash

# submit script with: sbatch <filename>

#SBATCH -n 50				# number of processor core(tasks)
##SBATCH --ntasks-per-node=2		# tasks pre nodes - if there is NUMA problem enabel this option
#SBATCH --mem-per-cpu=5G		# memory per CPU core (for autopick need more then 3G)
#SBATCH --time=0-03:00:00		# wall time
###SBATCH --exclusive 			# Want the node exlusively
#SBATCH -J autopick1273			# Job name
#SBATCH --output=%jap_1273.out
#SBATCH --error=%j.err
#SBATCH --mail-user=eladbi@gmail.com   # email address
#SBATCH --mail-type=ALL
#SBATCH --no-requeue			# to prevent the slurm restart after node fail !!!

echo "Starting at `date`"
echo "Job name: $SLURM_JOB_NAME JobID: $SLURM_JOB_ID"
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."
echo "Current working directory is `pwd`"

setpkgs -a openmpi_1.8.4
setpkgs -a relion_1.4

set -v
srun --mpi=pmi2 -n 50 `which relion_autopick_mpi` --i "micrographs_1042_1273_ctf.star" --o autopick --particle_diameter 350 --angpix 1.24 --ref manual_7class.star --invert  --ctf  --ang 10 --lowpass 20 --threshold 0.4 --min_distance 300 --max_stddev_noise 1 --skip_side 50 --outlier_removal_zscore 6
set +v

echo "Program finished with exit code $? at: `date`"

## srun --mpi=pmi2 or --mpirun
