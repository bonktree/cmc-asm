#!/bin/sh
# This script assumes that:
# $FN is set to the assembler source filename (without extension)
# $TMP_CONF is a synthesized dosbox.conf file
# $DOSBOX_OUTPUT_REDIRECTION tells DOSBox where to dump stdout 
# $DOSBOX_EXIT tells DOSBox if it needs to automatically close itself

[ -z $FN ] && FN="$1"
[ -z $FN ] && exit 40

# Cleaning binaries
if [ -z $MASM_ACTION ]; then
    [ -f $FN.exe ] && rm $FN.exe
    [ -f $FN.obj ] && rm $FN.obj
fi

