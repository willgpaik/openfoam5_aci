#!/bin/bash
# installation script updated for Centos 7 ver.

cd /opt/sw
BASE=$PWD

export MPI_ROOT=/opt/sw/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/openmpi-2.1.1
export MPI_ARCH_FLAGS="-DMPICH_SKIP_MPICXX"
export MPI_ARCH_INC="-I$MPI_ARCH_PATH/include"
export MPI_ARCH_LIBS='-L$(MPI_ARCH_PATH)/lib -lmpich -lmpichcxx -lmpl -lopa -lrt'

export LD_LIBRARY_PATH=$MPI_ROOT/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
export CPATH=/usr/include:$CPATH
export CPATH=$MPI_ROOT/include:$CPATH
export PATH=$PATH:$MPI_ROOT/bin
. /opt/sw/OpenFOAM/OpenFOAM-5.x/etc/bashrc WM_MPLIB=OPENMPI FOAMY_HEX_MESH=yes

mkdir CFDEM
mkdir LIGGGHTS
cd CFDEM
git clone git://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git CFDEMcoupling-PUBLIC-$WM_PROJECT_VERSION
cd $BASE/LIGGGHTS
git clone git://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git
git clone git://github.com/CFDEMproject/LPP.git lpp
cd LIGGGHTS-PUBLIC/src/
make auto
#sed -i -e '22s/.*/AUTOINSTALL_VTK = "ON"/g' Makefile.user_default
#sed -i -e '130s#.*#VTK_INC_USR=-I$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/include/vtk-8.0#g' Makefile.user_default
#sed -i -e '132s#.*#VTK_LIB_USR=-L$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib#g' Makefile.user_default
sed -i -e '12s/.*/AUTOINSTALL_VTK = "ON"/g' ./MAKE/Makefile.user
sed -i -e '120s#.*#VTK_INC_USR=-I$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/include/vtk-8.0#g' ./MAKE/Makefile.user
sed -i -e '122s#.*#VTK_LIB_USR=-L$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib#g' ./MAKE/Makefile.user

cd $BASE

export PATH=$PATH:$BASE/LIGGGHTS/lpp/src:$BASE/LIGGGHTS-PUBLIC/src
export PATH=$PATH:$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/sw/OpenFOAM/OpenFOAM-5.x/platforms/linux64Gcc48DPInt32Opt/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib
export CPATH=$CPATH:/opt/sw/OpenFOAM/OpenFOAM-5.x/platforms/linux64Gcc48DPInt32Opt/include
export CPATH=$CPATH:$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/include/vtk-8.0

export CFDEM_VERSION=PUBLIC
export CFDEM_PROJECT_DIR=$BASE/CFDEM/CFDEMcoupling-$CFDEM_VERSION-$WM_PROJECT_VERSION
mkdir -p $BASE/CFDEM/$LOGNAME-$CFDEM_VERSION-$WM_PROJECT_VERSION
export CFDEM_PROJECT_USER_DIR=$BASE/CFDEM/$LOGNAME-$CFDEM_VERSION-$WM_PROJECT_VERSION
export CFDEM_bashrc=$CFDEM_PROJECT_DIR/src/lagrangian/cfdemParticle/etc/bashrc
export CFDEM_LIGGGHTS_SRC_DIR=$BASE/LIGGGHTS/LIGGGHTS-PUBLIC/src
export CFDEM_LIGGGHTS_MAKEFILE_NAME=auto
export CFDEM_LPP_DIR=$BASE/LIGGGHTS/lpp/src
export CFDEM_SRC_DIR=$CFDEM_PROJECT_DIR/src
export CFDEM_SOLVER_DIR=$CFDEM_PROJECT_DIR/applications/solvers
export CFDEM_DOC_DIR=$CFDEM_PROJECT_DIR/doc
export CFDEM_UT_DIR=$CFDEM_PROJECT_DIR/applications/utilities
export CFDEM_TUT_DIR=$CFDEM_PROJECT_DIR/tutorials
export CFDEM_LIGGGHTS_MAKEFILE_POSTIFX=
export CFDEM_VERBOSE=false

#cat $CFDEM_bashrc

source $CFDEM_bashrc

export PATH=$BASE/LIGGGHTS/lpp:$PATH

#cfdemSysTest

cfdemCompCFDEMall
