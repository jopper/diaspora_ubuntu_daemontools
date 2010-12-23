#!/bin/bash
which=${1:?action}
cd /etc/service
diaspora=$(ls -1 | grep -vE '(mongo|nginx)')
case $which in
startall)
	svc -u *
;;
start)
	svc -u $diaspora
;;
stop)
	svc -d $diaspora
;;
stopall)
	svc -d *
;;
restart)
	svc -d $diaspora
	sleep 1
	svc -u $diaspora
;;
restartall)
	svc -d *
	sleep 1
	svc -u *
;;
status)
	svstat $diaspora
;;
statusall)
	svstat *
;;
*)
	echo "$which unknown, try {start|stop|restart|status|startall|stopall|restartall|statusall}" 1>&2
	exit 1
;;
esac

exit $?
