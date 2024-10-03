#!/bin/bash

exe="gmx_mpi"
export OMP_NUM_THREADS=2

mdp_dir="mdp_files"
em="1-em"
npt="2-npt"
nvt="3-nvt" 


em_mdp=$(readlink -f ../$mdp_dir/em.mdp)    # mdp file
npt_mdp=$(readlink -f ../$mdp_dir/npt.mdp)    # mdp file
nvt_mdp=$(readlink -f ../$mdp_dir/nvt.mdp)    # mdp file

init_geom=$(readlink -f final-box.gro)    # initial simulation box
top=$(readlink -f topol.top)			  # topology file


# Energy Minimization run using Steepest descent algo
mkdir $em ; pushd $em
$exe grompp -f $em_mdp -c $init_geom -p $top -o em.tpr -maxwarn 1
$exe mdrun -ntomp $OMP_NUM_THREADS -gpu_id 0 -v -deffnm em

if [[ -e "em.gro" ]]; then
	echo "Energy minimization is complete!"
fi
popd

# NPT Equilibration run
mkdir $npt ; pushd $npt
$exe grompp -f $npt_mdp -c ../$em/em.gro -r ../$em/em.gro -p $top -o npt.tpr -maxwarn 1
$exe mdrun -ntomp $OMP_NUM_THREADS -gpu_id 0 -v -deffnm npt

if [[ -e "npt.gro" ]]; then
    echo "NPT Equilibration is complete!"
fi
popd

## NVT run
#mkdir $nvt ; pushd $nvt
#$exe grompp -f $nvt_mdp -c ../$npt/npt.gro -p $top -o nvt.tpr -maxwarn 1
#$exe mdrun -ntomp $OMP_NUM_THREADS -gpu_id 0 -v -deffnm nvt
#
#if [[ -e "nvt.gro" ]]; then
#    echo "NVT Equilibration is complete!"
#fi
#popd
