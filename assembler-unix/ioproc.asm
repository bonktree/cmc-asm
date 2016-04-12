    
; ����� IOPROC:  ��楤��� �����-�뢮��
;         ��p������� - �� 30.03.2001
    
  public procnl, procoutnum, procflush, procinch, procinint

iocode segment
   assume cs:iocode
    
;************************************************
;               ����� �� �����
;************************************************
 
;========================================
;  ��ॢ�� ����� �� ����� ��ப� �࠭�
;   ���饭��: call procnl
;   ��ࠬ��஢ ���
;----------------------------------------
procnl proc far
      push dx
      push ax
      mov  ah,2
      mov  dl,13        ; CR (����� �� ��砫� ��ப�)
      int  21h
      mov  dl,10        ; LF (����� �� ᫥������ ��ப�)
      int  21h
      pop  ax
      pop  dx
      ret
procnl endp
 
;==============================================================
;  �뢮� 楫��� �᫠-᫮�� � ������ ��� ��� �����
;   ���饭��:  call procoutnum
;   �� �室�:  ax - �뢮����� �᫮
;              dh - �᫮ � ������ (1) ��� ��� ����� (0)
;              dl - �ਭ� ���� �뢮�� (>=0)
;    (�᫨ ���� �����, 祬 ����, � ᫥�� ����������� �஡���,
;     �᫨ ����� - �뢮����� ⮫쪮 �᫮)
;--------------------------------------------------------------
procoutnum proc far
      push bp
      mov  bp,sp
      push ax
      push dx
      push si
      sub  sp,6         ; �⢥�� 6 ���⮢ � �⥪� ��� �᫮
; ��� �����
      cmp  dh,1         ; �뢮� � ������ (dh=1)?
      jne  pon0
      cmp  ax,0
      jge  pon0
      mov  dh,2         ; �᫨ �뢮� � ������ � ax<0,
      neg  ax           ;  � dh:=2, ax:=abs(ax)
pon0: push dx           ; ᯠ�� dh (����) � dl (�ਭ�)
; ������ ��� �᫠ � �⥪ (� ���⭮� ���浪�)
      xor  si,si        ; si - ���-�� ��� � �᫥
pon1: mov  dx,0         ; ax -> (dx,ax)
      div  cs:ten       ; ax=ax div 10;  dx=ax mod 10
      add  dl,'0'
      mov  byte ptr [bp-12+si],dl ; ��� -> �⥪
      inc  si
      or   ax,ax
      jnz  pon1         ; �� �� 0
; ������ �����, �᫨ ����, � �⥪
      pop  dx
      cmp  dh,2
      jne  pon2
      mov  byte ptr [bp-12+si],'-'
      inc  si
; ����� �஡���� ���।�
pon2: mov  dh,0         ; dx - �ਭ� ���� �뢮��
      mov  ah,2         ; �㭪�� 02 ���뢠��� 21h
pon21: cmp dx,si
      jle  pon3         ; �ਭ� <= ����� �᫠
      push dx
      mov  dl,' '
      int  21h
      pop  dx
      dec  dx
      jmp  pon21
; ����� (����� �) ���
pon3: dec  si
      mov  dl,byte ptr [bp-12+si]
      int  21h
      or   si,si
      jnz  pon3
; ��室 �� ��楤���
      add  sp,6
      pop  si
      pop  dx
      pop  ax
      pop  bp
      ret
ten   dw 10
procoutnum endp
    
    
;***********************************************************
;                 ���� � ����������
;***********************************************************

;   ���� ����� � ���������� (��� ࠡ��� � �㭪樥� 0Ah)
maxb  db 128            ; ����. ࠧ��� ���� �����
sizeb db 0              ; �᫮ ��������� ᨬ����� � ����
buf   db 128 dup(?)     ; ᠬ ���� �����
posb  db 0              ; ����� ��᫥�. ��⠭. ᨬ���� �� buf

;===================================================
; �ᯮ����⥫쭠� ��楤�� ����� ��ப� ᨬ�����
; (������ Enter) � ���� buf (���� ��� �ਣ��襭��)
;---------------------------------------------------
readbuf proc near
      push ax
      push dx
      push ds
      mov  dx,cs
      mov  ds,dx
      lea  dx,buf-2     ; ds:dx - ���� buf[-2]
      mov  ah,0Ah       ; ���� ��ப� � ���� (������ Enter)
      int  21h
      call procnl       ; ����� �� ����� ��ப� �࠭�
      inc  cs:sizeb     ; � ����� ����� Enter
      mov  cs:posb,0    ; ᪮�쪮 ᨬ����� 㦥 ��⠭� �� buf
      pop  ds
      pop  dx
      pop  ax
      ret
