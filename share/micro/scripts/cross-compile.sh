#!/bin/bash
####################################################################################################
# This file generates the binanries (and sha 256 checksums) for bitcoin core (microcurrency edition)
# from the https://github.com/satoshiware/bitcoin repository. This script was made for linux 
# x86 & ARM 64 bit and has been tested on Debian 11.
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
sudo apt-get -y install g++-aarch64-linux-gnu binutils-aarch64-linux-gnu # ARM 64-bit

###Install SQLite (Required For The Descriptor Wallet)
sudo apt-get -y install libsqlite3-dev

###Download Bitcoin
sudo apt-get -y install git
git clone --depth=1 https://github.com/satoshiware/bitcoin ./bitcoin
cd bitcoin
rm -rf .git

###Compile all microcurrencies in the ./src/micros folder
sudo rm -rf ./bin; mkdir bin # Compressed binanries are stored in this ./bin file located in the downloaded repository folder
touch ./bin/SHA256SUMS # Compressed Binary hashes are stored here

micros=(./src/micros/*)
for micro in "${micros[@]}"; do 
	# Skip file names that don't start with the text "micro_" or names that contain the text "bitcoin"
	if [[ "$micro" == *"bitcoin"* || "$micro" != *"micro_"* ]]; then continue; fi
	
	# Get name of micro; Remove prefix ending with "_" and suffix starting with '.' from the microcurrency file name
	m_name=${micro#*_}
	m_name=${m_name%.*}

	# Copy the "micro" to the proper file location where compilation process can source it's contants
	cp ./src/micros/$micro ./src/micro.h
	
	###################################### x86 64 Bit ##############################################
	###Prepare the Cross Compiler for "x86 64 Bit"
	cd ./depends
	sudo make clean
	sudo make HOST=x86_64-pc-linux-gnu NO_TEST=1 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_ZMQ=1 NO_USDT=1 -j $(($(nproc)+1)) #x86 64-bit

	###Make Configuration
	cd ..
	./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

	### Select Configuration for "x86 64 Bit"
	CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure

	###Compile /w All Available Cores & Install
	make clean
	make -j $(($(nproc)+1))

	###Create Compressed Install Files in ./bin Directory
	make install DESTDIR=$PWD/mkinstall
	mv ./mkinstall/usr/local ./bitcoin-install
	rm -rf ./mkinstall

	###Compress Install Files for "x86 64 Bit"
	tar -czvf ./bin/bitcoin-${m_name}-x86_64-linux-gnu.tar.gz ./bitcoin-install #x86 64-Bit
	rm -rf ./bitcoin-install

	###################################### ARM 64 Bit ##############################################
	###Prepare the Cross Compiler for "ARM 64 Bit"
	cd ./depends
	sudo make clean
	sudo make HOST=aarch64-linux-gnu NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_ZMQ=1 NO_USDT=1 -j $(($(nproc)+1)) #ARM 64-bit

	###Make Configuration
	cd ..
	./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

	### Select Configuration for "ARM 64 Bit"
	CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site ./configure

	###Compile /w All Available Cores & Install
	make clean
	make -j $(($(nproc)+1))

	###Create Compressed Install Files in ./bin Directory
	make install DESTDIR=$PWD/mkinstall
	mv ./mkinstall/usr/local ./bitcoin-install
	rm -rf ./mkinstall

	###Compress Install Files for "ARM 64 Bit"
	tar -czvf ./bin/bitcoin-${m_name}-aarch64-linux-gnu.tar.gz ./bitcoin-install #ARM 64-Bit
	rm -rf ./bitcoin-install

	###################################### Calculate Hashes ##############################################
	sha256sum ./bin/bitcoin-${m_name}-aarch64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
	sha256sum ./bin/bitcoin-${m_name}-x86_64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
done

# Copy rpcauth python utility to ./bin folder
cp ./share/micro/rpcauth.py ./bin/rpcauth.py