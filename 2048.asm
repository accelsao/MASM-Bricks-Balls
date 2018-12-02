INCLUDE Irvine32.inc

main          EQU start@0

.data
	; dd=dword, dw=word ,db=byte
	Board	dw  1,2,3,4,5,6,7,8,9,10
			dw  11,12,13,14,15,16,17,18,19,110
			dw  21,22,23,24,25,26,27,28,29,210
			dw  0,'.',2048,'.','.','.','.','.','.','6'
			dw  '.','.','.','.','.','.','.','.','.','.'
			dw  '.','.',4096,'.','.','.','.','.','.','.'
			dw  '.','.','.','.','.','.','.','.','5','.'
			dw  '.','.','.','.','.','.','.','3','.','.'
			dw  '.','.','.',6,5,4,3,1,2,'.'
			dw  '.',2048,'.','.','.','.','.','.','.','.'
	
	dec2str db 16 DUP(0)	

	
	RandSeed dd ?
	Row dw ?
	Col dw ?
	
	Game_End_Msg db '~Game End~',0
	
.code

Random PROC ; return eax , like Delphi
	push edx
	imul edx,RandSeed,08088405h ; 08088405H=134775813_dec
	inc edx
	mov RandSeed,edx
	mul edx ; edx:eax = eax*edx
	mov eax,edx
	pop edx
	ret
Random ENDP


Init_Dif PROC
	mov ecx,10
	mov esi,offset Board
	mov eax,0
L1:
	push ecx
	mov ecx,10
L2:
	inc eax
	mov [esi],ax
	add esi,2
	loop L2
	pop ecx
	loop L1
	ret
Init_Dif ENDP

Init PROC
	mov ecx,10
	mov esi,offset Board
L1:
	push ecx
	mov ecx,10
L2:
	mov eax,3
	call random
	mov [esi],ax
	add esi,2
	loop L2
	pop ecx
	loop L1
	ret
	
Init ENDP

Eax2Dec PROC
	mov ebx,10 ;divisor=10
	xor ecx,ecx
L1:
	xor edx,edx
	div ebx ; eax/ebx ->  edx:eax 
	push edx
	inc ecx
	cmp eax,0
	jne L1
L2:
	cld ; df=0
	pop eax
	add eax,'0'
	stosb
	loop L2
	mov byte ptr [edi],0
	ret 
Eax2Dec ENDP

WriteNumber PROC ,
	number: word
	
	push ecx
	movzx eax,number
	lea edi,dec2str
	call Eax2Dec
	mov edx,offset dec2str
	call WriteString
	pop ecx
	
	
	ret 
WriteNumber ENDP

Display_Board PROC,
	mode: byte
	
	movzx ecx,mode ;playmode 8, debugmode 10
	.if mode==8
		mov esi,offset Board+22
	.else
		mov esi,offset Board
	.endif
	
	
L3:
	push ecx

	movzx ecx,mode
	
L4:	
	;Output number;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax,[esi]
	invoke WriteNumber,ax
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;Output 4 space;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push ecx
	mov ecx,4 ;暫時都給4格空白隔開
L5:
	mov ax,' '
	
	call WriteChar
	
	loop L5
	pop ecx
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	 
	add esi,2 ; word=2 byte
	
	
	
	
	loop L4	
	
	.if mode==8
		add esi,2*2 ; 右移2格
	.endif
	
	pop ecx 
	
	
	call crlf
	loop L3
	
	
	
	ret
Display_Board ENDP


Shift_Right PROC
	
	mov ecx,8
	mov esi,offset Board+160+14 ;8(rows 從後面往前)*10(cols)*2(word) + 14 (第7個 *2)
	mov edi,offset Board+160+16 ; 第8個 (8*2)
	
	
L2:

	; add for last one
	; 7加到8
	mov bx,[esi]
	add [edi],bx
	sub esi,2
	sub edi,2
	
	std ; set df=1
	; e;se just move 
	; 6 to 7,5 to 6 ... 0(邊界) to 1
	push ecx
	mov ecx,7
	rep movsw
	
	
	sub esi,4
	sub edi,4


	
	pop ecx
	loop L2
	
	; update random edge
	mov esi,offset Board
	mov ecx,10
L3:
	mov eax,3 ; number 0~2
	call random
	mov [esi],ax
	add esi,20
	loop L3
	ret
	
Shift_Right ENDP


Shift_Left PROC
	
	mov ecx,8
	mov esi,offset Board+22+2
	mov edi,offset Board+22
	
	
L2:

	mov bx,[esi]
	add [edi],bx
	add esi,2
	add edi,2
	
	cld
	
	push ecx
	mov ecx,7
	rep movsw
	
	
	add esi,4
	add edi,4
	
	pop ecx
	loop L2
	
	; update random edge
	mov esi,offset Board+18
	mov ecx,10
