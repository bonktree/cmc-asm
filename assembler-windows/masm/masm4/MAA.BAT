@echo off
rem Если в качестве параметра передано имя файла с программой без расширения
if exist %1 goto f3
if not exist %1.asm goto f3
rem 
rem                       Компилятор создает из него объектный модуль %1.obj
c:\masm_exe\masm %1,%1,%1;
if errorlevel 1 goto f1
echo                                Этап компиляции преодолен ...
rem 
rem Редактор связей создает из объектного модуля исполняемый файл %1.exe
c:\masm_exe\link %1+c:\masm_exe\ioproc.obj,%1;
rem
rem Объектный модуль удаляется
del %1.obj
if errorlevel 1 goto f2
rem 
echo Выполнение программы началось:
%1.exe
echo.
echo Выполнение программы закончено.
goto fin
rem ______________________________________________________________
:f1
echo Ошибка компиляции !!!
del %1.obj
goto fin
:f2
echo Ошибка редактирования связей !
goto fin
:f3
echo Файл с программой не обнаружен. 
echo Возможно, в качестве параметра ошибочно указано имя файла с расширением.
:fin
echo on
