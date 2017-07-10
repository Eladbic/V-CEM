#!/bin/bash

# submit script with: sbatch <filename>
#
# because 3D use a lottttt of RAM it help to use MPI and threading
# when doing that you need to spcify #task (= pmirun -np); cpus-per-task
# and in the relion command |j| is the same as cpus-per-task
#
#########################################################################

#SBATCH -n 100				# number of processor core(tasks)
##SBATCH --ntasks-per-node=2		# tasks pre nodes - if there is NUMA problem enabel this option
#SBATCH --mem-per-cpu=15G		# memory per CPU core
##SBATCH --mem=60G			# use: 20, 61, 120, 252 [mem per node]
#SBATCH --cpus-per-task=2		# threading number thread*task= cpu
#SBATCH --time=0-12:00:00		# wall time
##SBATCH --exclusive 			# Want the node exlusively
#SBATCH -J class3D_run1_15g 		# Job name
#SBATCH --output=%j3d_run1.out
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
echo "# of particles" `wc -l particlesN_all_2d.star` # chang star name to get number of particle

setpkgs -a openmpi_1.8.4
setpkgs -a relion_1.4

set -v
srun --mpi=pmi2 -n 200  `which relion_refine_mpi` --o Class3D/run1 --i particlesN_all_2d.star --particle_diameter 350 --angpix 1.24669 --ref U5_U2_U6_Melrelion2.mrc --firstiter_cc --ini_high 60 --ctf --iter 25 --tau2_fudge 4 --K 100 --flatten_solvent --zero_mask --oversampling 1 --healpix_order 1 --offset_range 5 --offset_step 2 --sym C1 --norm --scale  --j 2 --memory_per_thread 13 &
set +v

## srun --mpi=pmi2 or --mpirun

INTERVAL=5
NODES=$( scontrol show hostname ${SLURM_STEP_NODELIST} )
while [ $(echo -n ${NODES} | wc -m) -ne "0" ]; do
sleep ${INTERVAL}
for N in ${NODES}; do
ssh ${N} /bin/bash << "EOF"
PIDS=$(pgrep relion)
for PID in ${PIDS}; do
pmap -x ${PID} | tail -1 | awk '{printf "%20i%20i%20i\n", $3, $4, $5}' >>
/dors/ohilab/home/binshtem/accre/memlog/${HOSTNAME}_${PID}.log
done
echo ${PIDS} | wc -w > /scratch/vanzod/Relion/${HOSTNAME}.npid
EOF
if grep -q 0 ${N}.npid; then NODES=${NODES//$N/}; fi
done
done
rm -f *npid

echo "Program finished with exit code $? at: `date`"

## if srun don't work you can change to --mpirun w/o --mpi=pmi2
