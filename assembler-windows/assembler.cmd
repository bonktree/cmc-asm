@echo off
if not exist masm goto error
if not exist npp goto error
if exist schem.asm attrib -r schem.asm
attrib +r masm\*.*
copy masm\schem.asm . >nul
attrib +r schem.asm
start npp\notepad++ schem.asm
exit
:error
echo Требуемые файлы не найдены. Для работы ассемблера нужно извлечь из архива весь каталог 'assembler'.
pause