#!/usr/bin/env bash
echo "Cloning dependencies"
branch="EmptyGlory/20200209/p"
# FolderUpload="QuantumKiller"
# linkKernel="http://bit.ly/QuantumKiller or http://bit.ly/QK-kernels"
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chat_id_group_indo" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="prepare build kernel from <code>https://github.com/ZyCromerZ/android_kernel_asus_X01BD/tree/$branch</code>"
git clone --depth=1 https://github.com/ZyCromerZ/android_kernel_asus_X01BD -b $branch  kernel

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

GetCore=$(nproc --all)

# Push kernel to channel

TANGGAL=$(date +"%F-%S")

wget https://github.com/ZyCromerZ/builder-kernel/raw/master/sender.sh
chmod +x sender.sh
. sender.sh

sendinfo "PerSoNal" "$chat_id_group_indo"

buildKernel "P" "" "$chat_id_bot_log"

customInfo "$chat_id_group_indo" "$branch-P60Hz dah di build . . ."

buildKernel "P65Hz" "" "$chat_id_bot_log"

customInfo "$chat_id_group_indo" "$branch-P65Hz dah di build . . ."

buildKernel "P67Hz" "" "$chat_id_bot_log"

customInfo "$chat_id_group_indo" "$branch-P67Hz dah di build . . ."

buildKernel "P69Hz" "" "$chat_id_bot_log"

customInfo "$chat_id_group_indo" "$branch-P69Hz dah di build . . ."

buildKernel "P71Hz" "" "$chat_id_bot_log"

customInfo "$chat_id_group_indo" "$branch-P71Hz dah di build . . ."

curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/f4145eff14f9b35a426f881132e49c8af6077e87.patch | git am -3