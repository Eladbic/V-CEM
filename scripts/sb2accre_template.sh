#!/bin/bash

# submit script with: sbatch <filename>

#SBATCH -n 10				# number of processor core(tasks)
#SBATCH --ntasks-per-node=1		# tasks pre nodes
#SBATCH --mem-per-cpu=1G		# memory per CPU core
#SBATCH --time=0-00:05:00		# wall time
###SBATCH --exclusive 			# Want the node exlusively
#SBATCH -J jobname			# Job name
#SBATCH --output=%jjobname.out
#SBATCH --error=%j.err
#SBATCH --mail-user=eladbi@gmail.com   # email address
#SBATCH --mail-type=ALL

echo "Starting at `date`"
echo "Job name: $SLURM_JOB_NAME JobID: $SLURM_JOB_ID"
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."
echo "Current working directory is `pwd`"
	
setpkgs -a openmpi_1.8.4

export PATH=/programs/x86_64-linux/eman2/2.12/bin/:$PATH # the path to the software that you want to run in this ex. EMAN2


which mpirun
which e2boxer.py # test to the app path

# the command that you want to run 
set -v
#srun --mpi=pmi2 sxcter.py '/dors/ohilab/home/binshtem/accre/data/Micrographs2/sILSTAP_*.mrc' outdir_cter --wn=512 --apix=1.24665895 --Cs=2.2 --voltage=300 --ac=10
set +v

echo "Program finished with exit code $? at: `date`"