L3:
	mov eax,3 ; number 0~2
	call random
	mov [esi],ax
	add esi,20
	loop L3
	ret
	
Shift_Left ENDP


;;;;;;;;;;
;(n,m)->(n*10+m)*2;
;;;;;;;;;;
Shift_Down PROC
	
	mov ecx,9
	mov esi,offset Board+156 ;(7,8)
	mov edi,offset Board+176 ;(8,8)

	
	;add r7 to r8
L2:
	mov bx,[esi]
	add [edi],bx
	
	sub esi,2
	sub edi,2
	loop L2
	
	sub esi,2
	sub edi,2

	
	mov ecx,7
L3:
	std
	push ecx
	mov ecx,9
	rep movsw
	
	
	sub esi,2
	sub edi,2
	
	pop ecx

	loop L3
	
	; update random edge
	mov esi,offset Board
	mov ecx,10
Get_Rand:
	mov eax,3 ; number 0~2
	call random
	mov [esi],ax
	add esi,2
	loop Get_Rand
	ret
	
Shift_Down ENDP

Shift_Up PROC
	
	mov ecx,9
	mov esi,offset Board+42
	mov edi,offset Board+22

	
	;add r2 to r1
L2:
	mov bx,[esi]
	add [edi],bx
	
	add esi,2
	add edi,2
	loop L2
	
	add esi,2
	add edi,2

	
	mov ecx,7
L3:
	cld
	push ecx
	mov ecx,9
	rep movsw
	
	
	add esi,2
	add edi,2
	
	pop ecx

	loop L3
	
	; update random edge
	mov esi,offset Board+180
	mov ecx,10
Get_Rand:
	mov eax,3 ; number 0~2
	call random
	mov [esi],ax
	add esi,2
	loop Get_Rand
	ret
	
Shift_Up ENDP

Check_End PROC
	; Left-Right ;
	mov esi,offset Board+22
	mov edi,offset Board+24
	mov ecx,8
L1:
	push ecx
	mov ecx,7
L2:
	mov bx,[esi]
	cmp bx,[edi]
	je Game
	add esi,2
	add edi,2
	loop L2
	
	pop ecx
	
	add esi,6
	add edi,6
	
	loop L1
	
	
	; Up-Down ;
	mov esi,offset Board+22
	mov edi,offset Board+42
	mov ecx,7
L3:
	push ecx
	mov ecx,8
L4:
	mov bx,[esi]
	cmp bx,[edi]
	je Game
	add esi,2
	add edi,2
	loop L4
	
	pop ecx
	
	add esi,4
	add edi,4
	
	loop L3
	
	
	; Game End
	mov  edx,OFFSET Game_End_Msg
    call WriteString
	call crlf
	call WaitMsg
	invoke ExitProcess, 0
	
	
Game:
	pop ecx
	ret
	
Check_End ENDP

main PROC
	
	mov randseed,9487h ; set randseed
	
	;call Init
	call Init_Dif
	
	;mov esi,offset Board+22
	;mov eax,13
	;mov [esi],ax
	
	invoke Display_Board,10
	call crlf
	;invoke Display_Board,8
	;call crlf
	;call WaitMsg

	
Game:
	
	call Check_End
	call readchar ; read char to al in ascii
	; wasd當方向
	;;;;;;向左
	cmp al,'d'
	je Get_D
	cmp al,'D'
	je Get_D
	;;;;;;
	;;;;;;向左
	cmp al,'a'
	je Get_A
	cmp al,'A'
	je Get_A
	;;;;;;
	;;;;;;向上
	cmp al,'w'
	je Get_W
	cmp al,'W'
	je Get_W
	;;;;;;
	;;;;;;向下
	cmp al,'s'
	je Get_S
	cmp al,'S'
	je Get_S
	;;;;;;
	
	; Test print char
	cmp al,'c'
	je PrintChr
	
	; ESC exit exe ,esc ascii is 27 dec, 1b h
	cmp al,1bh 
	jne Game
	
	ret
PrintChr:
	call WriteChar
	jmp Game
Get_D:
	;call clrscr
	call Shift_Right	
	invoke Display_Board,10
	call crlf
	jmp Game
Get_A:
	;call clrscr
	call Shift_Left
	invoke Display_Board,10
	call crlf
	jmp Game
Get_S:
	;call clrscr
	call Shift_Down
	invoke Display_Board,10
	call crlf
	jmp Game
Get_W:
	;call clrscr
	call Shift_Up
	invoke Display_Board,10
	call crlf
	jmp Game

	
	
	;call init
	;call Display_Board
	;call Shift_Right
	;call Display_Board
	;invoke WriteNumber,100 測試用
	
	
main ENDP


END main


;esc 27


; Board
;遊戲區8X8 +邊界 10X10
;address 因為用word 所以是2bytes
; 0 2 4 6 8 10 12 14 16 18
;20 ................... 38
;40
;
;
;

comment @
待完成

外框
數字排版

@


