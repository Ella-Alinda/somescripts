#!/usr/bin/env bash

# ======== Android Build OS Set ======== #
ANDROID_OS="LineageOS 20.0" # Android OS
ANDROID_OS_NAME=lineage
BUILD_MODE= # user/userdebug/eng
ANDROID_OS_GIT_URL="a" # Android Git Repo URL
ANDROID_OS_BRANCH=""
DEVICE_MANUFACTURERS=xiaomi
DEVICE_NAME=chopin
X2_THREAD=y # Y/n Are X2 operations performed on threads?

# ======== Android Device File ======== #
USE_PREBUILD=y
GIT_DEVICE_URL=
GIT_DEVICE_URL_BRANCH=
GIT_VENDOR_URL=
GIT_VENDOR_URL_BRANCH=
GIT_PREBUILD_URL=
GIT_PREBUILD_URL_BRANCH=

# ======== Telegream Sent message ======== #
OPEN_TG_MASSAGE=n
TGBOT_API="a" # Telegream API
GROUP_OR_PERSON="a" # Send information to people or groups
    
# https://github.com/spiritLHLS/ecs/blob/main/ecs.sh#L54C1-L62C5
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')" "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(uname -s)") 
SYS="${CMD[0]}"

if [[ $X2_THREAD == y ]]; then
    NPROC=$(nproc --all)
    THREAD=$((NPROC * 2))
elif [[ $X2_THREAD == n ]]; then
    THREAD=$(nproc --all)
else 
    echo "You need set X2_THREAD!"
fi

function OSenvset() {
    if [[ -e "/usr/bin/apt-get" ]]; then
        sudo apt-get install -y aria2 arj brotli cabextract cmake device-tree-compiler gcc \
        g++ git liblz4-tool liblzma-dev libtinyxml2-dev lz4 mpack openjdk-11-jdk \
        p7zip-full p7zip-rar python3 python3-pip rar sharutils unace unrar unzip \
        uudeview xz-utils zip zlib1g-dev wget neofetch git-lfs htop python3 ca-certificates \
        tmux squashfs-tools xsltproc schedtool rsync pngcrush lzop libxml2-utils \
        libxml2 libssl-dev libsdl1.2-dev libncurses5-dev libncurses5 libelf-dev \
        lib32z1-dev lib32readline-dev lib32ncurses5-dev imagemagick gperf gnupg \
        gcc-multilib g++-multilib flex curl ccache build-essential bison bc
    elif [[ -e "/usr/bin/pacman" ]]; then
        sudo pacman -Syu --needed --noconfirm base-devel wget curl git-lfs android-tools aria2 arj \
        brotli cabextract cmake dtc gcc git lz4 xz tinyxml2 p7zip python-pip \
        unrar sharutils unace zip unzip uudeview zip
    elif [[ -e "/usr/bin/yum" ]]; then
        sudo yum install --refresh android-tools aria2 arj brotli \
        cabextract cmake dtc gcc git lz4 xz tinyxml2 p7zip python-pip \
        unrar sharutils unace zip unzip uudeview zip curl wget git-lfs
    fi

    if [[ $OPEN_TG_MASSAGE == y ]]; then
        curl https://api.telegram.org/$TGBOT_API/sendMessage?chat_id=$GROUP_OR_PERSON&text= \
        ------ Build Start ------ \n BuildOS: $ANDROID_OS_NAME
}

function getOSSource() {
    repo init -u $ANDROID_OS_GIT_URL -b $ANDROID_OS_BRANCH --git-lfs --depth=1
    repo sync -j$THREAD
}

function Getdevice() {
    git clone -b $GIT_DEVICE_URL_BRANCH $GIT_DEVICE_URL device/$DEVICE_MANUFACTURER/$DEVICE_NAME
    git clone -b $GIT_VENDOR_URL_BRANCH $GIT_VENDOR_URL vendor/$DEVICE_MANUFACTURER/$DEVICE_NAME
    if [[ $USE_PREBUILD == y ]]; then
        git clone -b $GIT_PREBUILD_URL_BRANCH $GIT_PREBUILD_URL device/$DEVICE_MANUFACTURER/$DEVICE_NAME-prebuild
    fi
}

function BuildStart() {
    . build/envsetup.sh
    lunch $ANDROID_OS_NAME-$DEVICE_NAME_$BUILD_MODE
    mka bacon -j$THREAD
}
# ======= Start ======= #
# OSenvset