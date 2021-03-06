#!/bin/bash
# add 2018-06-27 by Pascal Withopf, released under ASL 2.0
. $srcdir/diag.sh init
. $srcdir/diag.sh generate-conf
. $srcdir/diag.sh add-conf '
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514" ruleset="ruleset1")


template(name="outfmt" type="string" string="%PRI%,%syslogfacility-text%,%syslogseverity-text%,%timestamp:::date-rfc3164-buggyday%,%hostname%,%programname%,%syslogtag%,%msg%\n")

ruleset(name="ruleset1") {
	action(type="omfile" file="rsyslog.out.log"
	       template="outfmt")
}

'
. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -M "\"<38> Mar  7 19:06:53 example tag: testmessage (only date actually tested)\""
. $srcdir/diag.sh tcpflood -m1 -M "\"<38> Mar 17 19:06:53 example tag: testmessage (only date actually tested)\""
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown

echo '38,auth,info,Mar 07 19:06:53,example,tag,tag:, testmessage (only date actually tested)
38,auth,info,Mar 17 19:06:53,example,tag,tag:, testmessage (only date actually tested)' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  . $srcdir/diag.sh error-exit  1
fi;

. $srcdir/diag.sh exit
