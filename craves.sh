#!/usr/bin/env bash
set -euo pipefail

SYNC_ARGS="-c --force-sync --no-clone-bundle --no-tags --force-remove-dirty"

log() {
    echo
    echo "[$(date '+%H:%M:%S')] $*"
}

start_build_process() {

    if [ ! -d ".repo" ]; then
        log "Initializing Evolution-X..."
        repo init -u https://github.com/Evolution-X/manifest \
            -b cnb \
            --git-lfs \
            --depth=1
    fi

    log "Syncing sources..."
    /opt/crave/resync.sh
    repo sync ${SYNC_ARGS}

    log "Removing old device trees..."
    rm -rf device/xiaomi/peridot

    log "Cloning device tree..."
    git clone --depth=1 -b evo \
        https://github.com/ryznstk/pure.git \
        device/xiaomi/peridot

    log "Setting up build environment..."
    export NINJA_ARGS="-j16"
    export SISO_ARGS="-j16"
    . build/envsetup.sh

    log "Selecting lunch target..."
    lunch lineage_peridot-cp2a-user

    log "Starting Evolution-X build..."
    START=$(date +%s)

    m evolution 2>&1 | tee log.txt

    END=$(date +%s)
    log "Build completed in $((END - START)) seconds."
}

start_build_process
