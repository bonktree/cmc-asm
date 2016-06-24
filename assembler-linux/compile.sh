#!/bin/sh

#####################################################################
# Error codes:
#
#
#
#
#
#####################################################################

[ $DEBUG -ge 0 ] && echo "Displaying debugging info."

# Acquiring path to masm package
MASM_ROOT=`realpath "$0"`
MASM_ROOT=`dirname "$MASM_ROOT"`
# sed wants to know $MASM_PATH
export MASM_PATH="$MASM_ROOT/masm"

# Acquiring info about the source
FN_FULL=`realpath $1`
if [ -z $FN_FULL ]; then exit 40; fi
FNE=`basename $FN_FULL`
FN=`echo $FNE | sed 's/\.asm$//g'`
[ "$FN.asm" = "$FNE" ] || {
    echo "The source file must end with \`.asm'"
    exit 41
}
FN_DIR=`dirname $FNE`
# we run dosbox in the source directory as current dir.
# to be able to easily mount it
cd $FN_DIR

TMP_CONF=/tmp/${USER}-cmc-asm.dosbox.conf
sed -e 's|-package-masm-dir-|'$MASM_PATH'|g' < "$MASM_PATH/dosbox.conf" > $TMP_CONF

ML=c:\\ml.exe
LINKER=c:\\link.exe

[ $DEBUG -ge 1 ] && {
    echo --- Debugging ---
    echo "root:" $MASM_ROOT
    echo "path to masm:" $MASM_PATH
    echo "filename to compile:" $FN_DIR/$FNE "($FN)"
}

if [ ! -s $TMP_CONF ];
then {
    echo "Empty dosbox.conf!"
    echo "Abort."
    exit 5
};
else [ $DEBUG -ge 2 ] && {
    echo "temporary config contents:"
    cat $TMP_CONF;
    echo "($TMP_CONF)"
};
fi

[ $DEBUG -ge 1 ] && {
    echo --- Starting DOSBox... ---
}

# Cleaning binaries
[ -f $FN.exe ] && rm $FN.exe
[ -f $FN.obj ] && rm $FN.obj

# Compiling
dosbox -c "u:
$ML /nologo /c /Fo$FN.obj /Fl$FN.lst /W3 /X /Zm /Zi /I$MASM_PATH $FN.asm" \
    -conf $TMP_CONF #>/dev/null
if [ ! -f $FN.obj ] ; then
    echo "Compilation error."
    rm -f $TMP_CONF
    exit 10
else
    echo "Compilation complete."
fi

# Linking
dosbox -c "u:
$LINKER /nologo u:/$FN.obj+ioproc.obj,$FN.exe\;" \
    -conf $TMP_CONF #>/dev/null
if [ ! -f $FN.exe ] ; then
    echo "Linking error."
    rm -f $TMP_CONF
    exit 11
else
    echo "Linking complete."
fi




rm -f $TMP_CONF

