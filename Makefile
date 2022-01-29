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
	@echo 'make serve [PORT=8000]       serve site at http://localhost:${PORT}'
	@echo 'make rsync_upload            upload the web site via rsync+ssh'
	@echo 'make rpm_deps                install software deps for Fedora'
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
	rsync -P -rvzc ${INPUTDIR}/ ${OUTPUTDIR}/
	yuicompressor --type css \
		-o ${OUTPUTDIR}/style.css \
		${INPUTDIR}/style.css
	htmlmin ${INPUTDIR}/index.html \
		${OUTPUTDIR}/index.html

serve: 
	cd ${OUTPUTDIR} && python3 -m http.server ${HTTP_PORT}

rsync_upload:
	rsync -P -rvzc --include tags --cvs-exclude --delete \
		"${INPUTDIR}/" \
		"${SSH_USER}"@"${SSH_HOST}":"${SSH_TARGET_DIR}"

rpm_deps:
	sudo dnf -y install yuicompressor python3-htmlmin rsync
