    
; Модуль IOPROC:  Процедуры ввода-вывода
;         испpавление - от 30.03.2001
    
  public procnl, procoutnum, procflush, procinch, procinint

iocode segment
   assume cs:iocode
    
;************************************************
;               ВЫВОД НА ЭКРАН
;************************************************
 
;========================================
;  Перевод курсора на новую строку экрана
;   Обращение: call procnl
;   Параметров нет
;----------------------------------------
procnl proc far
      push dx
      push ax
      mov  ah,2
      mov  dl,13        ; CR (курсор на начало строки)
      int  21h
      mov  dl,10        ; LF (курсор на следующую строку)
      int  21h
      pop  ax
      pop  dx
      ret
procnl endp
 
;==============================================================
;  Вывод целого числа-слова со знаком или без знака
;   Обращение:  call procoutnum
;   На входе:  ax - выводимое число
;              dh - число со знаком (1) или без знака (0)
;              dl - ширина поля вывода (>=0)
;    (если поле больше, чем надо, то слева добавляются пробелы,
;     если меньше - выводится только число)
;--------------------------------------------------------------
procoutnum proc far
      push bp
      mov  bp,sp
      push ax
      push dx
      push si
      sub  sp,6         ; отвести 6 байтов в стеке под число
; учет знака
      cmp  dh,1         ; вывод со знаком (dh=1)?
      jne  pon0
      cmp  ax,0
      jge  pon0
      mov  dh,2         ; если вывод со знаком и ax<0,
      neg  ax           ;  то dh:=2, ax:=abs(ax)
pon0: push dx           ; спасти dh (знак) и dl (ширину)
; запись цифр числа в стек (в обратном порядке)
      xor  si,si        ; si - кол-во цифр в числе
pon1: mov  dx,0         ; ax -> (dx,ax)
      div  cs:ten       ; ax=ax div 10;  dx=ax mod 10
      add  dl,'0'
      mov  [bp-12+si],dl ; цифра -> стек
      inc  si
      or   ax,ax
      jnz  pon1         ; еще не 0
; запись минуса, если есть, в стек
      pop  dx
      cmp  dh,2
      jne  pon2
      mov  byte ptr [bp-12+si],'-'
      inc  si
; печать пробелов впереди
pon2: mov  dh,0         ; dx - ширина поля вывода
      mov  ah,2         ; функция 02 прерывания 21h
pon21: cmp dx,si
      jle  pon3         ; ширина <= длина числа
      push dx
      mov  dl,' '
      int  21h
      pop  dx
      dec  dx
      jmp  pon21
; печать (минуса и) цифр
pon3: dec  si
      mov  dl,[bp-12+si]
      int  21h
      or   si,si
      jnz  pon3
; выход из процедуры
      add  sp,6
      pop  si
      pop  dx
      pop  ax
      pop  bp
      ret
ten   dw 10
procoutnum endp
    
    
;***********************************************************
;                 ВВОД С КЛАВИАТУРЫ
;***********************************************************

;   буфер ввода с клавиатуры (для работы с функцией 0Ah)
maxb  db 128            ; макс. размер буфера ввода
sizeb db 0              ; число введенных символов в буфере
buf   db 128 dup(?)     ; сам буфер ввода
posb  db 0              ; номер послед. считан. символа из buf

;===================================================
; вспомогательная процедура ввода строки символов
; (включая Enter) в буфер buf (ввод без приглашения)
;---------------------------------------------------
readbuf proc near
      push ax
      push dx
      push ds
      mov  dx,cs
      mov  ds,dx
      lea  dx,buf-2     ; ds:dx - адрес buf[-2]
      mov  ah,0Ah       ; ввод строки в буфер (включая Enter)
      int  21h
      call procnl       ; курсор на новую строку экрана
      inc  cs:sizeb     ; в длине учесть Enter
      mov  cs:posb,0    ; сколько символов уже считано из buf
      pop  ds
      pop  dx
      pop  ax
      ret
readbuf endp

