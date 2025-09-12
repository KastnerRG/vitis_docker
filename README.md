# Docker setup for AMD Vitis

Steps:

1. Download the Offline Vivado Installer (130 GB) named _AMD Unified Installer for FPGAs & Adaptive SoCs 2024.2.2: SFD All OS installer Single-File Download_ from [AMD website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2024-2.html)

2. Extract it to a directory named `extracted`

```bash
tar -xf FPGA*.tar -C ./extracted --strip-components=1
```

3. Build the runner container, and Install Vivado into a docker volume named `xilinx-2024.2`

```bash
docker compose build runner
docker compose up --abort-on-container-exit installer
```

4. Run the container with the volume mounted, and the location `./vitis_work/` mounted to `/vitis_work`

```bash
docker compose run --rm vitis
```