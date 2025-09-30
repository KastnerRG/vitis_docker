# Docker setup for AMD Vitis

This docker works on Linux, Windows (WSL) and MacOS (including ARM). You need about 130GB space on your machine.
If you choose to install from scratch, you need another 150GB somewhere (in your machine, or in an external drive) for installation.  


### 0. To install on MacOS with ARM Chip, complete the following pre-requisites first

1. Install rosetta
```bash
softwareupdate --install-rosetta
```
2. Install docker desktop by folllowinf [these instructions](https://docs.docker.com/desktop/setup/install/mac-install/).

### 1. Full Vitis Installation (only once in your entire system)

- If you have an exported `docker volume` with vivado installation (*.tgz), you can simply import it:

```bash
make import IMPORTDIR=path/to/dir
```

- If you wish to create such a volume by installing Vitis from scratch, do the following:
  - Download the Offline Installer (130 GB) named _"AMD Unified Installer for FPGAs & Adaptive SoCs 2024.2.2: SFD All OS installer Single-File Download"_ from [AMD website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2024-2.html)
  - Extract it and install it on a docker volume

```bash
make extract ARCHIVE=path/to/archive.tar EXTRACTED=path/to/extracted/dir
make install EXTRACTED=path/to/extracted/dir
```

- You can export this volume with installed files to be imported elsewhere:

```bash
make export
```

### 2. Build the image and start the container (both user-specific)

```bash
make start
```

Note: both the image and container are user-specific. They have your username attached. This is done for the following reasons:

1. For security reasons, we avoid running the container as root. But we also need to map a local folder `./vitis_work/` to a folder inside docker `/vitis_work/`, such that we can work on common files, without moving them back and forth. Since that directory is owned by the user (you), we need to match the user ID and group ID of the user when building the image. Having a common image for all users makes this difficult. Hence, we have per-user images.
2. We are launching a long-running container, since Vitis flow often takes hours, and we want to inspect the progress or any errors. Having one container per user (by username) avoids too many dangling containers.


### 3. Enter the user-specific container

```bash
make enter
```

### 4. Kill the user-specific container

```bash
make kill
```