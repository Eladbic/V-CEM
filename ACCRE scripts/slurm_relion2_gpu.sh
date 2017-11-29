#!/bin/bash

#SBATCH --partition=XXXqueueXXX	#required for gpu job, GPU partition to use maxwell or pascal
##SBATCH --partition=maxwell	
#SBATCH --account=csb_gpu	#required for gpu job, your GPU group
#SBATCH --gres=gpu:4		#required for gpu job, number of GPU/node (max 4 per node)
#SBATCH --nodes=1		#if needed 8 gpu use 2 nodes (use even number of GPU 1, 2, 4, 8, 12, 16....)
#SBATCH --ntasks=XXXmpinodesXXX	# maxwell 1:3 pascal 1:2
#SBATCH --cpus-per-task=XXXthreadsXXX
#SBATCH --time=XXXextra1XXX
#SBATCH --mem-per-cpu=XXXextra2XXX 
#SBATCH -J XXXoutfileXXX
#SBATCH --error=XXXerrfileXXX
#SBATCH --output=XXXoutfileXXX
#SBATCH --mail-user=eladbi@gmail.com   # email address
#SBATCH --mail-type=ALL
#SBATCH --no-requeue			# to prevent the slurm restart after node fail !!!
######$ -l dedicated=XXXdedicatedXXX 
## Environment
##source ~/.cshrc

echo "Starting at `date`"
echo "Job name: $SLURM_JOB_NAME JobID: $SLURM_JOB_ID"
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."
echo "Current working directory is `pwd`"
echo "# of particles" `wc -l particles.star` # chang star name to get number of particle


setpkgs -a openmpi_1.10.6_roce      #for use when running on GPU node old=openmpi_1.10.2_roce
#setpkgs -a relion_2.0.3	    # use this with cuda7.5

#### For use of relion2.0
export PATH=/programs/x86_64-linux/relion/2.1b1_cu8.0/bin/:$PATH 
export LD_LIBRARY_PATH=/programs/x86_64-linux/relion/2.1b1_cu8.0/lib:$LD_LIBRARY_PATH

set -v
srun --mpi=pmi2 XXXcommandXXX
set +v

echo "Program finished with exit code $? at: `date`"





