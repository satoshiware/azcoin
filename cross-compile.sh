#!/usr/bin/env bash
set -euo pipefail

####################################################################################################
# AZCoin Core Multi-Platform Release Binary Builder Script
#
# This script automates the full process of building reproducible, cross-compiled binaries
#
# Main steps performed:
#   1. Checks for root privileges (required for package installation)
#   2. Updates system packages and installs essential build tools (git, cross-compilers, etc.)
#   3. Clones the AZCoin repository and fetches all tags/branches
#   4. Interactive prompt: lets the user select a specific branch tip, release tag, or commit hash
#      → Stores the selected version in $SELECTED_VERSION (tag name if tag chosen, else short commit hash)
#   5. Installs remaining native and cross-compile dependencies
#   6. Cross-compiles AZCoin Core for three platforms using the depends/ system:
#      - Linux x86_64 (native-like)
#      - Linux aarch64 (ARM64)
#      - Windows x86_64 (MinGW-w64)
#   7. For each platform:
#      - Runs autogen.sh → configure (with depends config.site) → make clean → make
#      - Installs to a staging directory
#      - Removes unnecessary files (benchmarks, tests, headers, libs, man pages)
#      - Copies rpcauth helper scripts
#      - Creates compressed archive:
#        • tar.gz for Linux platforms
#        • zip for Windows
#      - Places archives in ./azcoin/bin/
#   8. Generates SHA256SUMS file containing hashes of all produced archives
#
# Requirements:
#   - Must be run as root (sudo) due to apt package installation
#   - Tested on Debian 13 (Bookworm/Trixie) x86_64
#   - Significant disk space and RAM recommended (cross-compilation is resource-intensive)
#   - Internet access required for cloning and package downloads
#   - The script uses aggressive parallel compilation (-j$(nproc)+1). Reduce if OOM occurs.
#
# Output:
#   - All final binaries and checksums are placed in ./azcoin/bin/
#     Example:
#       azcoin-v0.1.2-x86_64-linux-gnu.tar.gz
#       azcoin-v0.1.2-aarch64-linux-gnu.tar.gz
#       azcoin-v0.1.2-win64.zip
#       SHA256SUMS
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
    echo " 1) Branch tip     - Latest development code (may be unstable)"
    echo " 2) Tag            - Fixed release point (recommended for stability)"
    echo " 3) Commit hash    - Exact historical commit (advanced / reproduce bug)"
    echo ""
    echo " Most users should choose 2 (Tag) for a reliable, tested build."
    echo " Press Enter for default (latest tag / stable release)."
    echo "===================================================================="
    read -p "Enter 1, 2, 3, or just press Enter for latest tag: " choice

    if [ -z "$choice" ]; then
        choice="2"
    fi

    case "$choice" in
        1)  # ── Branch ───────────────────────────────────────────────────────────────
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
            echo "Type a number, or enter the branch name directly (e.g. master)."
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
                git checkout -B "$selected" "origin/$selected"
                echo ""
                echo "SUCCESS: Now tracking branch '$selected'"
                git status --short --branch

                SELECTED_VERSION=$(git rev-parse --short HEAD)
                echo "Selected version (short commit hash): $SELECTED_VERSION"

                break
            else
                echo "Branch '$selected' not found. Try again."
                continue
            fi
            ;;

        2)  # ── Tag ─────────────────────────────────────────────────────────────────
            echo ""
            echo "Recent tags (newest creation date first - last 24):"
            echo "---------------------------------------------------"
            mapfile -t tag_list < <(git tag --sort=-creatordate | head -24)

            if [ ${#tag_list[@]} -eq 0 ]; then
                echo "No tags found."
            else
                for i in "${!tag_list[@]}"; do
                    tag="${tag_list[i]}"
                    desc=$(git log -1 --format="%ci %s" "$tag" 2>/dev/null | head -1 || echo "No description")
                    printf "  %2d) %-20s  %s\n" "$((i+1))" "$tag" "$desc"
                done
            fi
            echo ""
            echo "Recommended: Pick a recent v0.1.x tag for stability."
            echo "Type a number, or enter any tag name/hash directly."
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
                echo "SUCCESS: Checked out tag '$selected' (detached HEAD)"
                echo "Note: Detached HEAD is normal/safe here."

                # ── Tag case: use the tag name directly ──
                SELECTED_VERSION="$selected"
                echo "Selected version (tag): $SELECTED_VERSION"

                # Optional: show the underlying commit too
                SHORT_COMMIT=$(git rev-parse --short HEAD)
                echo "  (points to commit: $SHORT_COMMIT)"

                git describe --tags --always
                break
            else
                echo "Tag '$selected' not found. Try again (check spelling/case)."
                continue
            fi
            ;;

        3)  # ── Commit ──────────────────────────────────────────────────────────────
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
            echo "Type a number, or paste any commit hash."
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

                SELECTED_VERSION=$(git rev-parse --short HEAD)
                echo "Selected version (short commit hash): $SELECTED_VERSION"

                git log -1 --oneline --decorate
                break
            else
                echo "Commit '$selected' not found or invalid."
                continue
            fi
            ;;

        *)
            echo "Invalid choice. Please enter 1, 2, or 3 (or Enter for default)."
            continue
            ;;
    esac
