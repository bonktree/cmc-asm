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
echo �ॡ㥬� 䠩�� �� �������. ��� ࠡ��� ��ᥬ���� �㦭� ������� �� ��娢� ���� ��⠫�� 'assembler'.
pause