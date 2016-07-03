#!/bin/sh
# This script assumes that:
# $FN is set to the assembler source filename (without extension)
# $TMP_CONF is a synthesized dosbox.conf file
# $DOSBOX_OUTPUT tells DOSBox where to dump stdout 
# $DOSBOX_EXIT tells DOSBox if it needs to automatically close itself

[ -z $FN ] && FN=$1
[ -z $FN ] && exit 40

sh -c "dosbox -conf ""\"$TMP_CONF\""" \
    -c 'c:\\runprog.bat $FN' \
    -c '""$DOSBOX_EXIT""' \
    ""$DOSBOX_OUTPUT"

