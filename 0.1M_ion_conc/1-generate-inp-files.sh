#!/bin/bash


# load GROMACS
exe="gmx"

pdb=$(basename $(ls ../*.pdb))
pdb=$(echo "$pdb" | cut -d "." -f 1)

# bash variables
inp_pdb=$(readlink -f ../${pdb}.pdb)
refine_gro="${pdb}_refined.gro"
init_box="${pdb}_box.gro"
solv_box="${pdb}_solv.gro"
top="topol.top"
# salt concentration
M="0.1"

# topol.top posre.itp
# AMBER99SB-ILDN protein, nucleic AMBER94 (Lindorff-Larsen et al., Proteins 78, 1950-58, 2010)
$exe pdb2gmx -f $inp_pdb -water tip3p -ignh -o $refine_gro <<EOF
6
EOF

# configure the initial box, protein at the centre of the box, 1 nm distance from edge of 
# the simulation box
$exe editconf -f $refine_gro -c -d 1.0 -bt cubic -o $init_box

# solvate the box with water
$exe solvate -cp $init_box -cs spc216.gro -o $solv_box -p $top

# Prepare a tpr file to add ion in solution
$exe grompp -f ../mdp_files/em.mdp -c $solv_box -p $top -o topol.tpr

# Adding NaCl salt ions
$exe genion -s topol.tpr -p $top -pname NA -nname CL -conc $M -neutral -o final-box.gro <<EOF
SOL
EOF

rm -rf \#* topol.tpr mdout.mdp

