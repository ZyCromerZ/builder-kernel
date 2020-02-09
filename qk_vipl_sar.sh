#!/usr/bin/env bash
echo "Cloning dependencies"
branch="QuantumKiller/20200204/VIPL-SAR"
FolderUpload="QuantumKiller/SAR"
linkKernel="http://bit.ly/QuantumKiller or http://bit.ly/QK-kernels"
git clone --depth=1 https://github.com/ZyCromerZ/android_kernel_asus_X01BD -b $branch  kernel

curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chat_id" -d "disable_web_page_preview=true" -d "parse_mode=markdown" -d text="prepare build kernel from <code>https://github.com/ZyCromerZ/android_kernel_asus_X01BD/tree/$branch</code>"

cd kernel
GetBranch=$(git rev-parse --abbrev-ref HEAD)
GetCommit=$(git log --pretty=format:'%h' -1)
HeadCommit=$GetCommit
echo "getting last commit"
GetREALlog="$(git log --pretty='format:%C(auto)%h : %s' -1)"
Getlog="${GetREALlog/\&/"and"}"
git clone --depth=1 https://github.com/NusantaraDevs/clang.git -b dev/11.0 Getclang
git clone --depth=1 https://github.com/baalajimaestro/aarch64-maestro-linux-android.git -b 05022020 GetGcc
git clone --depth=1 https://github.com/ZyCromerZ/AnyKernel3 AnyKernel

echo "Done"
rFolder=$(pwd)
CC="$(pwd)/Getclang/bin/clang"
GCC="$(pwd)/GetGcc/bin/aarch64-maestro-linux-gnu-"
IMAGE="$(pwd)/out/arch/arm64/boot/Image.gz-dtb"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyCromerZ
echo "get all cores"
GetCore=$(nproc --all)

echo "setup builder"

echo "prepare push"
# Push kernel to channel

echo "build started"

TANGGAL=$(date +"%F-%S")
echo "set tanggal"

wget https://github.com/ZyCromerZ/builder-kernel/raw/master/sender.sh
chmod +x sender.sh
. sender.sh

sendinfo "STABLE"

buildKernel "" "sf"

buildKernel "65Hz" "sf"

buildKernel "67Hz" "sf"

buildKernel "69Hz" "sf"

buildKernel "71Hz" "sf"