#!/bin/sh
# This script assumes that:
# $FN is set to the assembler source filename (without extension)
# $TMP_CONF is a synthesized dosbox.conf file
# $DOSBOX_OUTPUT_REDIRECTION tells DOSBox where to dump stdout 
# $DOSBOX_EXIT tells DOSBox if it needs to automatically close itself

[ -z $FN ] && FN="$1"
[ -z $FN ] && exit 40

extn_list="exe crf lst obj tr"
extn_list_wcaps="$extn_list "`echo $extn_list | tr '[:lower:]' '[:upper:]'`

# Cleaning binaries
for extn in "$extn_list_wcaps"; do
    [ -f "$FN.$extn" ] && rm $FN.$extn
done

unset extn
unset extn_list
unset extn_list_wcaps

