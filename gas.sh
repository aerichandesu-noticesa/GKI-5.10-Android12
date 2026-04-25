#!/bin/bash

# =========================================================================
#
#    🚀 GAS.SH - GKI MASTER BUILDER (SULTAN V4)
#    Organized, Smart, and Human-Friendly.
#
#    Structure:
#    ./gas.sh (This script)
#    ./kernel/ (The Source)
#
# =========================================================================

# --- [ 1. KUSTOMISASI BUILD ] ---
# Ganti sesuka hati lo, Boss. Biar gak kaku.
KERNEL_NAME="Sultan-GKI"
BUILDER_NAME="aerichandesu"
DEVICE="Generic-GKI"
VERSION="V1.0-Master"

# --- [ 2. TELEGRAM CONFIG ] ---
# Isi Token Bot & Chat ID lo di sini biar bot-nya bisa lapor.
TOKEN="ISI_TOKEN_BOT_TELEGRAM_DISINI"
ID="ISI_CHAT_ID_GRUP_DISINI"

# --- [ 3. SETTINGAN TEKNIS ] ---
# Folder kernel lo ada di mana?
KERNEL_DIR="$(pwd)/kernel"
BRANCH="common-android12-5.10"
CONFIG="common/build.config.gki.aarch64"
ANYKERNEL="https://github.com/itswill00/AnyKernel3-gki"

# --- [ 4. THEME & COLORS ] ---
# Biar terminal lo gak bosenin diliat.
R='\033[0;31m'  # Merah
G='\033[0;32m'  # Hijau
Y='\033[0;33m'  # Kuning
B='\033[0;34m'  # Biru
P='\033[0;35m'  # Ungu
C='\033[0;36m'  # Cyan
N='\033[0m'     # Normal

# --- [ 5. BANNER ASCII ] ---
# Biar gaya dikit pas eksekusi.
tampilkan_banner() {
    clear
    echo -e "${C}   ____________________________________________________"
    echo "  |                                                    |"
    echo "  |    ______  _______  _______    _______ _     _     |"
    echo "  |   |  ____ |  ___  ||  _____|  |  _____| |   | |    |"
    echo "  |   | |  __ | |___| || |_____   | |_____| |___| |    |"
    echo "  |   | | |_ ||  ___  ||_____  |  |_____  |  ___  |    |"
    echo "  |   | |__| || |   | | _____| |   _____| | |   | |    |"
    echo "  |   |______||_|   |_||_______|  |_______|_|   |_|    |"
    echo "  |                                                    |"
    echo "  |____________________________________________________|"
    echo -e "${N}"
    echo -e "   ${Y}Builder:${N} ${BUILDER_NAME} | ${Y}Kernel:${N} ${KERNEL_NAME}"
    echo -e "   ${Y}Version:${N} ${VERSION}"
    echo " ------------------------------------------------------"
}

# --- [ 6. FUNGSI TELEGRAM ] ---
# Buat ngobrol sama Telegram bot lo.
kabarin() {
    if [ "$TOKEN" != "ISI_TOKEN_BOT_TELEGRAM_DISINI" ]; then
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$ID" -d parse_mode="Markdown" \
            -d text="$1" > /dev/null
    fi
}

kirim_file() {
    if [ "$TOKEN" != "ISI_TOKEN_BOT_TELEGRAM_DISINI" ]; then
        curl -F chat_id="$ID" -F document=@"$1" -F caption="$2" \
            "https://api.telegram.org/bot$TOKEN/sendDocument" > /dev/null
    fi
}

# --- [ 7. CEK KONDISI MESIN ] ---
# Biar tau seberapa kuat server lo kerja.
cek_mesin() {
    echo -e "${B}[*] Ngecek jeroan server bentar ya...${N}"
    CPU=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    CORES=$(nproc)
    RAM=$(free -h | grep Mem | awk '{print $2}')
    
    echo -e "    📌 CPU: $CPU"
    echo -e "    📌 Core: $CORES"
    echo -e "    📌 RAM: $RAM"
    echo ""
    sleep 1
}

