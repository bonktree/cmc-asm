#
# This script assumes that:
# $FN is set to the assembler source filename (without extension)
# $TMP_CONF is a synthesized dosbox.conf file
# $DOSBOX_OUTPUT tells DOSBox where to dump stdout 
# $DOSBOX_EXIT tells DOSBox if it needs to automatically close itself

# Cleaning binaries
[ -f $FN.exe ] && rm $FN.exe
[ -f $FN.obj ] && rm $FN.obj

ML="c:\\masm4\\masm.exe"
LINKER="c:\\masm4\\link.exe"

#ML_CL="$ML /nologo /c /Fo$FN.obj /Fl$FN.lst /W3 /X /Zm /Zi /Ic:\ $FN.asm"
ML_CL="$ML /c /Ic:\ $FN,$FN,$FN;"
#LINKER_CL="$LINKER /nologo $FN.obj+$MASMDOSPATH\\ioproc.obj,$FN.exe\;"
LINKER_CL="$LINKER $FN+c:\\ioproc.obj,$FN;"

dosbox -conf $TMP_CONF \
    -c "u:" \
    -c "$ML_CL" \
    -c "$LINKER_CL" \
    $DOSBOX_EXIT $DOSBOX_OUTPUT
if [ ! -f $FN.obj ] ; then
    echo "Compilation error."
    rm -f $TMP_CONF
    exit 10
else
    echo "Compilation complete."
    if [ ! -f $FN.exe ] ; then
        echo "Linking error."
        rm -f $TMP_CONF
        exit 11
    else
        echo "Linking complete."
    fi
fi


