
build_runner:
	docker compose build runner

extract_installer:
	mkdir -p ./extracted
	tar -xf FPGA*.tar -C ./extracted --strip-components=1

install_vitis:
	docker compose up --abort-on-container-exit installer

run:
	docker compose up vitis

export_volume:
	docker compose up --abort-on-container-exit export

import_volume:
	docker compose up --abort-on-container-exit import
