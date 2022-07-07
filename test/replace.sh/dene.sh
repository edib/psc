#!/bin/bash

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/private/common.sh



file_should_contain /opt/psc/test/replace.sh/file.txt/opt/psc/test/replace.sh/iceri.txt "###BAS" "###SON"   