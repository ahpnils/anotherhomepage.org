INPUTDIR=./content
SSH_TARGET_DIR=/srv/www/anotherhomepage.org/public/
SSH_HOST=vhost3.anotherhomepage.org
SSH_USER=nils

clean:
	rm -f *~ .*~
	rm -f */*~ */.*~

rsync_upload:
	rsync -P -rvzc --include tags --cvs-exclude --delete "${INPUTDIR}/" "${SSH_USER}"@"${SSH_HOST}":"${SSH_TARGET_DIR}"
