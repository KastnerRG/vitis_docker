IMAGE     := vivado-runner:22.04-$(USER)
NAME      := vitis-$(USER)
VOL       := vitis-2024.2
EXTRACTED := $(PWD)/extracted
ARCHIVE   := $(firstword $(wildcard *.tar))
PLATFORM  := linux/amd64
IMPORTDIR := ./

.PHONY: install start enter kill export import volume extract image container

image:
	docker build \
	  --platform $(PLATFORM) \
	  --build-arg USER=$$USER \
	  --build-arg UID=$$(id -u) \
	  --build-arg GID=$$(id -g) \
	  -t $(IMAGE) .

volume:
	- docker volume create $(VOL) >/dev/null

extract: $(ARCHIVE)
	mkdir -p $(EXTRACTED)
	tar -xf "$<" -C $(EXTRACTED) --strip-components=1
	chmod +x $(EXTRACTED)/xsetup

# -------- Actual Tasks to run --------


# One-time offline install
install: image volume
	docker run --rm \
	  --platform $(PLATFORM) \
	  --user 0:0 \
	  -v $(VOL):/opt/Xilinx \
	  -v $(EXTRACTED):/tmp/xlnx:ro \
	  $(IMAGE) \
	  bash -lc 'set -e; \
	    test -x /tmp/xlnx/xsetup; \
	    /tmp/xlnx/xsetup \
	      --agree 3rdPartyEULA,XilinxEULA \
	      --batch Install \
	      --edition "Vitis Unified Software Platform" \
	      --product Vitis \
	      --location /opt/Xilinx'


# Start a long-lived per-user container (GUI-ready)
start: image volume
	docker run -d \
	  --platform $(PLATFORM) \
	  --name $(NAME) \
	  --hostname vitis \
	  --user $$(id -u):$$(id -g) \
	  --privileged --device /dev/bus/usb \
	  --shm-size=2g \
	  --ipc=host \
	  -e DISPLAY=host.docker.internal:0 \
	  -e QT_X11_NO_MITSHM=1 \
  	  -e _JAVA_AWT_WM_NONREPARENTING=1 \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  -v $(VOL):/opt/Xilinx \
	  -v $$PWD/vitis_work:/vitis_work \
	  -w /vitis_work \
	  $(IMAGE) \
	  bash -lc 'tail -f /dev/null'


# Enter the container
enter:
	docker exec -it $(NAME) bash -l


# Stop/remove the container (volume remains)
kill:
	- docker kill $(NAME)
	- docker rm $(NAME)


# Export the volume as a portable tarball
export:
	docker run --rm --platform $(PLATFORM) --entrypoint /bin/sh \
	  -v $(VOL):/data:ro \
	  -v $$PWD:/backup \
	  $(IMAGE) \
	  -c 'tar -C /data -cf - . | gzip -c > /backup/$(VOL).tgz; ls -lh /backup/$(VOL).tgz'


# Import into the volume from local tarball (depends on file existing)
import: ${IMPORTDIR}/$(VOL).tgz volume
	docker run --rm --platform $(PLATFORM) --user 0:0 --entrypoint /bin/sh \
	  -v $(VOL):/data \
	  -v ${IMPORTDIR}:/backup \
	  $(IMAGE) \
	  -c 'cd /data && tar xzf /backup/$(VOL).tgz; du -sh /data'
