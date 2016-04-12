@echo off
if --%~x1==--.asm goto ext_ok
echo Программа должна иметь расширение '.asm' (сейчас '%~x1').
set NAMEFAIL=true
:ext_ok
dir "%~dp1"\%~nx1 > nul 2>nul && goto name_ok
echo В имени файла программы не должно быть пробелов (сейчас '%~n1').
set NAMEFAIL=true
:name_ok
if not --%NAMEFAIL%==--true goto name_ext_ok
echo Исправьте имя файла и запустите компиляцию заново.
rem pause
exit
:name_ext_ok
subst t: /d >nul
set MP="%~dp0."
subst t: %MP%
subst u: /d >nul
set FP="%~dp1."
set FN=%~n1
subst u: %FP%

if exist u:\%FN%.exe del u:\%FN%.exe
call t:\dosbox\dosbox.exe -exit -c "t:\asmprog.bat %FN%" -conf t:\dosbox\dosbox.conf -noconsole 
if not exist u:\%FN%.exe goto err

call t:\dosbox\dosbox.exe -c "t:\runprog.bat u:\%FN%.exe" -conf t:\dosbox\dosbox.conf -noconsole 
goto fin
:err
if exist u:\%FN%.obj del u:\%FN%.obj
"%~dp0..\npp\notepad++" -n1 "%~dpn1.lst"
echo При компиляции обнаружены ошибки. Смотрите файл %~n1.lst, открытый в редакторе, для подробной информации.
:fin
subst t: /d
subst u: /d
