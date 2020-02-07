#!/usr/bin/env bash
echo "Cloning dependencies"
branch="VirusNgepet/20200120/p"
git clone --depth=1 https://github.com/ZyCromerZ/android_kernel_asus_X01BD -b $branch  kernel

cd kernel

echo "getting last commit"

git clone --depth=1 https://github.com/NusantaraDevs/DragonTC.git -b daily/10.0 Getclang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r50 GetGcc
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r50 GetGcc_32
git clone --depth=1 https://github.com/ZyCromerZ/AnyKernel3 AnyKernel

echo "Done"

GCC="$(pwd)/GetGcc/bin/aarch64-linux-android-"
IMAGE="$(pwd)/out/arch/arm64/boot/Image.gz-dtb"
export CONFIG_PATH=$PWD/arch/arm64/configs/X01BD_defconfig
PATH="${PWD}/Getclang/bin:${PWD}/GetGcc/bin:${PWD}/GetGcc_32/bin:${PATH}"
export ARCH=arm64
export KBUILD_BUILD_USER=ZyCromerZ
echo "get all cores"
GetCore=$(nproc --all)

echo "setup builder"


echo "prepare push"
# Push kernel to channel
push() {
    ZIP="$1"
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id_private" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).
For <b>X01BD</b>
<b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
echo "prepare finner"
# Fin Error
finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id_private" \
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
    sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME-$GetLastCommit by ZyCromerZ/g" anykernel.sh
        if [ -e init.spectrum.rc ];then
            sed -i "s/setprop persist.spectrum.kernel.*/setprop persist.spectrum.kernel $KERNEL_NAME/g" init.spectrum.rc
        fi
    Type="P"
    if [ ! -z "$1" ];then
        Type="67"
    fi
    zip -r "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
    push "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip"
    rm -rf "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip"
    cd .. 
}
echo "build started"

TANGGAL=$(date +"%F-%S")
echo "set tanggal"

START=$(date +"%s")
echo "set waktu"

buildKernel() {
    GetLastCommit="$(git log --pretty=format:'%h' -1)"
    export KBUILD_BUILD_HOST="$GetLastCommit-Circleci"
    if [ ! -z "$1" ];then
        if [ "$1" == "67Hz" ];then
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/aafb3e87895f0e1b714a254861e2e8dfb32c3124.patch | git am -3
        fi
    fi
    make -j$(($GetCore+1))  O=out ARCH=arm64 X01BD_defconfig
    make -j$(($GetCore+1))  O=out \
                            ARCH=arm64 \
                            CROSS_COMPILE=aarch64-linux-android- \
                            CROSS_COMPILE_ARM32=arm-linux-androideabi-

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
buildKernel