# Docker setup for AMD Vitis

1. Vivado Installation (only once in your entire system)

- If you have an exported `docker volume` with vivado installation, named `$(VOL).tgz`, you can simply import it:

```bash
make import
```

- If you wish to create such a volume by install vivado from scratch, do the following:
  - Download the Offline Vivado Installer (130 GB) named _AMD Unified Installer for FPGAs & Adaptive SoCs 2024.2.2: SFD All OS installer Single-File Download_ from [AMD website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2024-2.html)
  - Install it on a docker volume named `$(VOL)` with

```bash
make install
```

- You can export this volume with docker installation to provide it to be imported in other systems:

```bash
make export
```

2. Build the user-specific image and start the user-specific container:

```bash
make image
make start
```

3. Enter the user-specific container

```bash
make enter
```

4. Kill the user-specific container

```bash
make kill
```