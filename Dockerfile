# Dockerfile: minimal Vivado runner base
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Install system dependencies Vivado runtime needs
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates locales wget curl gnupg2 software-properties-common \
      build-essential make gcc g++ libstdc++6 libtinfo5 libncurses5 \
      libx11-6 libxext6 libxrender1 libxtst6 libxi6 libxft2 libgtk2.0-0 \
      libusb-1.0-0 fxload udev usbutils \
      libc6-i386 lib32stdc++6 lib32gcc-s1 \
      xorg xauth x11-apps xvfb fontconfig xfonts-base xfonts-75dpi \
      python3 python3-pip vim nano less git && \
    rm -rf /var/lib/apt/lists/*

# Locale
RUN locale-gen en_US.UTF-8

# Optional: prompt color
ENV PS1="\e[0;33m[\u@\h \W]\$ \e[m "

# Udev rules for Digilent/Xilinx cables
RUN bash -lc 'cat > /etc/udev/rules.d/52-xilinx-digilent-usb.rules << "EOF"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1443\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", ATTR{idProduct}==\"6010\", MODE=\"0666\"\n\
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0403\", ATTR{idProduct}==\"6014\", MODE=\"0666\"\n\
EOF\nudevadm control --reload-rules || true'

RUN echo "source /opt/Xilinx/Vivado/2024.2/.settings64-Vivado.sh" > /root/.bashrc

WORKDIR /work
CMD ["/bin/bash"]
