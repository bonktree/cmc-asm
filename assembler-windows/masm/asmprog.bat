rem t:\masm4\masm.exe /nologo /c /Fou:\%FN%.obj /Flu:\%FN%.lst /W3 /X /Zm /Zi /It: u:\%FN%.asm
set FN=%1
u:
t:\masm4\masm.exe %FN%,%FN%,%FN%;
t:\masm4\link.exe %FN%+T:\masm4\ioproc.obj,%FN%;
exit
