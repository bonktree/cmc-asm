@echo off
set ASM_EDITOR="%~dp0..\npp\notepad++"

if --%~x2==--.asm goto ext_ok
echo �ணࠬ�� ������ ����� ���७�� '.asm' (ᥩ�� '%~x2').
set NAMEFAIL=true
:ext_ok
dir "%~dp2"\%~nx2 >nul 2>nul && goto name_ok
echo � ����� 䠩�� �ணࠬ�� �� ������ ���� �஡���� (ᥩ�� '%~n2').
set NAMEFAIL=true
:name_ok
if not --%NAMEFAIL%==--true goto name_ext_ok
echo ��ࠢ�� ��� 䠩�� � ������� ��������� ������.
rem pause
exit
:name_ext_ok

rem Poekhali

subst t: /d >nul
rem Full path to ...\masm
set MASMP="%~dp0."
subst t: %MASMP%

subst u: /d >nul
set ARGP="%~dp2."
set FN=%~n2
subst u: %ARGP%

if exist u:\%FN%.exe del u:\%FN%.exe
call t:\dosbox\dosbox.exe -exit -c "t:\compile.bat %FN%" -conf t:\dosbox\dosbox.conf -noconsole
if not exist u:\%FN%.exe goto err

if --%1==--run ^
call t:\dosbox\dosbox.exe -c "t:\runprog.bat u:\%FN%.exe" -conf t:\dosbox\dosbox.conf -noconsole

if --%1==--debug ^
call t:\dosbox\dosbox.exe -c "t:\runprog.bat u:\%FN%.exe" -conf t:\dosbox\dosbox.conf -noconsole

goto fin
:err
if exist u:\%FN%.obj del u:\%FN%.obj
%ASM_EDITOR% -n1 "%~dpn2.lst"
echo �� �������樨 �����㦥�� �訡��. ������ 䠩� %~n2.lst, ������ � ।����, ��� ���஡��� ���ଠ樨.
:fin
subst t: /d
subst u: /d
