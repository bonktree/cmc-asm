#!/bin/sh
MASMDIR=`dirname $0`
[ $MASMDIR = . ] && MASMDIR=`pwd`

echo Этот скрипт установит все необходимое для запуска MASM под *nix.
echo MASM будет запускаться из $MASMDIR.
echo Если Вы хотите переместить его в другой каталог,
echo этот скрипт придется запустить заново.
echo Для продолжения нажмите Enter, для отмены - Ctrl-C.
read DUMMY

MISSING1=
dosbox --version >/dev/null 2>&1 || MISSING1=dosbox
MISSING2=
wine --version >/dev/null 2>&1 || MISSING2=wine
MISSING3=
geany --version >/dev/null 2>&1 || MISSING3=geany
if [ x$MISSING1$MISSING2$MISSING3 != x ] ; then
	echo Будут установлены дополнительные пакеты: $MISSING1 $MISSING2 $MISSING3
	echo Для продолжения потребуется пароль администратора.
	echo Для продолжения нажмите Enter, для отмены - Ctrl-C.
	read DUMMY
	PACMAN=
	aptitude --version >/dev/null 2>&1 && PACMAN='sudo aptitude install'
	yum --version >/dev/null 2>&1 && PACMAN='su -c yum install'
	emerge --version >/dev/null 2>&1 && PACMAN='su -c emerge'
	urpmi --version >/dev/null 2>&1 && PACMAN='su -c urpmi'
	if [ -z "$PACMAN" ] ; then
		echo Не найдена программа установки пакетов.
		echo Пожалуйста, установите следующие пакеты вручную:
		echo $MISSING1 $MISSING2 $MISSING3
		echo а затем запустите скрипт еще раз.
		exit 1
	fi
	FAIL=0
	sudo $PACMAN $MISSING1 $MISSING2 $MISSING3 || FAIL=1
	if [ $FAIL = 1 ] ; then
		echo Программа установки пакетов завершилась с ошибкой.
		echo Пожалуйста, установите следующие пакеты вручную:
		echo $MISSING1 $MISSING2 $MISSING3
		echo а затем запустите скрипт еще раз.
		exit 1
	fi
fi

mkdir -p ~/.config/geany/filedefs
echo "[build_settings]" > ~/.config/geany/filedefs/filetypes.asm
echo "compiler="$MASMDIR/"fullma.sh \"%f\"" >> ~/.config/geany/filedefs/filetypes.asm
echo "error_regex=(.+)\(([0-9]+)\)" >> ~/.config/geany/filedefs/filetypes.asm
echo Все готово.
