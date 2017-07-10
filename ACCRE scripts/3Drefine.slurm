#!/bin/bash

# submit script with: sbatch filename
#
# because 3D use a lottttt of RAM it help to use MPI and threading
# when doing that you need to spcify #task (= pmirun -np); cpus-per-task
# and in the relion command |j| is the same as cpus-per-task
#
#########################################################################

#SBATCH -n 100				# number of processor core(tasks)
#SBATCH --nodes=50
#SBATCH --ntasks-per-node=2		# tasks pre nodes - if there is NUMA problem enabel this option
#SBATCH --mem-per-cpu=15G		# memory per CPU core
##SBATCH --mem=60G			# use: 20, 61, 120, 252 [mem per node]
#SBATCH --cpus-per-task=2		# threading number thread*task= cpu
#SBATCH --time=1-06:00:00		# wall time
#SBATCH -J 3Drefine_run1 		# Job name
#SBATCH --output=%j3dref_run1.out
#SBATCH --error=%j.err
#SBATCH --mail-user=eladbi@gmail.com    # email address
#SBATCH --mail-type=ALL
#SBATCH --no-requeue			# to prevent the slurm restart after node fail !!!


echo "Starting at `date`"
echo "Job name: $SLURM_JOB_NAME JobID: $SLURM_JOB_ID"
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."
echo "Current working directory is `pwd`"
echo "# of particles" `wc -l articles_all_3d.star` # chang star name to get number of particle

setpkgs -a openmpi_1.8.4
setpkgs -a relion_1.4

set -v
srun --mpi=pmi2 `which relion_refine_mpi` --o Refine3D/run1 --auto_refine --split_random_halves --i particles_all_3d.star --particle_diameter 310 --angpix 1.24669 --ref U5_U2_U6_Melrelion2.mrc --firstiter_cc --ini_high 60 --ctf --flatten_solvent --oversampling 1 --healpix_order 2 --auto_local_healpix_order 4 --offset_range 5 --offset_step 2 --sym C1 --low_resol_join_halves 40 --norm --scale  --j 2 --memory_per_thread 13
set +v

echo "Program finished with exit code $? at: `date`"
# srun --mpi=pmi2
