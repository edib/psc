#!/bin/bash

export cls=$1
etcdhosts=$2

export hostname=$(hostname)

#java -cp /var/lib/psc/lib/psc-jar-with-dependencies.jar psc.config.ConfigUpdater $cls "http://pgtest-bt-1:2379,http://pgtest-pt-1:2379"

java -cp /var/lib/psc/lib/psc-jar-with-dependencies.jar psc.config.ConfigUpdater $cls $etcdhosts