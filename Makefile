IMAGE := vivado-runner:22.04-$(USER)
NAME  := vitis-$(USER)
VOL   := vivado_xilinx-2024.2
EXTRACTED := $(PWD)/extracted

.PHONY: build install start enter kill export import volume-check

# Build the runner image
build:
	docker build \
	  --build-arg USERNAME=$$USER \
	  --build-arg UID=$$(id -u) \
	  --build-arg GID=$$(id -g) \
	  -t $(IMAGE) .

# One-time offline install 
# Requires: ./extracted/xsetup present
install: volume-check
	docker run --rm \ 
		--user 0:0 \
	  -v $(VOL):/opt/Xilinx \
	  -v $(EXTRACTED):/tmp/xlnx:ro \
	  $(IMAGE) \
	  bash -lc 'set -e; \
	    test -x /tmp/xlnx/xsetup || { echo "xsetup not found in /tmp/xlnx"; exit 1; }; \
	    /tmp/xlnx/xsetup \
	      --agree 3rdPartyEULA,XilinxEULA \
	      --batch Install \
	      --edition "Vivado ML Standard" \
	      --product Vivado \
	      --location /opt/Xilinx'

# Start a long-lived per-user container (GUI-ready; stays up)
start:
	docker run -d \
	  --name $(NAME) \
	  --hostname vitis \
	  --user $$(id -u):$$(id -g) \
	  --privileged --device /dev/bus/usb \
	  -e DISPLAY=$$DISPLAY \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  -v $(VOL):/opt/Xilinx \
	  -v $$PWD/vitis_work:/vitis_work \
	  -w /vitis_work \
	  $(IMAGE) \
	  bash -lc 'tail -f /dev/null'

# Enter the running container
enter:
	docker exec -it $(NAME) bash -l

# Stop/remove the container (volume remains)
kill:
	- docker kill $(NAME)
	- docker rm $(NAME)

# Export/import the Vivado volume as a portable tarball
export:
	docker run --rm --entrypoint /bin/sh \
	  -v $(VOL):/data:ro \
	  -v $$PWD:/backup \
	  $(IMAGE) \
	  -c 'set -e; tar -C /data -cf - . | gzip -c > /backup/$(VOL).tgz; ls -lh /backup/$(VOL).tgz'

import:
	docker run --rm --entrypoint /bin/sh \
	  -v $(VOL):/data \
	  -v $$PWD:/backup \
	  $(IMAGE) \
	  -c 'set -e; test -s /backup/$(VOL).tgz || { echo "Archive missing/empty"; exit 1; }; cd /data; tar xzf /backup/$(VOL).tgz; du -sh /data'

# Create volume if it doesn't exist (safe to re-run)
volume-check:
	@if ! docker volume inspect $(VOL) >/dev/null 2>&1; then \
	  echo "Creating volume $(VOL)"; docker volume create $(VOL) >/dev/null; \
	fi
