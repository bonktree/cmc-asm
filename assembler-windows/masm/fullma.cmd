@echo off
rem Holy crap `subst` is a complete mess to work with
rem I won't even talk about goto swamp
rem mind == blown

rem Run DosBox with supplied .conf with mounted paths
if --[%1]==--[dd] (
	set PURPOSE=dd
	goto debug_dosbox
)

set ASM_EDITOR="%~dp0..\npp\notepad++"

if exist "%2" goto file_found
:file_not_found
echo Не указано имя файла с исходником.
exit

:file_found
if /I --%~x2==--.asm goto ext_ok
echo Программа должна иметь расширение '.asm' (сейчас '%~x2').
set NAMEFAIL=true

:ext_ok
dir "%~dp2"\%~nx2 >nul 2>nul && goto name_ok
echo В имени файла программы не должно быть пробелов (сейчас '%~n2').
set NAMEFAIL=true

:name_ok
if not --%NAMEFAIL%==--true goto name_ext_ok
echo Исправьте имя файла и запустите компиляцию заново.
rem pause
exit

:name_ext_ok
rem Poekhali


:debug_dosbox
subst t: /d >nul
rem Full path to ...\masm
set MASMP="%~dp0."
echo MASMP = %MASMP%
subst t: %MASMP%

subst u: /d >nul
rem Full path to source directory
set ARGP="%~dp2."
echo ARGP = %ARGP%
set FN=%~n2
subst u: %ARGP%

if --%PURPOSE%==--dd (
	call t:\dosbox\dosbox.exe -conf t:\dosbox\dosbox.conf
	goto fin
)


rem Assembling
if exist u:\%FN%.exe del u:\%FN%.exe
call t:\dosbox\dosbox.exe -exit -c "t:\compile.bat %FN%" -conf t:\dosbox\dosbox.conf -noconsole
if not exist u:\%FN%.exe goto err

rem Running
if --[%1]==--[run] goto run_regular
if --[%1]==--[debug] goto run_debugger
goto fin

:run_regular
call t:\dosbox\dosbox.exe -c "t:\runprog.bat u:\%FN%.exe" -conf t:\dosbox\dosbox.conf -noconsole
goto fin
:run_debugger
call t:\dosbox\dosbox.exe -c "t:\run_td.bat u:\%FN%.exe" -conf t:\dosbox\dosbox.conf -noconsole
goto fin

:err
if exist u:\%FN%.obj del u:\%FN%.obj
%ASM_EDITOR% -n1 "%~dpn2.lst"
echo При компиляции обнаружены ошибки. Смотрите файл %~n2.lst, открытый в редакторе, для подробной информации.

:fin
subst t: /d
subst u: /d
exit

