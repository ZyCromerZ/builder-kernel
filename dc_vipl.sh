#!/usr/bin/env bash
echo "Cloning dependencies"
branch="DeadlyCute/20200204/VIPL"
git clone --depth=1 https://github.com/ZyCromerZ/android_kernel_asus_X01BD -b $branch  kernel

cd kernel

git clone --depth=1 https://github.com/NusantaraDevs/DragonTC.git -b 10.0 Getclang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r53 GetGcc
# git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r53 GetGcc_32
git clone --depth=1 https://github.com/ZyCromerZ/AnyKernel3 AnyKernel

echo "Done"

#fix gcc crash
checkLib="$(ls /usr/lib/x86_64-linux-gnu/ | grep libisl.so -m1)"
if [ "$checkLib" != "libisl.so.15" ];then
    cp -af /usr/lib/x86_64-linux-gnu/$checkLib /usr/lib/x86_64-linux-gnu/libisl.so.15
fi

GCC="$(pwd)/GetGcc/bin/aarch64-linux-android-"
CC="$(pwd)/Getclang/bin/clang"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
export CONFIG_PATH=$PWD/arch/arm64/configs/X01BD_defconfig
PATH="${PWD}/Getclang/bin:${PWD}/GetGcc/bin:${PATH}"
export ARCH=arm64
export KBUILD_BUILD_HOST=ZyCromerZ
GetLastCommit=$(git show | grep "commit " | awk '{if($1=="commit") print $2;exit}' | cut -c 1-12)
export KBUILD_BUILD_USER="$GetLastCommit-Circleci"
GetCore=$(nproc --all)
# sticker plox
sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAADBQADVAADaEQ4KS3kDsr-OWAUFgQ" \
        -d chat_id=$chat_id
}
# Send info plox channel
sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build started on <code>Circle CI/CD</code>%0AFor device <b>Max pro m2</b>%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b> #Try"
}
# Push kernel to channel
push() {
    ZIP="$1"
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).%0AFor <b>X01BD</b>%0A<b>$(${CC} -v | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>%0A<b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
# Fin Error
finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build kernel from branch : $branch failed -_-"
    exit 1
}
# Compile plox
compile() {
    make -j$(($GetCore+1))  O=out ARCH=arm64 X01BD_defconfig
    make -j$(($GetCore+1))  O=out \
                            ARCH=arm64 \
                            CROSS_COMPILE=$(pwd)/GetGcc/bin/aarch64-linux-android- \
                            CC="$(pwd)/Getclang/bin/clang"

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
   cp -af out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
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
    fi
    cp -af anykernel-real.sh anykernel.sh
    sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME-$GetLastCommit by ZyCromerZ/g" anykernel.sh
        if [ -e init.spectrum.rc ];then
            sed -i "s/setprop persist.spectrum.kernel.*/setprop persist.spectrum.kernel $KERNEL_NAME/g" init.spectrum.rc
        fi
    zip -r "[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
    push "[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip"
    rm -rf "[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetLastCommit.zip"
    cd .. 
}
buildSekarang() {
    echo "build started"
    TANGGAL=$(date +"%F-%S")
    START=$(date +"%s")
    # sticker >/dev/null
    # sendinfo >/dev/null
    compile
    END=$(date +"%s")
    DIFF=$(($END - $START))
    zipping
}
buildSekarang