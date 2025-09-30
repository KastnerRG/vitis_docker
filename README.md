# Docker setup for AMD Vitis

This docker works on Linux, Windows (WSL) and MacOS (including ARM). You need about 130GB space on your machine to run these tools.
To install from scratch, you temporarily need another 150GB somewhere, either in your machine, or in an external drive.  


### 0. To install on MacOS with ARM Chip, first install rosetta and docker

1. Install rosetta
  ```bash
  softwareupdate --install-rosetta
  ```
2. Install docker desktop by folllowing [these instructions](https://docs.docker.com/desktop/setup/install/mac-install/).

### 1. Full Vitis Installation (only once in your entire system)

- If you have an exported docker volume with vivado installation (*.tgz), you can simply import it:
  ```bash
  make import IMPORTDIR=path/to/dir
  ```

- To install Vitis from scratch, do the following:
  - Visit [AMD downloads page](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2024-2.html)
  - Download the Offline Installer (130 GB) named _"AMD Unified Installer for FPGAs & Adaptive SoCs 2024.2.2: SFD All OS installer Single-File Download"_
  - Extract the archive with the following command. If you don't have 300GB+ space in your machine, make sure `EXTRACTED` is in an external drive.
  ```bash
  make extract ARCHIVE=path/to/archive.tar EXTRACTED=path/to/extracted/dir
  ```
  - To save space, delete the `ARCHIVE` (.tar) after extraction. Install from the `EXTRACTED` using the following command
  ```bash
  make install EXTRACTED=path/to/extracted/dir
  ```

- (Optional) You can export this volume with installed files to be imported elsewhere. You will need an additional 120GB space if you choose to do this:
  ```bash
  make export
  ```

### 2. Build the image and start the container (both user-specific)

```bash
make start
```


### 3. Enter the user-specific container

```bash
make enter
```

From within this container, you can launch the tools with or without GUI.

```
vivado
vitis
vitis_hls
vitis_hls --classic
```

### 4. Kill the user-specific container

If anything goes wrong with the setup, with the following command you can simply stop the container and delete the runner image (without deleting your volume/installation), and do a `make start` again.

```bash
make kill
```

## Note about the User-Specific Image and the Container

Both the image and container are user-specific. They have your username attached. This is done for the following reasons:

1. For security reasons, we avoid running the container as root. But we also need to map a local folder `./vitis_work/` to a folder inside docker `/vitis_work/`, such that we can work on common files, without moving them back and forth. Since that directory is owned by the user (you), we need to match the user ID and group ID of the user when building the image. Having a common image for all users makes this difficult. Hence, we have per-user images.
2. We are launching a long-running container, since Vitis flow often takes hours, and we want to inspect the progress or any errors. Having one container per user (by username) avoids too many dangling containers.