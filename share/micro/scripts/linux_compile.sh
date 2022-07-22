#!/bin/bash
###############################################################################
###### Linux Headless Satoshiware/Bitcoin Compile #############################
###############################################################################
#	Bash wizard to help compile the satoshiware/bitcoin repository from github
#	on a fresh linux install. Used to test new changes in the code.
#
#	Note: Add a branch name as a command line parameter to compile it with all
#		defaults selected.
###############################################################################

###### Update/Upgrade ######
apt-get -y update
apt-get -y upgrade

#Install Essential Tools
apt-get -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3

#Install The Required Dependencies
apt-get -y install libevent-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev

#Install SQLite (Required For The Descriptor Wallet)
apt-get -y install libsqlite3-dev

#Download Bitcoin
apt-get -y install git-core
rm -rf ~/bitcoin
git clone https://github.com/satoshiware/bitcoin ~/bitcoin
cd ~/bitcoin

#Select Desired Branch
if [ $# -eq 1 ] ; then #Check if one command line parameter (branch selection) was supplied
    git checkout $1
else
	echo ""
	echo "Remote branches available on satoshiware/bitcoin:"
	echo ""
	branches=($(git branch -r))
	unset branches[0]
	unset branches[1]
	unset branches[2]
	index=1
	for i in "${branches[@]}"; do
		printf "\t%s)\t%s\n" "$index" "$i"
		index=$(expr $index + 1)
	done
	echo ""
	read -p "What satoshiware/bitcoin branch would you like to compile [select number]? " branch
	re='^[0-9]+$'
	if ! [[ $branch =~ $re ]] ; then
		echo "Error: Input not a number!" >&2; exit 1
	fi
	if (($branch < 1 || $branch > ${#branches[@]})); then
		echo "Error: Input out of range!" >&2; exit 1
	fi
	git checkout $(echo ${branches[$branch + 2]} | sed "s/origin\///")	
fi

#Select Compile Options & Install Required Dependencies
if [ $# -eq 1 ] ; then #Check if one command line parameter (branch selection) was supplied
    options="--disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no"
else
	read -p "Compile using defaults [N/n]? " yn
	case $yn in
		[Nn]* ) 
			read -p "Enable debugging [Y/y]? " yn
			case $yn in
				[Yy]* ) options="--enable-debug";;
				* ) ;;
			esac
			read -p "Enable the \"gprof\" tool used for measuring program performance [Y/y]? " yn
			case $yn in
				[Yy]* ) options="--enable-gprof ${options}";;
				* ) ;;
			esac
			read -p "Make all warnings into errors [Y/y]? " yn
			case $yn in
				[Yy]* ) options="--enable-werror ${options}";;
				* ) ;;
			esac
			read -p "Enable link time optimization [Y/y]? " yn
			case $yn in
				[Yy]* ) options="--enable-lto ${options}";;
				* ) ;;
			esac
			read -p "See more options (ZMQ, UPnP, NAT-PMP, or USDT) [Y/y]? " yn
			case $yn in
				[Yy]* ) 
					read -p "Enable ZMQ API [Y/y]? " yn
					case $yn in
						[Yy]* ) apt-get -y install libzmq3-dev;;
						* ) options="--disable-zmq ${options}";;
					esac
					read -p "Enable Universal Plug and Play (UPnP) for dynamic port forwarding [Y/y]? " yn
					case $yn in
						[Yy]* ) apt-get -y install libminiupnpc-dev;;
						* ) options="--with-miniupnpc=no ${options}";;
					esac
					read -p "Enable the NAT Port Mapping Protocol (NAT-PMP) [Y/y]? " yn
					case $yn in
						[Yy]* ) apt-get -y install libnatpmp-dev;;
						* ) options="--with-natpmp=no ${options}";;
					esac
					read -p "Enable User-Space, Statically Defined Tracing (USDT) [Y/y]? " yn
					case $yn in
						[Yy]* ) apt-get -y install systemtap-sdt-dev;;
						* ) options="--enable-usdt=no ${options}";;
					esac;;
				* ) options="--disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no ${options}";;
			esac;;
		* ) options="--disable-zmq --with-miniupnpc=no --with-natpmp=no --enable-usdt=no";;
	esac
fi

#Compile /w All Available Cores & Install
cd ~/bitcoin
./autogen.sh
./configure --without-bdb --with-gui=no $options
make clean
make -j $(($(nproc)+1))
make install
 
#User Report
echo ""
echo ""
echo "Ready to go! The following commands will run Bitcoin Core in microcurrency mode"
echo "    bitcoind -micro                           #Run Bitcoin Core"
echo "    bitcoind -micro -daemon                   #Run it in the background"
echo "    bitcoind -micro -maxtipage=\$SECONDS       #Maximum time (in seconds) that can pass from previous block (default = 24 hours)"
echo ""
echo ""