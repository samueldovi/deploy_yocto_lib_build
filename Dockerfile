# =============================================================================
# Yocto + Debix build environment
# Builds the install.sh setup from samueldovi/build_dts_libs_debix inside a
# crops/poky container.  The deploy scripts (deploy_libs.sh / deploy_dts.sh)
# SSH/SCP to the target EVK, so the container MUST be started with
# --network=host (see docker-compose.yml or run.sh).
# =============================================================================

FROM crops/poky:ubuntu-22.04

# ---------------------------------------------------------------------------
# 1. Root: install extra system packages that crops/poky doesn't include
# ---------------------------------------------------------------------------
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        # SSH / deploy
        openssh-client \
        scp \
        # General build deps listed in the repo's README
        gawk \
        wget \
        git \
        diffstat \
        unzip \
        texinfo \
        gcc \
        build-essential \
        chrpath \
        socat \
        cpio \
        python3 \
        python3-pip \
        python3-pexpect \
        xz-utils \
        debianutils \
        iputils-ping \
        python3-git \
        python3-jinja2 \
        libegl1-mesa \
        libsdl1.2-dev \
        xterm \
        python3-subunit \
        mesa-common-dev \
        zstd \
        liblz4-tool \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 2. Root: clone the repo into pokyuser's home while still root so we can
#    set ownership atomically.  Avoids a chown on a second layer.
# ---------------------------------------------------------------------------
RUN git clone --depth=1 \
        https://github.com/samueldovi/build_dts_libs_debix.git \
        /home/pokyuser/build_dts_libs_debix \
    && chown -R pokyuser:pokyuser /home/pokyuser/build_dts_libs_debix \
    && chmod +x /home/pokyuser/build_dts_libs_debix/install.sh

# ---------------------------------------------------------------------------
# 3. Root: create the .ssh directory for the pokyuser so SSH keys can be
#    bind-mounted at runtime without permission errors.
# ---------------------------------------------------------------------------
RUN mkdir -p /home/pokyuser/.ssh \
    && chown pokyuser:pokyuser /home/pokyuser/.ssh \
    && chmod 700                /home/pokyuser/.ssh

# ---------------------------------------------------------------------------
# 4. Switch to pokyuser — everything below and at runtime runs as this user.
#    Yocto / BitBake will refuse to run as root.
# ---------------------------------------------------------------------------
USER pokyuser
WORKDIR /home/pokyuser/build_dts_libs_debix

# ---------------------------------------------------------------------------
# 5. ENTRYPOINT — sources install.sh (important: it sets env vars that the
#    deploy scripts depend on, so it MUST be sourced, not executed).
#    After sourcing, drop into an interactive shell so the user can run
#    deploy_libs.sh / deploy_dts.sh manually, OR pass a command as CMD.
#
#    Usage examples:
#      docker run ... <image>                          → interactive shell
#      docker run ... <image> ./deploy_libs.sh opencv  → run one deploy directly
# ---------------------------------------------------------------------------
ENTRYPOINT ["/bin/bash", "-c", \
    "source ./install.sh && exec \"$@\"", \
    "--"]

# Default CMD: drop into bash so the user can work interactively
CMD ["bash"]