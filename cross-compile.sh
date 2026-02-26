#!/usr/bin/env bash
set -euo pipefail

####################################################################################################
# This file generates the binanries (and sha 256 checksums) for AZCoin Core
# from the https://github.com/satoshiware/azcoin repository. This script was made for linux
# x86 & ARM 64 bit and has been tested on Debian 13
####################################################################################################

# ---------------------------------------------
# Make sure we are running as root
# ---------------------------------------------
if [[ $EUID -ne 0 ]]; then
    log "Error: Must run as root (sudo)."
    exit 1
fi

# ---------------------------------------------
# Download AZCoin; select desired branch/tag/commit
# ---------------------------------------------
# Update package lists quietly, but fail if it doesn't work
echo "Preparing environment..."
if ! apt -y update -qq; then
    echo "ERROR: 'apt -y update' failed. Check your internet connection, sources.list, or run as root/sudo."
    echo "       This is required to install git."
    exit 1
fi
echo "System updated."

# Use apt (modern) instead of apt for better defaults
echo "Applying system upgrades (this may take a minute)..."
if ! apt upgrade -y >/dev/null 2>&1; then
    echo "WARNING: System upgrade had issues (some packages may be held back)."
    echo "         Continuing anyway — git install should still work."
    # Don't exit — upgrade failure isn't always fatal for our goal
fi
echo "System upgraded."

# Install git non-interactively; fail if installation fails
echo "Insalling git..."
if ! apt -y install git >/dev/null 2>&1; then
    echo "ERROR: Failed to install 'git' package."
    echo "       Possible reasons: No internet, package not available, insufficient permissions."
    echo "       Try running this script with sudo, or install git manually first."
    exit 1
fi
echo "Git is installed."

# Clone azcoin repository
rm -rf ./azcoin
echo "Cloning azcoin repository..."
if ! git clone https://github.com/satoshiware/azcoin ./azcoin; then
    echo "ERROR: git clone failed. Check internet, repo URL, or directory conflicts." >&2
    exit 1
fi
cd azcoin
echo "azcoin is downloaded."

