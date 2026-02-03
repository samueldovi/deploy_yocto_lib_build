# =============================================================================
# Yocto + Debix build environment
#
# Why ubuntu:22.04 and not crops/poky?
#   crops/poky does NOT have a static "pokyuser".  That user is created
#   dynamically at runtime by poky-entry.py based on the --workdir argument.
#   Using it as a plain FROM base and referencing pokyuser during build will
#   always fail with "invalid user".  ubuntu:22.04 + a manually created user
#   is the straightforward fix and is exactly what crops/poky does under the
#   hood anyway.
# =============================================================================

FROM ubuntu:22.04

# Avoid interactive prompts during package install
ARG DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# 1. Create the build user (uid 1000, same as crops/poky convention)
# ---------------------------------------------------------------------------
RUN useradd -m -s /bin/bash -u 1000 pokyuser

# ---------------------------------------------------------------------------
# 2. Install everything: build tools + SSH/SCP for deploy
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        # SSH / deploy
        openssh-client \
        scp \
        # Yocto / OE build deps (from the repo README)
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
        sudo \
        # Locale — BitBake hard-requires en_US.UTF-8, ubuntu:22.04 doesn't
        # ship it by default
        locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set the locale for all processes in the container
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ---------------------------------------------------------------------------
# 3. Clone the repo, set ownership, mark script executable — all in one layer
# ---------------------------------------------------------------------------
RUN git clone --depth=1 \
        https://github.com/samueldovi/build_dts_libs_debix.git \
        /home/pokyuser/build_dts_libs_debix \
    && chown -R pokyuser:pokyuser /home/pokyuser/build_dts_libs_debix \
    && chmod +x /home/pokyuser/build_dts_libs_debix/install.sh

# ---------------------------------------------------------------------------
# 4. Prepare .ssh directory for the bind-mounted deploy key
# ---------------------------------------------------------------------------
RUN mkdir -p /home/pokyuser/.ssh \
    && chown pokyuser:pokyuser /home/pokyuser/.ssh \
    && chmod 700               /home/pokyuser/.ssh

# ---------------------------------------------------------------------------
# 5. Drop to non-root for everything from here on (BitBake refuses root)
# ---------------------------------------------------------------------------
USER pokyuser
WORKDIR /home/pokyuser/build_dts_libs_debix

# ---------------------------------------------------------------------------
# 6. Entrypoint: source install.sh (sets env vars needed by deploy scripts),
#    then hand off to whatever CMD is passed.
#
#    Interactive:  docker compose run -it debix          -> bash shell
#    One-shot:     docker compose run debix ./deploy_libs.sh opencv
# ---------------------------------------------------------------------------
ENTRYPOINT ["/bin/bash", "-c", \
    "source ./install.sh && exec \"$@\"", \
    "--"]

CMD ["bash"]# =============================================================================
# Yocto + Debix build environment
#
# Why ubuntu:22.04 and not crops/poky?
#   crops/poky does NOT have a static "pokyuser".  That user is created
#   dynamically at runtime by poky-entry.py based on the --workdir argument.
#   Using it as a plain FROM base and referencing pokyuser during build will
#   always fail with "invalid user".  ubuntu:22.04 + a manually created user
#   is the straightforward fix and is exactly what crops/poky does under the
#   hood anyway.
# =============================================================================

FROM ubuntu:22.04

# Avoid interactive prompts during package install
ARG DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# 1. Create the build user (uid 1000, same as crops/poky convention)
# ---------------------------------------------------------------------------
RUN useradd -m -s /bin/bash -u 1000 pokyuser

# ---------------------------------------------------------------------------
# 2. Install everything: build tools + SSH/SCP for deploy
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        # SSH / deploy
        openssh-client \
        scp \
        # Yocto / OE build deps (from the repo README)
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
        sudo \
        # Locale — BitBake hard-requires en_US.UTF-8, ubuntu:22.04 doesn't
        # ship it by default
        locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set the locale for all processes in the container
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ---------------------------------------------------------------------------
# 3. Clone the repo, set ownership, mark script executable — all in one layer
# ---------------------------------------------------------------------------
RUN git clone --depth=1 \
        https://github.com/samueldovi/build_dts_libs_debix.git \
        /home/pokyuser/build_dts_libs_debix \
    && chown -R pokyuser:pokyuser /home/pokyuser/build_dts_libs_debix \
    && chmod +x /home/pokyuser/build_dts_libs_debix/install.sh

# ---------------------------------------------------------------------------
# 4. Prepare .ssh directory for the bind-mounted deploy key
# ---------------------------------------------------------------------------
RUN mkdir -p /home/pokyuser/.ssh \
    && chown pokyuser:pokyuser /home/pokyuser/.ssh \
    && chmod 700               /home/pokyuser/.ssh

# ---------------------------------------------------------------------------
# 5. Drop to non-root for everything from here on (BitBake refuses root)
# ---------------------------------------------------------------------------
USER pokyuser
WORKDIR /home/pokyuser/build_dts_libs_debix

# ---------------------------------------------------------------------------
# 6. Entrypoint: source install.sh (sets env vars needed by deploy scripts),
#    then hand off to whatever CMD is passed.
#
#    Interactive:  docker compose run -it debix          -> bash shell
#    One-shot:     docker compose run debix ./deploy_libs.sh opencv
# ---------------------------------------------------------------------------
ENTRYPOINT ["/bin/bash", "-c", \
    "source ./install.sh && exec \"$@\"", \
    "--"]

CMD ["bash"]