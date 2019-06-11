#!/bin/bash

. /opt/openfoam5/etc/bashrc

cd /opt/sw
BASE=$PWD

mkdir CFDEM
mkdir LIGGGHTS
cd CFDEM
git clone git://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git CFDEMcoupling-PUBLIC-$WM_PROJECT_VERSION
cd $BASE/LIGGGHTS
git clone git://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git
git clone git://github.com/CFDEMproject/LPP.git lpp

cd $BASE

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
