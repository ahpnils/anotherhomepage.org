BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output

SSH_HOST=vhost3.anotherhomepage.org
SSH_PORT=22
SSH_USER=ahp-org
SSH_CHROOT_TARGET_DIR=/public/

PORT ?= 0
ifneq ($(PORT), 0)
	HTTP_PORT += $(PORT)
else
	HTTP_PORT += 8001
endif

help:
	@echo 'Makefile for Another Home Page web site'
	@echo ' '
	@echo 'Usage:'
	@echo 'make clean                   remove stale files'
	@echo 'make html                    (re)generate the web site'
	@echo 'make publish                 generate using production settings'
	@echo 'make serve [PORT=8001]       serve site at http://localhost:8001'
	@echo 'make sshfs_upload            upload the web site via rsync+sshfs'
	@echo 'make rpm_deps                install software deps for Fedora'
	@echo 'make deb_deps                install software deps for Debian'
	@echo ' '

clean:
	rm -f *~ .*~
	rm -f */*~ */.*~
	[ ! -d "$(OUTPUTDIR)" ] || rm -rf "$(OUTPUTDIR)"

html:
	mkdir -p ${OUTPUTDIR}
	rsync -P -rvzc ${INPUTDIR}/ ${OUTPUTDIR}/

publish: html
	css-html-js-minify --overwrite ${OUTPUTDIR}/

serve: 
	cd ${OUTPUTDIR} && python3 -m http.server --protocol HTTP/1.1 --bind 127.0.0.1 ${HTTP_PORT}

bg_serve: 
	cd ${OUTPUTDIR} && python3 -m http.server --protocol HTTP/1.1 --bind 127.0.0.1 ${HTTP_PORT} &

sshfs_upload: publish
	mkdir -p $(BASEDIR)/sshfs
	sshfs -p ${SSH_PORT} "$(SSH_USER)@$(SSH_HOST):$(SSH_CHROOT_TARGET_DIR)" \
		$(BASEDIR)/sshfs
	rsync -P -rvzc --include tags --cvs-exclude --exclude=.*.swp\
		--delete --delete-excluded "$(OUTPUTDIR)"/ sshfs/
	fusermount -u $(BASEDIR)/sshfs

rpm_deps:
	sudo dnf --quiet -y install pipx rsync fuse fuse-sshfs
	pipx install css-html-js-minify

deb_deps:
	sudo DEBIAN_FRONTEND=noninteractive apt-get update
	# fusermount is provided by fuse3 package, a direct dependency of sshfs.
	sudo DEBIAN_FRONTEND=noninteractive apt-get \
		-q -y --no-install-recommends \
		install pipx rsync sshfs
	pipx install css-html-js-minify
