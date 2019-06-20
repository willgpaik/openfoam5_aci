# Entire installation process takes over 3 hours on scivybridge
# Installation requires over 12 GB of empty space and 400,000 Inodes
# Default installation directory is $HOME/work
# In case you want to change the installation directory,
# please change paths on line 11, 66, and 69
# echo "alias of5x='source $HOME/scratch/OpenFOAM/OpenFOAM-5.x/etc/bashrc $FOAM_SETTINGS'"

# Strongly suggest working on an interactive job
# qsub -A open -I -l nodes=1:ppn=20:scivybridge -l walltime=6:00:00

# Change path to directory if needed
WORK=$HOME/scratch
mkdir $WORK/OpenFOAM
BASE=$WORK/OpenFOAM
WM_PROJECT=OpenFOAM-5.x

sed -i '/alias of5x/d' $HOME/.bashrc
sed -i '/of5x/d' $HOME/.bashrc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo Number of threads used for installation: $NP

# Download files
cd $BASE
git clone https://github.com/OpenFOAM/OpenFOAM-5.x.git
git clone https://github.com/OpenFOAM/ThirdParty-5.x.git

sed -i -e 's|FOAM_INST_DIR=$HOME/$WM_PROJECT|FOAM_INST_DIR=$BASE/$WM_PROJECT|g' ${BASE}/${WM_PROJECT}/etc/bashrc

cd ThirdParty-5.x
if [[ ! -d "./download" ]]; then
	mkdir -p download
	wget -nc -P download  https://www.cmake.org/files/v3.9/cmake-3.9.0.tar.gz
	wget -nc -P download  https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.10/CGAL-4.10.tar.xz
	wget -nc -P download https://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2
	wget -nc -P download https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.bz2
	wget -nc -P download http://www.paraview.org/files/v5.4/ParaView-v5.4.0.tar.gz

	tar -xzf download/cmake-3.9.0.tar.gz
	tar -xJf download/CGAL-4.10.tar.xz
	tar -xjf download/boost_1_55_0.tar.bz2
	tar -xjf download/openmpi-2.1.1.tar.bz2
	tar -xzf download/ParaView-v5.4.0.tar.gz --transform='s/ParaView-v5.4.0/ParaView-5.4.0/'

	wget -nc -P download http://mirror.centos.org/centos/6/os/x86_64/Packages/mesa-libGLU-devel-11.0.7-4.el6.x86_64.rpm
	rpm2cpio ./download/mesa-libGLU-devel-11.0.7-4.el6.x86_64.rpm | cpio -idmv

	wget -nc -P download http://mirror.centos.org/centos/6/os/x86_64/Packages/gstreamer-plugins-base-devel-0.10.29-2.el6.x86_64.rpm
	rpm2cpio ./download/gstreamer-plugins-base-devel-0.10.29-2.el6.x86_64.rpm | cpio -idmv
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/usr/lib64
fi

cd $BASE

echo Files are downloaded and extracted

sed -i -e 's/\(boost_version=\)boost-system/\1boost_1_55_0/' OpenFOAM-5.x/etc/config.sh/CGAL
sed -i -e 's/\(cgal_version=\)cgal-system/\1CGAL-4.10/' OpenFOAM-5.x/etc/config.sh/CGAL

ARCH=$(uname -m)
echo Running on $ARCH architecture
if [[ "$ARCH" == 'i386' ]]; then
	source $WORK/OpenFOAM/OpenFOAM-5.x/etc/bashrc WM_COMPILER_TYPE=ThirdParty WM_COMPILER=Gcc48 WM_ARCH_OPTION=32 WM_MPLIB=OPENMPI FOAMY_HEX_MESH=yes
	echo "alias of5x='source $BASE/OpenFOAM-5.x/etc/bashrc $FOAM_SETTINGS'" >> $HOME/.bashrc
elif [[ "$ARCH" == 'x86_64' ]]; then
	source $WORK/OpenFOAM/OpenFOAM-5.x/etc/bashrc WM_LABEL_SIZE=64 WM_COMPILER_TYPE=ThirdParty WM_COMPILER=Gcc48 WM_MPLIB=OPENMPI FOAMY_HEX_MESH=yes
	echo "alias of5x='source $BASE/OpenFOAM-5.x/etc/bashrc $FOAM_SETTINGS'" >> $HOME/.bashrc