done
echo ""
echo "Selected version: $SELECTED_VERSION"

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

###################################### x86 64 Bit ##############################################
echo "Ready to compile for linux (x86_64)"
read -p "Press [Enter] key to continue..."

# Prepare the Cross Compiler for "x86 64 Bit"
cd ./depends
make clean
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

# Customize azcoin-install files & directory structure
rm ./azcoin-install/bin/bench_*
rm ./azcoin-install/bin/test_*
rm -rf ./azcoin-install/include
rm -rf ./azcoin-install/lib
rm -rf ./azcoin-install/share/man
cp -r ./share/rpcauth ./azcoin-install/share/rpcauth

# Compress Install Files for "x86 64 Bit"
tar -czvf ./bin/azcoin-${SELECTED_VERSION#v}-x86_64-linux-gnu.tar.gz ./azcoin-install #x86 64-Bit
rm -rf ./azcoin-install

###################################### ARM 64 Bit ##############################################
echo "Ready to compile for linux (ARM_64)"
read -p "Press [Enter] key to continue..."

# Prepare the Cross Compiler for "ARM 64 Bit"
cd ./depends
make clean
make HOST=aarch64-linux-gnu NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_USDT=1 -j $(($(nproc)+1)) #ARM 64-bit

# Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the azcoin directory

# Select Configuration for "ARM 64 Bit"
CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site ./configure

# Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

# Create Compressed Install Files in ./bin Directory
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./azcoin-install
rm -rf ./mkinstall

# Customize azcoin-install files & directory structure
rm ./azcoin-install/bin/bench*
rm ./azcoin-install/bin/test*
rm -rf ./azcoin-install/include
rm -rf ./azcoin-install/lib
rm -rf ./azcoin-install/share/man
cp -r ./share/rpcauth ./azcoin-install/share/rpcauth

# Compress Install Files for "ARM 64 Bit"
tar -czvf ./bin/azcoin-${SELECTED_VERSION#v}-aarch64-linux-gnu.tar.gz ./azcoin-install #ARM 64-Bit
rm -rf ./azcoin-install

###################################### Windows x86 64 Bit ##############################################
echo "Ready to compile for Windows (x86_64)"
read -p "Press [Enter] key to continue..."

# Prepare the Cross Compiler for "Windows x86 64 Bit"
cd ./depends
make clean
make HOST=x86_64-w64-mingw32 NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 NO_USDT=1 -j $(($(nproc)+1)) #Windows (x86 64-bit)

# Make Configuration
cd ..
./autogen.sh # Make sure Bash's current working directory is the azcoin directory

# Select Configuration for "Windows x86 64 Bit"
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure

# Compile /w All Available Cores & Install
make clean
make -j $(($(nproc)+1))

# Create Compressed Install Files in ./bin Directory
rm -rf ./mkinstall
rm -rf ./azcoin-install
make install DESTDIR=$PWD/mkinstall
mv ./mkinstall/usr/local ./azcoin-install

# Customize azcoin-install files & directory structure
rm ./azcoin-install/bin/bench*
rm ./azcoin-install/bin/test*
rm ./azcoin-install/bin/libbitcoinconsensus-0.dll
rm -rf ./azcoin-install/include
rm -rf ./azcoin-install/lib
rm -rf ./azcoin-install/share/man
cp -r ./share/rpcauth ./azcoin-install/share/rpcauth

# Compress Install Files for "Windows x86 64 Bit"
zip -ll -X -r ./bin/azcoin-${SELECTED_VERSION#v}-win64.zip ./azcoin-install #Windows x86 64-bit
rm -rf ./azcoin-install

# ---------------------------------------------
# Calculate Hashes
# ---------------------------------------------
sha256sum ./bin/azcoin-${SELECTED_VERSION#v}-x86_64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
sha256sum ./bin/azcoin-${SELECTED_VERSION#v}-aarch64-linux-gnu.tar.gz >> ./bin/SHA256SUMS
sha256sum ./bin/azcoin-${SELECTED_VERSION#v}-win64.zip >> ./bin/SHA256SUMS