#!/usr/bin/env bash
push() {
    ZIP="$1"
    if [ "$3" != "" ];then
        RefreshRT="$3(oc)"
    else
        RefreshRT="60Hz(default)"
    fi
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="New kernel !!
Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).

- Kernel name : $2
- Refreshrate : $RefreshRT
- Pass Protected : $4
 
Using compiler: 
- <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>
- <code>$(${CC} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>" >/dev/null
}
pushSF() {
    Zip_File="$(pwd)/$1"
    rsync -avP -e "ssh -o StrictHostKeyChecking=no" "$Zip_File" $my_host@frs.sourceforge.net:/home/frs/project/zyc-kernel/$FolderUpload/ >/dev/null
    if [ "$3" != "" ];then
        RefreshRT="$3(oc)"
    else
        RefreshRT="60Hz(default)"
    fi
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="New kernel !!
Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).

- Kernel name : $2
- Refreshrate : $RefreshRT
- Pass Protected : $4
 
Using compiler: 
- <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>
- <code>$(${CC} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>
link : $linkKernel" >/dev/null
}
sendinfo() {
    if [ ! -z "$2" ];then
        SendTo="$2"
    else
        SendTo="$chat_id"
    fi
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$SendTo" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build started on <code>Circle CI/CD</code>

Branch 
- <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)

Under commit 
- <code>$Getlog</code>

Using compiler: 
- <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>
- <code>$(${CC} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>

Started on <code>$(date)</code>
<b>Build Status:</b> #$1" >/dev/null
}
echo "prepare finner"
# Fin Error
finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build kernel from branch : $branch failed -_-" >/dev/null
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
    elif [[ "$KERNEL_NAME" == *"EmptyGlory"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/private-3.0_2.rc
        cp -af private-3.0_2.rc init.spectrum.rc
        rm -rf private-3.0_2.rc
    elif [[ "$KERNEL_NAME" == *"VIP"* ]];then
        wget https://github.com/ZyCromerZ/spectrum/raw/master/vip.rc
        cp -af vip.rc init.spectrum.rc
        rm -rf vip.rc
    fi
    cp -af anykernel-real.sh anykernel.sh
    sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME by ZyCromerZ@$GetCommit/g" anykernel.sh
        if [ -e init.spectrum.rc ];then
            sed -i "s/setprop persist.spectrum.kernel.*/setprop persist.spectrum.kernel $KERNEL_NAME/g" init.spectrum.rc
        fi
    Type=""
    HzNya=""
    PassProteted="No"
    if [ ! -z "$1" ];then
        Type="$1"
        HzNya=${Type/"P"/""}
        HzNya=${HzNya/"Q"/""}
    fi
    if [ ! -z "$3" ];then
        zip -r "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetCommit.zip" --password "$3" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
        PassProteted="Yes"
    else
        zip -r "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetCommit.zip" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
    fi
    if [ "$2" == "sf" ];then
        pushSF "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetCommit.zip" "$KERNEL_NAME" "$HzNya" "$PassProteted"
    else
        push "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetCommit.zip" "$KERNEL_NAME" "$HzNya" "$PassProteted"
    fi
    rm -rf "$Type[$TANGGAL]$ZIP_KERNEL_VERSION-$KERNEL_NAME-$GetCommit.zip"
    cd .. 
}
buildKernel() {
    if [ ! -z "$3" ];then
        chat_id="$3"
    fi
    START=$(date +"%s")
    if [ ! -z "$1" ];then
        if [[ "$1" == *"65Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/53611dfaddbca9e6c7ef52e558cf98a483bdcd84.patch | git am -3
        fi
        if [[ "$1" == *"66Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/0438496fb3e84724afc5e239d6b56c7937a74fbc.patch | git am -3
        fi
        if [[ "$1" == *"67Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/1e89a8453eb9a23f25e405510bcf2055522f2c94.patch | git am -3
        fi
        if [[ "$1" == *"68Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/37147e430b15a01d56484a8d550a02a298fdbadf.patch | git am -3
        fi
        if [[ "$1" == *"69Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/31c2d552b7090e925a3216b0fb2ba9767edcbc16.patch | git am -3
        fi
        if [[ "$1" == *"71Hz"* ]];then
            git reset $HeadCommit --hard
            curl https://github.com/ZyCromerZ/android_kernel_asus_X01BD/commit/6d72976e8f8e23c418841110fe06a3fe8b6ab5e0.patch | git am -3
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
    zipping "$1" "$2" "$4"
}

customInfo() {
    if [ ! -z "$1" ];then
        SendTo="$1"
    else
        SendTo="$chat_id"
    fi
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$SendTo" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="$2" >/dev/null
}
echo "include sender.sh success"