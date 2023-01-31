#!/bin/bash
####################################################################################################
# This file generates the binanries (and sha 256 checksums) for bitcoin core (microcurrency edition)
# from the https://github.com/satoshiware/bitcoin repository. This script was made for linux 
# x86 64 bit and has been tested on Debian 11.
####################################################################################################

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Generated binaries and related files are transfered to the \"./bitcoin/bin\" directory."
echo "Binaries are created from the latest master branch commit @ https://github.com/satoshiware/bitcoin."
read -p "Press [Enter] key to continue..."

###Update/Upgrade
sudo apt-get -y update
sudo apt-get -y upgrade

###Install Essential Tools
sudo apt-get -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils curl zip

###Install The Required Dependencies
sudo apt-get -y install libevent-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev

###Install The Optional Dependencies
sudo apt-get -y install libzmq3-dev libminiupnpc-dev libnatpmp-dev systemtap-sdt-dev

###Install SQLite (Required For The Descriptor Wallet)
sudo apt-get -y install libsqlite3-dev

###Download Bitcoin
sudo apt-get -y install git
git clone https://github.com/satoshiware/bitcoin ./bitcoin

###git checkout $COMMIT_HASH #Find the latest release at this link and its corresponding commit hash (7 digit code)

###Update, Add, or Overwrite microcurrency Header File: ./src/micro.h

###Install Cross Compilation Dependencies
#Linux x86 64-bit are already installed
sudo apt-get -y install g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf #ARM 32-bit
sudo apt-get -y install g++-aarch64-linux-gnu binutils-aarch64-linux-gnu #ARM 64-bit
sudo apt -y install g++-mingw-w64-x86-64-posix #Windows x86 64-bit

###Prepare the Cross Compiler for "x86 64 Bit"
cd ./bitcoin/depends
sudo make clean
sudo make HOST=x86_64-pc-linux-gnu NO_QT=1 NO_BDB=1 NO_UPNP=1 NO_NATPMP=1 -j $(($(nproc)+1)) #x86 64-bit

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

### Select Configuration for "x86 64 Bit"
CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure --without-bdb --with-gui=no --disable-lto --disable-debug --disable-gprof --disable-werror --disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no

###Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

###Create Compressed Install Files in ./bin Directory
rm -rf ./mkinstall
rm -rf ./bitcoin-install
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./bitcoin-install
mkdir bin

###Compress Install Files for "x86 64 Bit"
tar -czvf ./bin/bitcoin-x86_64-linux-gnu.tar.gz ./bitcoin-install #x86 64-Bit

###################################### ARM 32 Bit ##############################################
###Prepare the Cross Compiler for "ARM 32 Bit"
cd ./depends
sudo make clean
sudo make HOST=arm-linux-gnueabihf NO_QT=1 NO_BDB=1 NO_UPNP=1 NO_NATPMP=1 -j $(($(nproc)+1)) #ARM 32-bit

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

### Select Configuration for "ARM 32 Bit"
CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site ./configure --without-bdb --with-gui=no --disable-lto --disable-debug --disable-gprof --disable-werror --disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no

###Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

###Create Compressed Install Files in ./bin Directory
rm -rf ./mkinstall
rm -rf ./bitcoin-install
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./bitcoin-install
mkdir bin

###Compress Install Files for "ARM 32 Bit"
tar -czvf ./bin/bitcoin-arm-linux-gnueabihf.tar.gz ./bitcoin-install #ARM 32-Bit
		
###################################### ARM 64 Bit ##############################################
###Prepare the Cross Compiler for "ARM 64 Bit"
cd ./depends
sudo make clean
sudo make HOST=aarch64-linux-gnu NO_QT=1 NO_BDB=1 NO_UPNP=1 NO_NATPMP=1 -j $(($(nproc)+1)) #ARM 64-bit

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

### Select Configuration for "ARM 64 Bit"
CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site ./configure --without-bdb --with-gui=no --disable-lto --disable-debug --disable-gprof --disable-werror --disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no

###Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

###Create Compressed Install Files in ./bin Directory
rm -rf ./mkinstall
rm -rf ./bitcoin-install
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./bitcoin-install
mkdir bin

###Compress Install Files for "ARM 64 Bit"
tar -czvf ./bin/bitcoin-aarch64-linux-gnu.tar.gz ./bitcoin-install #ARM 64-Bit

###################################### Windows x86 64 Bit ##############################################
###Prepare the Cross Compiler for "Windows x86 64 Bit"
cd ./depends
sudo make clean
sudo make HOST=x86_64-w64-mingw32 NO_QT=1 NO_BDB=1 NO_UPNP=1 NO_NATPMP=1 -j $(($(nproc)+1)) #Windows (x86 64-bit)

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

### Select Configuration for "Windows x86 64 Bit"
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --without-bdb --with-gui=no --disable-lto --disable-debug --disable-gprof --disable-werror --disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no

###Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

###Create Compressed Install Files in ./bin Directory
rm -rf ./mkinstall
rm -rf ./bitcoin-install
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./bitcoin-install
mkdir bin

###Compress Install Files for "Windows x86 64 Bit"
zip -ll -X -r ./bin/bitcoin-win64.zip ./bitcoin-install #Windows x86 64-bit

###################################### Calculate Hashes ##############################################
sha256sum ./bin/bitcoin-aarch64-linux-gnu.tar.gz > ./bin/SHA256SUMS
sha256sum ./bin/bitcoin-arm-linux-gnueabihf.tar.gz >> ./bin/SHA256SUMS
sha256sum ./bin/bitcoin-win64.zip >> ./bin/SHA256SUMS
sha256sum ./bin/bitcoin-x86_64-linux-gnu.tar.gz >> ./bin/SHA256SUMS