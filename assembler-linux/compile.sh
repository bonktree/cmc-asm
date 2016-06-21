#!/bin/sh

# Acquiring path to masm
readlink "$0" >/dev/null && MASM_ROOT=`readlink "$0"` || MASM_ROOT="$0"
MASM_ROOT=`realpath "$MASM_ROOT"`
MASM_PATH="$MASM_ROOT/masm"

readlink "$1" >/dev/null && FN=`readlink "$1"` || FN="$1"
FN=`basename $FN`
FN_BASE=`echo $FN | sed 's/\.asm$//g'`
[ "$FN_BASE.asm" = "$FN" ] || {
    echo "The source file must end with \`.asm\'"
    exit 40
}
FN_DIR=`dirname $FN`
cd $FN_DIR

TMPCONF=/tmp/${USER}-cmc-asm.dosbox.conf
cat $MASM_PATH/dosbox.conf | sed s/mount c: ---$/mount c: $MASM_PATH/ > /tmp/${USER}-cmc-asm.dosbox.conf

ML=c:\\ml.exe
LINKER=c:\\link.exe

# Cleaning
[ -f $FN.exe ] && rm $FN.exe
[ -f $FN.obj ] && rm $FN.obj

# Compiling
dosbox -c "$ML /nologo /c /Fo$FN.obj /Fl$FN.lst /W3 /X /Zm /Zi /I$MASMPATH $FN.asm" -conf $TMPCONF #>/dev/null
if [ ! -f $FN.obj ] ; then
    echo Compilation error.
    exit 10
elif echo Compilation complete.
fi

# Linking
dosbox -c "$LINKER /nologo u:/$FN.obj+ioproc.obj,$FN.exe\;" -conf $TMPCONF #>/dev/null
if [ ! -f $FN.exe ] ; then
    echo Linking error.
    exit 11
elif echo Linking complete.
fi


