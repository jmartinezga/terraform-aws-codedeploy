SHELL = /bin/sh

.PHONY: init plan apply destroy docs examples clean
.DEFAULT_GOAL := apply
.SILENT: clean

init: clean
	terraform init -upgrade
	terraform fmt
	tflint
	terraform validate

plan: init
	terraform plan
	$(MAKE) clean

apply: init
	terraform apply --auto-approve
	$(MAKE) clean

destroy: init
	terraform destroy
	$(MAKE) clean

docs:
	terraform-docs markdown . | tee README.md

precommit:
	pre-commit autoupdate
	pre-commit run -a ;	git add .
	$(MAKE) clean

infracost:
	infracost breakdown --path ./examples/*/ --format table
	$(MAKE) clean

scan:
	terrascan scan -i terraform -t aws -d . --non-recursive

install:
	./install_dependencies.sh

examples:
	ln -s ../../provider.tf provider.tf
	ln -s ../../common.tf common.tf
	ln -s ../../main.tf main.tf
	ln -s ../../outputs.tf outputs.tf
	ln -s ../../variables.tf variables.tf
	ln -s ../../version version

clean:
	@echo "Cleaning up..."
	find . -name ".infracost" -type d -print0 | xargs -0 /bin/rm -Rf
	find . -name ".terraform" -type d -print0 | xargs -0 /bin/rm -Rf
	find . -name ".terraform.*" -type f -print0 | xargs -0 /bin/rm -Rf
