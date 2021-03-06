#!/usr/bin/env bash
echo "Cloning dependencies"
branch="QuantumKiller/20200210/VIPLA"
FolderUpload="QuantumKiller/TEST"
linkKernel="http://bit.ly/QuantumKiller or http://bit.ly/QK-kernels"
# curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chat_id" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="prepare build kernel from <code>https://github.com/ZyCromerZ/android_kernel_asus_X01BD/tree/$branch</code>"
git clone --depth=1 https://github.com/ZyCromerZ/android_kernel_asus_X01BD -b $branch  kernel

cd kernel
GetBranch=$(git rev-parse --abbrev-ref HEAD)
GetCommit=$(git log --pretty=format:'%h' -1)
HeadCommit=$GetCommit
echo "getting last commit"
GetREALlog="$(git log --pretty='format:%C(auto)%h : %s' -1)"
Getlog="${GetREALlog/\&/"and"}"
git clone --depth=1 https://github.com/Haseo97/Clang-11.0.0.git -b 11.0.0 Getclang
git clone --depth=1 https://github.com/baalajimaestro/aarch64-maestro-linux-android.git -b 05022020 GetGcc
git clone --depth=1 https://github.com/ZyCromerZ/AnyKernel3 AnyKernel

echo "Done"
rFolder=$(pwd)
CC="$(pwd)/Getclang/bin/clang"
GCC="$(pwd)/GetGcc/bin/aarch64-maestro-linux-gnu-"
IMAGE="$(pwd)/out/arch/arm64/boot/Image.gz-dtb"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyCromerZ

GetCore=$(nproc --all)

# Push kernel to channel

TANGGAL=$(date +"%F-%S")

wget https://github.com/ZyCromerZ/builder-kernel/raw/master/sender.sh
chmod +x sender.sh
. sender.sh

sendinfo "VIPL"

buildKernel "" "sf"

buildKernel "65Hz" "sf"

buildKernel "66Hz" "sf"

buildKernel "67Hz" "sf"

buildKernel "68Hz" "sf"

buildKernel "69Hz" "sf"

buildKernel "71Hz" "sf"

git reset --hard $HeadCommit

curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/6b75a30c36bae997be8de6357fb04950bc34897b.patch | git am -3

curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/983771bc483cd0fc47cb98a5862f1ac96943fba4.patch | git am -3

curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/959a49f0e7efb16443dbf17d3abaa5dbbc514425.patch | git am -3

FolderUpload="DeadlyCute/TEST"

linkKernel="http://bit.ly/DeadlyCute / http://bit.ly/DC-Kernels"

GetBranch=$(git rev-parse --abbrev-ref HEAD)

GetCommit=$(git log --pretty=format:'%h' -1)

HeadCommit=$GetCommit

buildKernel "" "sf"

buildKernel "65Hz" "sf"

buildKernel "66Hz" "sf"

buildKernel "67Hz" "sf"

buildKernel "68Hz" "sf"

buildKernel "69Hz" "sf"

buildKernel "71Hz" "sf"