# Select a branch, tag, or commit
echo "Fetching latest tags, branches, and history..."
git fetch --tags --prune origin
while true; do
    echo ""
    echo "===================================================================="
    echo " Which version do you want to build from?"
    echo "===================================================================="
    echo "  1) Branch tip     - Latest development code (may be unstable)"
    echo "  2) Tag            - Fixed release point (recommended for stability)"
    echo "  3) Commit hash    - Exact historical commit (advanced / reproduce bug)"
    echo ""
    echo " Most users should choose 2 (Tag) for a reliable, tested build."
    echo " Press Enter for default (latest tag / stable release)."
    echo "===================================================================="
    read -p "Enter 1, 2, 3, or just press Enter for latest tag: " choice

    # Default to tags if empty
    if [ -z "$choice" ]; then
        choice="2"
    fi

    case "$choice" in
        1)  # Branches
            echo ""
            echo "Available branches (origin/*):"
            echo "------------------------------"
            mapfile -t branch_list < <(git branch -r | grep -v 'HEAD' | sed 's/^[[:space:]]*origin\///' | sort | uniq)
            
            if [ ${#branch_list[@]} -eq 0 ]; then
                echo "No branches found. Falling back to manual entry."
            else
                for i in "${!branch_list[@]}"; do
                    printf "  %2d) %s\n" "$((i+1))" "${branch_list[i]}"
                done
            fi
            echo ""
            echo "Type a number, or enter the branch name directly (e.g. master, feature/docker-packaging)."
            read -p "Branch: " input
            selected="$input"

            if [[ "$selected" =~ ^[0-9]+$ ]]; then
                idx=$((selected - 1))
                if (( idx >= 0 && idx < ${#branch_list[@]} )); then
                    selected="${branch_list[idx]}"
                else
                    echo "Invalid number."
                    continue
                fi
            fi

            if git rev-parse --verify "origin/$selected" >/dev/null 2>&1; then
                git checkout -B "$selected" "origin/$selected"  # -B to reset if exists
                echo ""
                echo "SUCCESS: Now tracking branch '$selected'"
                git status --short --branch
                break
            else
                echo "Branch '$selected' not found. Try again."
                continue
            fi
            ;;

        2)  # Tags - last 24, newest first
            echo ""
            echo "Recent tags (newest creation date first - last 24):"
            echo "---------------------------------------------------"
            mapfile -t tag_list < <(git tag --sort=-creatordate | head -24)
            
            if [ ${#tag_list[@]} -eq 0 ]; then
                echo "No tags found."
            else
                for i in "${!tag_list[@]}"; do
                    tag="${tag_list[i]}"
                    # Show commit date + subject for context
                    desc=$(git log -1 --format="%ci %s" "$tag" 2>/dev/null | head -1 || echo "No description")
                    printf "  %2d) %-20s  %s\n" "$((i+1))" "$tag" "$desc"
                done
            fi
            echo ""
            echo "Recommended: Pick a recent v0.1.x tag for stability."
            echo "Type a number, or enter any tag name/hash directly (even if not listed)."
            read -p "Tag: " input
            selected="$input"

            if [[ "$selected" =~ ^[0-9]+$ ]]; then
                idx=$((selected - 1))
                if (( idx >= 0 && idx < ${#tag_list[@]} )); then
                    selected="${tag_list[idx]}"
                else
                    echo "Invalid number."
                    continue
                fi
            fi

            if git rev-parse --verify "refs/tags/$selected" >/dev/null 2>&1; then
                git checkout "$selected"
                echo ""
                echo "SUCCESS: Checked out tag '$selected' (detached HEAD - stable release point)"
                echo "Note: Detached HEAD is normal/safe here. To modify code later:"
                echo "      git checkout -b my-changes"
                git describe --tags --always
                break
            else
                echo "Tag '$selected' not found. Try again (check spelling/case)."
                continue
            fi
            ;;

        3)  # Commits - last 24 on current branch/HEAD
            echo ""
            echo "Recent commits (newest first - last 24):"
            echo "----------------------------------------"
            mapfile -t commit_list < <(git log -24 --format="%h %ci %s" --no-merges)
            
            if [ ${#commit_list[@]} -eq 0 ]; then
                echo "No commits found."
            else
                for i in "${!commit_list[@]}"; do
                    printf "  %2d) %s\n" "$((i+1))" "${commit_list[i]}"
                done
            fi
            echo ""
            echo "Type a number, or paste any full/short commit hash directly."
            read -p "Commit: " input
            selected="$input"

            if [[ "$selected" =~ ^[0-9]+$ ]]; then
                idx=$((selected - 1))
                if (( idx >= 0 && idx < ${#commit_list[@]} )); then
                    selected=$(echo "${commit_list[idx]}" | cut -d' ' -f1)
                else
                    echo "Invalid number."
                    continue
                fi
            fi

            if git rev-parse --verify "$selected" >/dev/null 2>&1; then
                git checkout "$selected"
                echo ""
                echo "SUCCESS: Checked out commit '$selected' (detached HEAD)"
                echo "Note: This is an exact historical point. Detached HEAD is normal."
                git log -1 --oneline --decorate
                break
            else
                echo "Commit '$selected' not found or invalid hash. Try again."
                continue
            fi
            ;;

        *) 
            echo "Invalid choice. Please enter 1, 2, or 3 (or Enter for default)."
            continue
            ;;
    esac
done

# ---------------------------------------------
# Install Essential Tools
# ---------------------------------------------
apt -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils curl zip
apt -y install pkg-config # Helper tool used when compiling applications and libraries.
apt -y install g++-aarch64-linux-gnu binutils-aarch64-linux-gnu # ARM 64-bit
apt -y install g++-mingw-w64-x86-64-posix # Windows x86 64-bit

# Install SQLite (Required For The Descriptor Wallet)
apt -y install libsqlite3-dev

# ---------------------------------------------
# Compile Time
# ---------------------------------------------
rm -rf ./bin; mkdir bin # Compressed binanries are stored in this ./bin file located in the downloaded repository folder
touch ./bin/SHA256SUMS # Compressed Binary hashes are stored here

# Info' for the User
echo "Generated binaries and related files will be transfered to the \"./azcoin/bin\" directory."
read -p "Press [Enter] key to continue..."

###################################### x86 64 Bit ##############################################
# Prepare the Cross Compiler for "x86 64 Bit"
cd ./depends
make clean
#make HOST=x86_64-pc-linux-gnu NO_TEST=1 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_ZMQ=1 NO_USDT=1 -j $(($(nproc)+1)) #x86 64-bit
#make HOST=x86_64-pc-linux-gnu NO_TEST=1 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_USDT=1 -j $(($(nproc)+1)) #x86 64-bit
make HOST=x86_64-pc-linux-gnu NO_TEST=1 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_USDT=1 -j $(($(nproc)+1)) #x86 64-bit

# Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the azcoin directory

# Select Configuration for "x86 64 Bit"
CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure

# Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

# Create Compressed Install Files in ./bin Directory
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./azcoin-install
rm -rf ./mkinstall

# Create Compressed Install Files in ./bin Directory <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< editing file structure <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
rm ./azcoin-install/bin/bench_bitcoin   ###<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< azcoin
rm ./azcoin-install/bin/test_bitcoin   ###<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< azcoin
rm -rf ./azcoin-install/include 
rm -rf ./azcoin-install/lib
rm -rf ./azcoin-install/share/man
cp -r ./share/rpcauth ./azcoin-install/share/rpcauth
















# Compress Install Files for "x86 64 Bit"
tar -czvf ./bin/azcoin-${m_name}-x86_64-linux-gnu.tar.gz ./azcoin-install #x86 64-Bit  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< let's put tag, or commit for m_name should work find <<<<<<<<<<<<<<<< Make it like bitcoin
rm -rf ./azcoin-install

###################################### ARM 64 Bit ##############################################
###Prepare the Cross Compiler for "ARM 64 Bit"
cd ./depends
sudo make clean
sudo make HOST=aarch64-linux-gnu NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_ZMQ=1 NO_USDT=1 -j $(($(nproc)+1)) #ARM 64-bit

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the azcoin directory

### Select Configuration for "ARM 64 Bit"
CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site ./configure

###Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

###Create Compressed Install Files in ./bin Directory
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./azcoin-install
rm -rf ./mkinstall

###Compress Install Files for "ARM 64 Bit"
tar -czvf ./bin/azcoin-${m_name}-aarch64-linux-gnu.tar.gz ./azcoin-install #ARM 64-Bit
rm -rf ./azcoin-install

###################################### Windows x86 64 Bit ##############################################
###Prepare the Cross Compiler for "Windows x86 64 Bit"
cd ./depends
sudo make clean
sudo make HOST=x86_64-w64-mingw32 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_BOOST=1 NO_LIBEVENT=1 NO_ZMQ=1 NO_USDT=1 -j $(($(nproc)+1)) #Windows (x86 64-bit)

###Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the bitcoin directory

### Select Configuration for "Windows x86 64 Bit"
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure
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
zip -ll -X -r ./bin/azcoin-${m_name}-bitcoin-win64.zip ./azcoin-install #Windows x86 64-bit

###################################### Calculate Hashes ##############################################
sha256sum ./bin/azcoin-${m_name}-x86_64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
sha256sum ./bin/azcoin-${m_name}-aarch64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
sha256sum ./bin/azcoin-${m_name}-win64.zip >> ./bin/SHA256SUMS

# Copy rpcauth python utility to ./bin folder
cp ./share/rpcauth/rpcauth.py ./bin/rpcauth.py