fi
source $HOME/.bashrc

#echo "of5x" >> $HOME/.bashrc

of5x

echo Downloading gcc and cmake for OpenFOAM-5.x
cd $WM_THIRD_PARTY_DIR
wget -nc "https://raw.github.com/wyldckat/scripts4OpenFOAM3rdParty/master/getGcc"
wget -nc "https://raw.github.com/wyldckat/ThirdParty-2.0.x/binutils/makeBinutils"
wget -nc "https://raw.github.com/wyldckat/ThirdParty-2.0.x/binutils/getBinutils"
chmod +x get* make*	

echo Building CMAKE-3.x
cd $WM_THIRD_PARTY_DIR
./makeCmake > log.makeCmake 2>&1
wmRefresh

echo Building GCC-4.8
./getGcc gcc-4.8.5 gmp-5.1.2 mpfr-3.1.2 mpc-1.0.1
./makeGcc -no-multilib > log.makeGcc 2>&1
wmRefresh

echo Building GNU Binutils
./getBinutils
./makeBinutils gcc-4.8.5 > log.makeBinutils 2>&1

echo Building CGAL
echo This process may take a while
# This next command will take a little while...
./makeCGAL > log.makeCGAL 2>&1
# update the shell environment
wmRefresh

echo Building Qt-4.8.6
cd $WM_THIRD_PARTY_DIR
# Get the scripts we need
wget -nc https://github.com/wyldckat/scripts4OpenFOAM3rdParty/raw/master/getQt
wget -nc https://github.com/OpenFOAM/ThirdParty-2.4.x/raw/master/makeQt
wget -nc -P etc/tools/ https://github.com/OpenFOAM/ThirdParty-2.4.x/raw/master/etc/tools/QtFunctions
# make them executable
chmod +x getQt makeQt
# define correct download version and download it
sed -i -e 's=4\.6=4.8=' -e 's=4\.8\.4=4.8.6=' -e 's=/\$major/\$tarFile=/$major/$version/$tarFile=' getQt
./getQt
./makeQt qt-4.8.6 > log.makeQt 2>&1

# Setup OpenMPI for ParaView
cd $WM_THIRD_PARTY_DIR
./Allwmake > log.make 2>&1
wmRefresh

echo Building ParaView-5.4.0
echo This process may take few hours
# Build ParaView 5.4.0 with Python and MPI
if [[ "$ARCH" == 'i686' ]]; then
	cd $WM_THIRD_PARTY_DIR
	# Load the Python 2.7 that came with the SCL repository
	#source /opt/rh/python33/enable
	# this will take a while... somewhere between 30 minutes to 2 hours or more
	./makeParaView -qt-4.8.6 -mpi -python -python-lib /opt/aci/sw/python/3.6.3_anaconda-5.0.1/lib/libpython3.so -python-include/opt/aci/sw/python/3.6.3_anaconda-5.0.1/include/python3.6m > log.makePV 2>&1
elif [[ "$ARCH" == 'x86_64' ]]; then
	cd $WM_THIRD_PARTY_DIR
	# Load the Python 2.7 that came with the SCL repository
	#source /opt/rh/python33/enable
	# this will take a while... somewhere between 30 minutes to 2 hours or more
	./makeParaView -qt-4.8.6 -mpi -python -python-lib /opt/aci/sw/python/3.6.3_anaconda-5.0.1/lib/libpython3.so -python-include /opt/aci/sw/python/3.6.3_anaconda-5.0.1/include/python3.6m > log.makePV 2>&1
fi
wmRefresh

echo Building OpenFOAM-5.x
echo This process may take few hours
cd $WM_PROJECT_DIR
export CMAKE_PREFIX_PATH=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER/qt-4.8.6/

./Allwmake -j $NP > log.make 2>&1

# Run above again to get an installation summary
./Allwmake -j $NP > log.make 2>&1

# Check status of installation
of5x

echo $(which icoFoam)

CHK_COMPLETE=$(icoFoam -help)

if [[ -f $(which icoFoam) ]]; then
        icoFoam -help
        echo Installation is successfully completed!
else
        echo Could not successfully install OpenFOAM-5.x
fi

