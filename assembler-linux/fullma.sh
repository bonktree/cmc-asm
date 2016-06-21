#!/bin/sh
OWNPATH=$0
readlink $0 >/dev/null && OWNPATH=`readlink $0`
MASMPATH=`dirname $OWNPATH`
MASMDOSPATH=`echo $MASMPATH | sed 's/\\//\\\\/g'`
ML=$MASMPATH/ml.exe
LINK=$MASMPATH/link.exe

FN=`echo $1 | sed 's/\.asm$//g'`
if [ x$FN = x$1 ] ; then
	echo Should have .asm extension
	exit 40
fi
[ -f $FN.exe ] && rm $FN.exe
[ -f $FN.obj ] && rm $FN.obj

$ML /nologo /c /Fo$FN.obj /Fl$FN.lst /W3 /X /Zm /Zi /I$MASMPATH $FN.asm
if [ ! -f $FN.obj ] ; then
	echo Compilation error
	exit 10
fi
$LINK /nologo $FN.obj+$MASMDOSPATH\\ioproc.obj,$FN.exe\;
if [ ! -f $FN.exe ] ; then
	echo Linking error
	exit 10
fi

rm $FN.obj

cp $MASMPATH/runprog.bat $FN.bat
ln -s $MASMPATH/rkm.com
dosbox -c "u:\\$FN.bat u:\\$FN.exe" -conf $MASMPATH/dosbox2.conf \
-noconsole >/dev/null
rm -f $FN.bat
rm -f rkm.com