readbuf endp

;====================================
;  ���⪠ ���� ����� � ����������
;   ���饭��: call procflush
;   ��ࠬ��஢ ���
;------------------------------------
procflush proc far
      push ax
      mov cs:sizeb,0    ; ���⪠ buf
      mov cs:posb,0
      mov ah,0Ch        ; ���⪠ DOS-����
      mov al,0          ; ��� �����. ����⢨�
      int 21h
      pop ax
      ret
procflush endp
    
;==================================================================
;  ���� ᨬ���� (� �ய�᪮� ��� ��� �ய�᪠ Enter)
;   ���饭��: call procinch
;   �� �室�:  al - Enter �ய����� (0) ��� �뤠�� ��� ᨬ��� (1)
;   �� ��室�: al - �������� ᨬ��� (ah �� �������)
;-----------------------------------------------------------------
procinch proc far
      push bx
princh1:
      mov  bl,cs:posb    ; ����� ��᫥����� ��⠭���� ᨬ����
      inc  bl            ; ᫥�. �����
      cmp  bl,cs:sizeb   ; �� ��᫥���� ᨬ��� ����?
      jb   princh2
      jne  princh10      ; ���� �� ��⠭ �� ����?
      cmp  al,0          ; ���뢠�� �� ����� ��ப� (Enter)?
      jne  princh2
princh10:
      call readbuf       ; ������ � ����
      jmp  princh1       ; �������
princh2:
      mov  cs:posb,bl    ;��������� ����� ���뢠����� ᨬ����
      mov  bh,0
      mov  al,cs:buf[bx-1]   ;al:=ᨬ���
      pop  bx
      ret
procinch endp

;=================================================================
;  ���� 楫��� �᫠ (� ������ � ���) ࠧ��஬ � ᫮��
;   ���饭��: call procinint
;   �� �室�:  ���
;   �� ��室�: ax - ��������� �᫮
;------------------------------------------------------------------
procinint proc far
      push bx
      push cx
      push dx
; �ய�� �஡���� � ���殢 ��ப ���砫�
prinint1:
      mov al,0
      call procinch     ; al - ���. ᨬ��� (� �ய�᪮� Enter)
      cmp al,' '        ; �஡��?
      je  prinint1
; �஢�ઠ �� ����
      mov dx,0          ; dx - �������� �᫮
      mov cx,0          ; ch=0 - ��� ����, cl=0 - ����
      cmp al,'+'
      je  prinint2
      cmp al,'-'
      jne prinint3
      mov cl,1          ; cl=1 - �����
; 横� �� ��ࠬ
prinint2:
      mov al,1
      call procinch     ; al - ���. ᨬ��� (Enter - ᨬ���)
prinint3:               ; �஢�ઠ �� ����
      cmp al,'9'
      ja  prinint4      ; >'9' ?
      sub al,'0'
      jb  prinint4      ; <'0' ?
      mov ch,1          ; ch=1 - ���� ���
      mov ah,0
      mov bx,ax         ; bx - ��� ��� �᫮
      mov ax,dx         ; ax - �।�. �᫮
      mul cs:prten      ; *10
      jc  provfl        ; >FFFFh (dx<>0) -> ��९�������
      add ax,bx         ; +���
      jc  provfl
      mov dx,ax         ; ᯠ�� �᫮ � dx
      jmp prinint2      ; � ᫥�. ᨬ����
; ���稫��� ���� (�᫮ � dx)
prinint4:
      mov ax,dx
      cmp ch,1          ; �뫨 ����?
      jne prnodig
      cmp cl,1          ; �� �����?
      jne prinint5
      cmp ax,8000h      ; ����� ����. �᫠ > 8000h ?
      ja  provfl
      neg ax            ; ����� � ����ᮬ
prinint5:
      pop dx            ; ��室
      pop cx
      pop bx
      ret
prten dw 10
;---------- ॠ��� �� �訡�� �� ����� �᫠
provfl:  lea cx,prmsgovfl   ; ��९�������
      jmp prerr
prnodig: lea cx,prmsgnodig  ; ��� ���
prerr: push cs          ; ����� ᮮ�饭�� �� �訡��
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
prmsg      db '�訡�� �� ����� �᫠: ','$'
prmsgovfl  db '��९�������','$'
prmsgnodig db '��� ����','$'
procinint endp
iocode ends
    
       end       ; ����� ����� ioproc
