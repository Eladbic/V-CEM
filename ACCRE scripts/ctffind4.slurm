#!/bin/bash

# submit script with: sbatch <filename>

#SBATCH -n 50				# number of processor core(tasks)
##SBATCH --ntasks-per-node=2		# tasks pre nodes - if there is NUMA problem enabel this option
#SBATCH --mem-per-cpu=5G		# memory per CPU core
#SBATCH --time=0-03:00:00		# wall time (take +/- 5min for mircograph/cpu)
###SBATCH --exclusive 			# Want the node exlusively
#SBATCH -J ctf4_bcom175		      	# Job name
#SBATCH --output=%jctf4_4432.out
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
mpirun -n 50 `which relion_run_ctffind_mpi` --i "micrographs_0001_0175.star" --o "micrographs_0001_0175_ctf.star" --ctfWin -1 --CS 2.2 --HT 300 --AmpCnst 0.1 --XMAG 40106  --DStep 5 --Box 512 --ResMin 100 --ResMax 4 --dFMin 5000 --dFMax 50000 --FStep 500 --dAst 100 --only_do_unfinished --ctffind_exe "/programs/x86_64-linux/ctffind4/4.0.16/bin/ctffind --old-school-input"
set +v

## --only_do_unfinished --only_make_star # for complit the ctf if kill befor finish

echo "Program finished with exit code $? at: `date`"

## srun --mpi=pmi2 or --mpirun
