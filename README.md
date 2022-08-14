# Postgresql Scripted Cluster Automation (PSC)

How it works
* Patronili cluster'i kuruyor. Pgbackrest ve pgbouncer 'i da cluster'a dahil ediyor.
* switch-over ve fail-over'lar da pgbouncer ve backrest otomatik olarak guncelleniyor
* pgbouncer nodelarinda haproxy'de aktif
* Manuel mod'a gecip herseyi el ile de yapabiliyorsun :)
