# Use a vetted Yocto-compatible base image
# crops/poky is the standard for running Yocto in Docker
FROM crops/poky:ubuntu-22.04

USER root

# Install additional dependencies required for SSH and general build tools
RUN apt-get update && apt-get install -y \
    git \
    ssh \
    scp \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /home/pokyuser

# Clone the repository
RUN git clone https://github.com/samueldovi/build_dts_libs_debix.git

# Fix permissions to ensure the pokyuser can execute scripts
RUN chown -R pokyuser:pokyuser /home/pokyuser/build_dts_libs_debix

# Switch back to the non-root user (Yocto/BitBake should not run as root)
USER pokyuser

# Set the working directory to the repo
WORKDIR /home/pokyuser/build_dts_libs_debix

# Ensure the install script is executable
RUN chmod +x install.sh

# Automatically run the install script when the container starts
ENTRYPOINT ["/bin/bash", "./install.sh"]