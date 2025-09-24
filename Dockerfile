# Dockerfile: minimal Vivado runner base
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# ----- system deps -----
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates locales wget curl gnupg2 software-properties-common \
      build-essential make gcc g++ libstdc++6 libtinfo5 libncurses5 \
      python3 python3-pip vim nano less file git git-lfs openssh-client && \
    rm -rf /var/lib/apt/lists/*

# --- X11 + legacy/USB support ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libx11-6 libxext6 libxrender1 libxtst6 libxi6 libxft2 libgtk2.0-0 \
      libusb-1.0-0 fxload udev usbutils \
      libc6-i386 lib32stdc++6 lib32gcc-s1 \
      xorg xauth x11-apps xvfb fontconfig xfonts-base xfonts-75dpi && \
    rm -rf /var/lib/apt/lists/*

# --- Vitis GUI dependencies (Eclipse/GTK3 based) ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libgtk-3-0 libnss3 libxss1 libasound2 libgbm1 \
      libcanberra-gtk-module libcanberra-gtk3-module \
      xdg-utils libgdk-pixbuf2.0-0 libxdamage1 libxcursor1 \
      dbus-x11 libx11-xcb1 libxcb1 libxfixes3 libdrm2 \
      libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 \
      libpango-1.0-0 libpangocairo-1.0-0 libcairo2 \
      libcups2 libpulse0 libsecret-1-0 \
      libwebkit2gtk-4.0-37 \
    && rm -rf /var/lib/apt/lists/*

# --- From installLibs.sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libc6-dev-i386 net-tools graphviz make unzip zip g++ \
      libtinfo5 xvfb git libncursesw5 libnss3-dev libgdk-pixbuf2.0-dev \
      libgtk-3-dev libxss-dev libasound2 fdisk && \
    rm -rf /var/lib/apt/lists/*

# ----- Mac x11 forwarding -----
RUN apt-get update && apt-get install -y x11-utils netcat-openbsd

# Locale
RUN locale-gen en_US.UTF-8

# ----- udev rules for Digilent/Xilinx -----
RUN bash -lc 'cat > /etc/udev/rules.d/52-xilinx-digilent-usb.rules << "EOF"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1443\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", ATTR{idProduct}==\"6010\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", ATTR{idProduct}==\"6014\", MODE=\"0666\"\n\
EOF\nudevadm control --reload-rules || true'

RUN printf 'force_color_prompt=yes\n' >> /etc/bash.bashrc && \
    printf 'if [ -t 1 ]; then PS1="\\[\\e[1;32m\\]\\u@\\h \\[\\e[1;34m\\]\\W\\[\\e[0m\\]\\$ "; fi\n' >> /etc/bash.bashrc

RUN bash -lc 'echo ". /opt/Xilinx/Vitis/2024.2/settings64.sh" > /etc/profile.d/xilinx.sh'
RUN echo 'source /opt/Xilinx/Vitis/2024.2/settings64.sh' >> /etc/bash.bashrc

# Pass these at build-time or let them default to 1000:1000
ARG USER=dev
ARG UID=1000
ARG GID=1000

RUN set -eux; \
    # If a group with GID exists, reuse it; otherwise create one named ${USER}
    if getent group "${GID}" >/dev/null; then \
        echo "Using existing group $(getent group "${GID}" | cut -d: -f1) (GID=${GID})"; \
    else \
        groupadd -g "${GID}" "${USER}"; \
    fi; \
    # Create the user if missing; otherwise align its IDs
    if id -u "${USER}" >/dev/null 2>&1; then \
        usermod -u "${UID}" -g "${GID}" "${USER}"; \
    else \
        useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USER}"; \
    fi; \
    # Populate home and set ownership
    cp -rT /etc/skel "/home/${USER}"; \
    chown -R "${UID}:${GID}" "/home/${USER}"

USER ${USER}
ENV USER=${USER} HOME=/home/${USER}
WORKDIR /vitis_work

# Login shell by default so .bashrc/.bash_profile load; keeps container interactive-friendly
CMD ["/bin/bash","-l"]
