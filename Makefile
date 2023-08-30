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
	python-cssmin < ${INPUTDIR}/style.css > ${OUTPUTDIR}/style.css
	htmlmin ${INPUTDIR}/index.html \
		${OUTPUTDIR}/index.html
	htmlmin ${INPUTDIR}/404.html \
		${OUTPUTDIR}/404.html

serve: 
	cd ${OUTPUTDIR} && python3 -m http.server ${HTTP_PORT}

rsync_upload:
	rsync -P -rvzc --include tags \
		--cvs-exclude --exclude=.*.swp\
		--delete --delete-excluded \
		"${OUTPUTDIR}/" \
		"${SSH_USER}"@"${SSH_HOST}":"${SSH_TARGET_DIR}"

rpm_deps:
	sudo dnf -y install python3-cssmin python3-htmlmin rsync
