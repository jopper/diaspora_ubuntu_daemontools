# Daemontools for Diaspora\*, on Ubuntu

## Rationale

It seems that Diaspora\* is very picky about which services start first. This 
is my attempt to decouple from the monolithic ./script/server, which provides
no recourse for services which disappear. As best I can tell, the order of
services should be (mongo, nginx, redis), websocket, resque worker, and thin.
The websocket run script will wait for redis availability. The resque worker 
will wait for websocket, and thin will wait for mongo, nginx, redis, and
websocket availability.

If a script fails to connect to a dependent service 10 times, the run script
will exit and try again. This allows you to monitor `svstat` for short lived
processes. Each time the run script attempts to connect to a dependent service,
it will be echoed to STDOUT. This will allow you to monitor readproctitle for
errant services as well.

## Requirements

+ Ubuntu 10.10 (the only version I tested with)
+ Diaspora requirements
    + As of this writing, it includes
        + MTA (we run postfix)
        + Web server (we run nginx)
        + Redis
        + MongoDB
        + Debian packages: daemontools, daemontools-run

## Installation

1. Get your packages
    * `apt-get install postfix nginx redis-server mongo daemontools daemontools-run`
1. Stop init from starting your Diaspora\* services
    * `update-rc.d -f mongodb remove`
    * `update-rc.d -f nginx remove`
    * `update-rc.d -f redis-server remove`
1. Stop services
    * `service mongodb stop`
    * `service nginx stop`
    * `service redis-server stop`
1. Copy the etc skeleton into place
`cd [GIT_SRC_TREE]`
    * `find . -name .git -prune -o -print | cpio -dpm /`
    * `chmod a+x /etc/service/*/run /usr/local/bin/diaspora_svc.sh`
1. Edit the defaults if you need to
    * `$EDITOR /etc/default/diaspora`
1. Double check these scripts do what you expect! Our system currently runs three individual thins, over UNIX domain sockets. If your nginx isn't expecting that, you should probably update the thin run scripts.
    * `rm -rf /etc/service/thin_[12]`
    * `$EDITOR /etc/service/99thin_0/run`
1. Start the daemontools service scanner (should run automatically, during next boot)
    * `initctl start svscan`

## Customization

1. Adding new thin processes
    * `mkdir /etc/service/99thin_N`
    * `cp /etc/service/99thin_0/run /etc/service/99thin_N`
1. Set thin user and group in /etc/default/diaspora
    * `THIN_USER=nobody`
    * `THIN_GROUP=nogroup`
1. Set rails environment in /etc/default/diaspora
    * `RAILS_ENV=development`
1. Set diaspora root directory in /etc/default/diaspora
    * `DIASPORA_HOME=/usr/local/app/diaspora`
1. Globally define the max attempts scripts will try to connect to services
    * `DEFAULT_ATTEMPTS=10`
1. Modify a single service's max attempts it will try to connect to a service
    * in a run script: `wait_service -a N`

## diaspora_svc.sh usage

`/usr/local/bin/diaspora_svc.sh {start|stop|restart|status|startall|stopall|restartall|statusall}`

This script is by no means required, but there are some useful features to it.
It allows you to easily control diaspora related services (resque_worker,
redis, thin, and websocket) and everything else controlled by svscan.

+ *start* allows you to start diaspora related services in /etc/service
+ *startall* starts all services in /etc/service
+ *stop* allows you to stop diaspora related services in /etc/service
+ *stopall* stops all services in /etc/service
+ *restart* allows you to restart diaspora related services in /etc/service
+ *restartall* restarts all services in /etc/service
+ *status* allows you to see status for diaspora related services in /etc/service
+ *statusall* prints all services in /etc/service

