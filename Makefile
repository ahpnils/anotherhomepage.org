INPUTDIR=./content
OUTPUTDIR=./output
SSH_TARGET_DIR=/srv/www/anotherhomepage.org/public/
SSH_HOST=vhost3.anotherhomepage.org
SSH_USER=nils

PORT ?= 0
ifneq ($(PORT), 0)
	HTTP_PORT += $(PORT)
else
	HTTP_PORT += 8000
endif

help:
	@echo 'Makefile for Another Home Page web site'
	@echo ' '
	@echo 'Usage:'
	@echo 'make clean                   remove stale files'
	@echo 'make html                    (re)generate the web site'
	@echo 'make publish                 generate using production settings'
	@echo 'make serve [PORT=8000]       serve site at http://localhost:${PORT}'
	@echo 'make rsync_upload            upload the web site via rsync+ssh'
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

publish:
	mkdir -p ${OUTPUTDIR}
	rsync -P -rvzc --exclude=.*.swp \
		${INPUTDIR}/ ${OUTPUTDIR}/
	css-html-js-minify --overwrite ${OUTPUTDIR}/

serve: 
	cd ${OUTPUTDIR} && python3 -m http.server ${HTTP_PORT}

rsync_upload:
	rsync -P -rvzc --include tags \
		--cvs-exclude --exclude=.*.swp\
		--delete --delete-excluded \
		"${OUTPUTDIR}/" \
		"${SSH_USER}"@"${SSH_HOST}":"${SSH_TARGET_DIR}"

rpm_deps:
	sudo dnf -y install pipx rsync
	pipx install css-html-js-minify

deb_deps:
	sudo DEBIAN_FRONTEND=noninteractive apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install pipx rsync
	pipx install css-html-js-minify