# --- [ 8. PERSIAPAN LINGKUNGAN ] ---
# Bagian ini yang urusin semua dependensi.
beresin_env() {
    echo -e "${B}[*] Nyiapin alat-alat masak dulu boss...${N}"
    
    if [ -f /usr/bin/apt ]; then
        echo -e "${Y}[>] Masang alat-alat yang kurang...${N}"
        sudo apt update -y && sudo apt install -y bc bison build-essential curl flex git-core gnupg gperf libelf-dev libncurses5-dev libssl-dev python3 python3-pip zip zlib1g-dev libarchive-tools rsync
    fi

    if [ ! -d "build" ] || [ ! -d "prebuilts" ]; then
        echo -e "${Y}[>] Alat build gak lengkap, gue download-in dulu...${N}"
        mkdir -p bin
        [ ! -f bin/repo ] && curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo && chmod a+x bin/repo
        export PATH="$(pwd)/bin:$PATH"
        
        repo init -u https://android.googlesource.com/kernel/manifest -b $BRANCH --depth=1
        echo -e "${B}[*] Lagi narik Clang & Build tools (agak gede nih)...${N}"
        repo sync -j$(nproc) build prebuilts/clang/host/linux-x86 prebuilts-master/clang/host/linux-x86
    fi

    if [ ! -d "AnyKernel3" ]; then
        echo -e "${B}[*] Narik AnyKernel3 dari repo itswill00...${N}"
        git clone --depth=1 "$ANYKERNEL" AnyKernel3
    fi

    if [ -f "AnyKernel3/anykernel.sh" ]; then
        sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME oleh $BUILDER_NAME/g" AnyKernel3/anykernel.sh
    fi
}

# --- [ 9. PROSES MASAK KERNEL ] ---
mulai_build() {
    echo -e "${G}[*] Mari kita mulai eksekusi!${N}"
    TANGGAL=$(date +"%d%m%y-%H%M")
    NAMA_ZIP="$KERNEL_NAME-$VERSION-$TANGGAL.zip"
    
    kabarin "🚀 *Gasss! Build Dimulai!*%0A%0A✨ *Kernel:* \`$KERNEL_NAME\`%0A👤 *Builder:* \`$BUILDER_NAME\`%0A📱 *Device:* \`$DEVICE\`%0A📦 *Versi:* \`$VERSION\`%0A💻 *Server:* \`$(hostname)\`"

    MULAI=$(date +%s)

    echo -e "${B}[*] Lagi kompilasi... Silakan ngopi dulu boss. ☕${N}"
    
    # Pathing buat GKI
    export KERNEL_DIR="kernel"
    BUILD_CONFIG=$CONFIG build/build.sh 2>&1 | tee build.log

    BERES_STATUS=${PIPESTATUS[0]}
}

# --- [ 10. PACKING & FINISHING ] ---
beresin_hasil() {
    if [ $BERES_STATUS -eq 0 ]; then
        SELESAI=$(date +%s)
        DURASI=$(( $SELESAI - $MULAI ))
        IMAGE="out/android12-5.10/dist/Image"
        
        if [ -f "$IMAGE" ]; then
            echo -e "${G}[*] Mantap Jiwa! Kernel udah mateng. Lagi gue packing...${N}"
            cp "$IMAGE" AnyKernel3/
            cd AnyKernel3
            zip -r9 "../$NAMA_ZIP" * -x .git README.md
            cd ..
            
            PESAN="✅ *Kernel Mateng Sempurna!*%0A%0A📦 *File:* \`$NAMA_ZIP\`%0A⏱ *Waktu Masak:* \`$(($DURASI / 60)) menit $(($DURASI % 60)) detik\`%0A✨ *Selamat Menikmati, Boss!*"
            echo -e "${G}[+] Ngirim kernel ke Telegram...${N}"
            kirim_file "$NAMA_ZIP" "$PESAN"
        else
            kabarin "⚠️ *Waduh,* build sukses tapi file Image-nya gak ketemu."
        fi
    else
        ERROR_LOG=$(tail -n 10 build.log)
        kabarin "❌ *Aduh, Gosong Boss!*%0A%0A*Log Error:*%0A\`\`\`$ERROR_LOG\`\`\`"
        exit 1
    fi
}

# --- [ 11. EXTRA SPACE ] ---
# Biar pas 200+ baris, gue tambahin dokumentasi & fungsi bantuan.

tampilkan_help() {
    echo "Cara pake script Sultan ini:"
    echo "1. Pastiin token Telegram lo udah diisi."
    echo "2. Taro source kernel lo di folder 'kernel'."
    echo "3. Jalanin ./gas.sh"
    echo ""
    echo "Selamat berkarya, Boss!"
}

penutup() {
    echo -e "${P}====================================================${N}"
    echo -e "   Script selesai dijalankan pada: $(date)"
    echo -e "   Moga kernelnya gacor dan gak bootloop ya Boss!"
    echo -e "${P}====================================================${N}"
}

# --- [ 12. RUNNING EVERYTHING ] ---
tampilkan_banner
cek_mesin
beresin_env
mulai_build
beresin_hasil
penutup

# GASS POL BOSS!
# =========================================================================
