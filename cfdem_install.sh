#!/bin/bash

cd /opt/sw
BASE=$PWD

export LD_LIBRARY_PATH=/opt/openfoam5/platforms/linux64GccDPInt32Opt/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
export CPATH=/usr/include:$CPATH
export CPATH=/usr/lib/openmpi/include:$CPATH
export MPI_ROOT=/usr/lib/openmpi
export MPI_ARCH_FLAGS="-DMPICH_SKIP_MPICXX"
export MPI_ARCH_INC="-I$MPI_ARCH_PATH/include"
export MPI_ARCH_LIBS='-L$(MPI_ARCH_PATH)/lib -lmpich -lmpichcxx -lmpl -lopa -lrt'
. /opt/openfoam5/etc/bashrc

icoFoam --help

mkdir CFDEM
mkdir LIGGGHTS
cd CFDEM
git clone git://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git CFDEMcoupling-PUBLIC-$WM_PROJECT_VERSION
cd $BASE/LIGGGHTS
git clone git://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git
git clone git://github.com/CFDEMproject/LPP.git lpp

cd $BASE

export PATH=$PATH:/opt/sw/LIGGGHTS/lpp/src:/opt/sw/LIGGGHTS-PUBLIC/src
export PATH=$PATH:/opt/sw/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openfoam5/platforms/linux64Gcc48DPInt32Opt/lib
export LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/sw/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib
export CPATH=$CPATH:/opt/openfoam5/platforms/linux64Gcc48DPInt32Opt/include
export CPATH=$CPATH:/opt/sw/LIGGGHTS/IGGGHTS-PUBLIC/lib/vtk/install/include/vtk-8.0

export CFDEM_VERSION=PUBLIC
export CFDEM_PROJECT_DIR=/opt/sw/CFDEM/CFDEMcoupling-$CFDEM_VERSION-$WM_PROJECT_VERSION
mkdir -p /opt/sw/CFDEM/$LOGNAME-$CFDEM_VERSION-$WM_PROJECT_VERSION
export CFDEM_PROJECT_USER_DIR=/opt/sw/CFDEM/$LOGNAME-$CFDEM_VERSION-$WM_PROJECT_VERSION
export CFDEM_bashrc=$CFDEM_PROJECT_DIR/src/lagrangian/cfdemParticle/etc/bashrc
export CFDEM_LIGGGHTS_SRC_DIR=/opt/sw/LIGGGHTS/LIGGGHTS-PUBLIC/src
export CFDEM_LIGGGHTS_MAKEFILE_NAME=auto
export CFDEM_LPP_DIR=/opt/sw/LIGGGHTS/lpp/src
. $CFDEM_bashrc

cfdemSysTest

cfdemCompCFDEMall