;====================================
;  Очистка буфера ввода с клавиатуры
;   Обращение: call procflush
;   Параметров нет
;------------------------------------
procflush proc far
      push ax
      mov cs:sizeb,0    ; очистка buf
      mov cs:posb,0
      mov ah,0Ch        ; очистка DOS-буфера
      mov al,0          ; без допол. действий
      int 21h
      pop ax
      ret
procflush endp
    
;==================================================================
;  Ввод символа (с пропуском или без пропуска Enter)
;   Обращение: call procinch
;   На входе:  al - Enter пропустить (0) или выдать как символ (1)
;   На выходе: al - введенный символ (ah не меняется)
;-----------------------------------------------------------------
procinch proc far
      push bx
princh1:
      mov  bl,cs:posb    ; номер последнего считанного символа
      inc  bl            ; след. номер
      cmp  bl,cs:sizeb   ; не последний символ буфера?
      jb   princh2
      jne  princh10      ; буфер не считан до конца?
      cmp  al,0          ; считывать ли конец строки (Enter)?
      jne  princh2
princh10:
      call readbuf       ; доввод в буфер
      jmp  princh1       ; повторить
princh2:
      mov  cs:posb,bl    ;запомнить номер считываемого символа
      mov  bh,0
      mov  al,cs:buf[bx-1]   ;al:=символ
      pop  bx
      ret
procinch endp

;=================================================================
;  Ввод целого числа (со знаком и без) размером в слово
;   Обращение: call procinint
;   На входе:  нет
;   На выходе: ax - введенное число
;------------------------------------------------------------------
procinint proc far
      push bx
      push cx
      push dx
; пропуск пробелов и концов строк вначале
prinint1:
      mov al,0
      call procinch     ; al - очер. символ (с пропуском Enter)
      cmp al,' '        ; пробел?
      je  prinint1
; проверка на знак
      mov dx,0          ; dx - вводимое число
      mov cx,0          ; ch=0 - нет цифры, cl=0 - плюс
      cmp al,'+'
      je  prinint2
      cmp al,'-'
      jne prinint3
      mov cl,1          ; cl=1 - минус
; цикл по цифрам
prinint2:
      mov al,1
      call procinch     ; al - очер. символ (Enter - символ)
prinint3:               ; проверка на цифру
      cmp al,'9'
      ja  prinint4      ; >'9' ?
      sub al,'0'
      jb  prinint4      ; <'0' ?
      mov ch,1          ; ch=1 - есть цифра
      mov ah,0
      mov bx,ax         ; bx - цифра как число
      mov ax,dx         ; ax - предыд. число
      mul cs:prten      ; *10
      jc  provfl        ; >FFFFh (dx<>0) -> переполнение
      add ax,bx         ; +цифра
      jc  provfl
      mov dx,ax         ; спасти число в dx
      jmp prinint2      ; к след. символу
; кончились цифры (число в dx)
prinint4:
      mov ax,dx
      cmp ch,1          ; были цифры?
      jne prnodig
      cmp cl,1          ; был минус?
      jne prinint5
      cmp ax,8000h      ; модуль отриц. числа > 8000h ?
      ja  provfl
      neg ax            ; взять с минусом
prinint5:
      pop dx            ; выход
      pop cx
      pop bx
      ret
prten dw 10
;---------- реакция на ошибки при вводе числа
provfl:  lea cx,prmsgovfl   ; переполнение
      jmp prerr
prnodig: lea cx,prmsgnodig  ; нет цифр
prerr: push cs          ; печать сообщения об ошибке
      pop  ds           ; ds=cs
      lea  dx,prmsg
      mov  ah,9         ; outstr
      int  21h
      mov  dx,cx
      mov  ah,9         ; outstr
      int  21h
      call procnl
      mov  ah,4Ch       ; finish
      int  21h
prmsg      db 'Ошибка при вводе числа: ','$'
prmsgovfl  db 'переполнение','$'
prmsgnodig db 'нет цифры','$'
procinint endp
iocode ends
    
       end       ; конец модуля ioproc
