#!/bin/bash

# submit script with: sbatch <filename>

#SBATCH -n 50				# number of processor core(tasks)
##SBATCH --ntasks-per-node=2		# tasks pre nodes - if there is NUMA problem enabel this option
#SBATCH --mem-per-cpu=10G		# memory per CPU core
#SBATCH --time=0-12:00:00		# wall time
###SBATCH --exclusive 			# Want the node exlusively
#SBATCH -J class2D_run1			# Job name
#SBATCH --output=%j2d_run1.out
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
echo "# of particles" `wc -l particles.star` # chang star name to get number of particle

setpkgs -a openmpi_1.8.4
setpkgs -a relion_1.4

set -v
srun --mpi=pmi2 -n 50  `which relion_refine_mpi` --o Class2D/run1 --i particles.star --particle_diameter 450 --angpix 1.24669 --ctf  --iter 25 --tau2_fudge 2 --K 30 --flatten_solvent  --oversampling 1 --psi_step 10 --offset_range 5 --offset_step 2 --norm --scale
set +v

echo "Program finished with exit code $? at: `date`"

## srun --mpi=pmi2 or --mpirun
