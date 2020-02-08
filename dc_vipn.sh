#!/usr/bin/env bash
echo "Cloning dependencies"
branch="DeadlyCute/20200204/VIPN"
FolderUpload="DeadlyCute"
linkKernel="http://bit.ly/DeadlyCute / http://bit.ly/DC-Kernels"
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
echo "get all cores"
GetCore=$(nproc --all)

echo "setup builder"

ForSendInfo="Build started on <code>Circle CI/CD</code>

Branch 
- <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)

Under commit 
- <code>$Commit</code>

Using compiler: 
- <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>
- <code>$(${CC} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>

Started on <code>$(date)</code>
<b>Build Status:</b> #STABLE"

echo "prepare push"
# Push kernel to channel
push() {
    ZIP="$1"
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).
For <b>X01BD</b>
<b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
pushSF() {
    Zip_File="$(pwd)/$1"
    rsync -avP -e "ssh -o StrictHostKeyChecking=no" "$Zip_File" $my_host@frs.sourceforge.net:/home/frs/project/zyc-kernel/$FolderUpload/
    if [ "$3" != "" ];then
        Text="New kernel !!%0ABuild took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).%0A- Kernel name : $2%0A -Refreshrate : $3(oc)%0A%0Alink : $linkKernel"
    else
        Text="New kernel !!%0ABuild took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).%0A- Kernel name : $2%0A -Refreshrate : 60Hz(default)%0A%0Alink : $linkKernel"
    fi
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="$Text"
}
sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="$ForSendInfo"
}
echo "prepare finner"
# Fin Error
finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build kernel from branch : $branch failed -_-"
    exit 1
}
echo "prepare zipping"
# Zipping
zipping() {
    KERNEL_NAME=$(cat "$(pwd)/arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    ZIP_KERNEL_VERSION="4.4.$(cat "$(pwd)/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')"
    cd AnyKernel || exit 1
    if [ -e "init.spectrum.rc" ];then
        rm -rf init.spectrum.rc
    fi
    if [[ "$KERNEL_NAME" == *"VIPN"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/vipn.rc
        cp -af vipn.rc init.spectrum.rc
        rm -rf vipn.rc
    elif [[ "$KERNEL_NAME" == *"VIPL"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/vipl.rc
        cp -af vipl.rc init.spectrum.rc
        rm -rf vipl.rc
    elif [[ "$KERNEL_NAME" == *"iLoC"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/iLoC.rc
        cp -af iLoC.rc init.spectrum.rc
        rm -rf iLoC.rc
    elif [[ "$KERNEL_NAME" == *"MiuiXDC"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/vipn.rc
        cp -af vipn.rc init.spectrum.rc
        rm -rf vipn.rc
    elif [[ "$KERNEL_NAME" == *"VirusNgepet"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/private-3.0.rc
        cp -af private-3.0.rc init.spectrum.rc
        rm -rf private-3.0.rc
    elif [[ "$KERNEL_NAME" == *"VIP"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/vip.rc
        cp -af vip.rc init.spectrum.rc
        rm -rf vip.rc
    fi
    cp -af anykernel-real.sh anykernel.sh
    sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME- by ZyCromerZ/g" anykernel.sh
        if [ -e init.spectrum.rc ];then
            sed -i "s/setprop persist.spectrum.kernel.*/setprop persist.spectrum.kernel $KERNEL_NAME/g" init.spectrum.rc
        fi
    Type=""
    if [ ! -z "$1" ];then
        Type="$1"
    fi
    zip -r "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME.zip" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
    # push "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME.zip"
    pushSF "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME.zip" "$KERNEL_NAME" "$Type"
    rm -rf "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME.zip"
    cd .. 
}
echo "build started"

TANGGAL=$(date +"%F-%S")
echo "set tanggal"

buildKernel() {
    START=$(date +"%s")
    if [ ! -z "$1" ];then
        if [ "$1" == "67Hz" ];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/aafb3e87895f0e1b714a254861e2e8dfb32c3124.patch | git am -3
        fi
        if [ "$1" == "71Hz" ];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/aca1f53268e819422949464b7fcacf545aa71ab9.patch | git am -3
        fi
        GetBranch=$(git rev-parse --abbrev-ref HEAD)
        GetCommit=$(git log --pretty=format:'%h' -1)
    fi
    export KBUILD_BUILD_HOST="$GetBranch-$GetCommit"
    make -j$(($GetCore+1))  O=out ARCH=arm64 X01BD_defconfig
    make -j$(($GetCore+1))  O=out \
                            ARCH=arm64 \
                            CROSS_COMPILE=$rFolder/GetGcc/bin/aarch64-maestro-linux-gnu- \
                            CC=$rFolder/Getclang/bin/clang \
                            CLANG_TRIPLE=aarch64-linux-gnu-
                            

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp -af out/arch/arm64/boot/Image.gz-dtb AnyKernel
    END=$(date +"%s")
    DIFF=$(($END - $START))
    if [ ! -z "$1" ];then
        zipping "$1"
    else
        zipping
    fi
}
sendinfo

buildKernel

buildKernel "67Hz"

buildKernel "71Hz"