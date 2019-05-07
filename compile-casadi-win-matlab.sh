set -e

sudo apt-get update -qq
sudo apt-get install p7zip-full -y
sudo apt-get install bison -y
sudo apt-get install -y binutils gcc g++ gfortran git cmake liblapack-dev ipython python-dev python-numpy python-scipy python-matplotlib libmumps-seq-dev libblas-dev liblapack-dev libxml2-dev
sudo apt-get install -y fakeroot rpm alien

sudo apt-get remove -y mingw32
sudo apt-get install -y dpkg
sudo apt-get install -y mingw-w64 g++-mingw-w64 gcc-mingw-w64 gfortran-mingw-w64 mingw-w64-tools

# swig matlab
sudo apt-get install -y libpcre3-dev automake yodl
git clone https://github.com/jaeandersson/swig.git --depth=1
cd swig
./autogen.sh
./configure --prefix=$HOME/swig-matlab-install
make -j4
make install
cd ..

BUILD_TYPE=Release
NAME_SUFFIX=""
compilerprefix=x86_64-w64-mingw32
BITNESS=64

export CC=x86_64-w64-mingw32-gcc-posix
export CXX=x86_64-w64-mingw32-g++-posix
export CXXFLAGS=-lstdc++


# METIS
# wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz
# tar xzf metis-5.1.0.tar.gz
# cd metis-5.1.0/
# mkdir build
# cd build
# cp /mnt/c/Users/jonas/Documents/repos/ocl-deployment/toolchain-metis.cmake .
# cmake -DGKLIB_PATH=../GKlib/ -DCMAKE_INSTALL_PREFIX=$HOME/metis-install -DCMAKE_TOOLCHAIN_FILE=toolchain-metis.cmake ..
# make
# make install

rm metis-5.1.0.tar.gz
rm -r metis-5.1.0

# get ipopt
wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.3.tgz
tar -xf Ipopt-3.12.3.tgz
cd Ipopt-3.12.3
cd ThirdParty

cd Metis
./get.Metis
cd ..

cd Blas
./get.Blas
cd ..

cd Lapack
./get.Lapack
cd ..

cd Mumps
./get.Mumps
cd ..

cd ..

# required for modern x86_64-w64-mingw32-pkg-config
find . -type f -name "*" -exec sed -i'' -e 's/PKG_CONFIG_PATH/PKG_CONFIG_LIBDIR/g' {} +

mkdir build
cd build
mkdir $HOME/ipopt-install
../configure --host x86_64-w64-mingw32 --enable-dependency-linking --build mingw32 --prefix=$HOME/ipopt-install --disable-shared ADD_FFLAGS=-fPIC ADD_CFLAGS=-fPIC ADD_CXXFLAGS=-fPIC --with-blas=BUILD --with-lapack=BUILD --with-mumps=BUILD --with-metis=BUILD --without-hsl --without-asl
make -j4
make install
cd ..
cd ..

# setup compiler
export SWIG_HOME=$HOME/swig-matlab-install
export PATH=$SWIG_HOME/bin:$SWIG_HOME/share:$PATH
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/ipopt-install/lib/pkgconfig

# get matlab
export MATLAB_ROOT=$HOME/matlab

export LDFLAGS='-m -L/usr/lib -L/usr/x86_64-w64-mingw32/'
export CFLAGS='-m'
export CXXFLAGS='-m'
export LDFLAGS='-m'

# compile
git clone --branch 3.4.5 https://github.com/casadi/casadi.git --depth=1
cd casadi
mkdir build
cp /mnt/c/Users/jonas/Documents/repos/ocl-deployment/toolchain-casadi.cmake .
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-casadi.cmake -DWITH_OSQP=OFF -DWITH_THREAD_MINGW=OFF -DWITH_THREAD=ON -DWITH_AMPL=OFF -DCMAKE_BUILD_TYPE=Release -DWITH_SO_VERSION=OFF -DWITH_NO_QPOASES_BANNER=ON -DWITH_COMMON=ON -DWITH_HPMPC=OFF -DWITH_BUILD_HPMPC=OFF -DWITH_BLASFEO=OFF -DWITH_BUILD_BLASFEO=OFF -DINSTALL_INTERNAL_HEADERS=ON -DWITH_IPOPT=ON -DWITH_OPENMP=ON -DWITH_SELFCONTAINED=ON -DCMAKE_INSTALL_PREFIX=$HOME/casadi-matlab-install -DWITH_DEEPBIND=ON -DWITH_MATLAB=OFF -DWITH_DOC=OFF -DWITH_EXAMPLES=OFF -DWITH_EXTRA_WARNINGS=ON ..
make -j4
make install