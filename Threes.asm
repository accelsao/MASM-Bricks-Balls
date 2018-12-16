INCLUDE Irvine32.inc
main EQU start@0

.data
	; 6X6 邊界
	Board	dw  1,1,1,1,1,1
			dw  1,65534,65535,1,3,6
			dw  0,3,1,3,1,0
			dw  1,1,3,1,3,6
			dw  0,3,1,3,1,0
			dw  1,1,0,4,5,6

	Game_Mode db 6
	Game_End_Msg db '< Game End >',0
	Game_Score_Msg db 'Score: ',0

	
.code

Init PROC
	mov ecx,6
	mov esi,offset Board
L1:
	push ecx
	mov ecx,6
L2:
	mov eax,3
	call randomrange
	mov [esi],ax
	add esi,2
	loop L2
	pop ecx
	loop L1
	ret
	
Init ENDP


Count_digit PROC
	mov ebx,eax
	.if ebx<10
		mov ecx,5
	.elseif ebx<100
		mov ecx,4
	.elseif ebx<1000
		mov ecx,3
	.elseif ebx<10000
		mov ecx,2
	.elseif ebx<100000
		mov ecx,1
	.else
		mov ecx,0
	.endif
	ret
Count_digit ENDP


Display_Board PROC,
	mode: byte
	
	movzx ecx,mode ;playmode 4, debugmode 6
	.if mode==4
		mov esi,offset Board+12+2
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
	movzx eax,ax
	
	;;; set ecx for space
	push ecx
	call Count_digit
	mov ebx,eax
	mov al,' '
L5:
	call WriteChar
	loop L5	
	mov eax,ebx
	call writedec
	
	pop ecx
	add esi,2 ; word=2 byte
	
	
	
	
	loop L4	
	
	.if mode==4
		add esi,4 ; 右移2格
	.endif
	
	pop ecx 
	
	
	call crlf
	loop L3
	
	ret
Display_Board ENDP


Shift_Right PROC
	
	mov ecx,4
	;6*2
	mov esi,offset Board+48+6   ;(4,3)
	mov edi,offset Board+48+8 ;(4,4)
	
	
L1:
	push ecx
	mov ecx,3
	
	
L2:
	mov bx,[edi]
	
	.if bx==0
		mov bx,[esi]
		add [edi],bx
		sub esi,2
		sub edi,2
		std
		rep movsw
		add esi,2
		add edi,2
		mov ecx,1
	.elseif bx==[esi]
		.if bx >= 3
			mov bx,[esi]
			add [edi],bx
			sub esi,2
			sub edi,2
			std
			rep movsw
			add esi,2
			add edi,2
			mov ecx,1
		.else
			sub esi,2
			sub edi,2
		.endif
	.elseif	bx==2
		mov bx,[esi]
		.if bx==1
			add [edi],bx
			sub esi,2
			sub edi,2
			std
			rep movsw
			add esi,2
			add edi,2
			mov ecx,1
		.else
			sub esi,2
			sub edi,2
		.endif
	.elseif	bx==1
		mov bx,[esi]
		.if bx==2
			add [edi],bx
			sub esi,2
			sub edi,2
			std
			rep movsw
			add esi,2
			add edi,2
			mov ecx,1
		.else
			sub esi,2
			sub edi,2
		.endif
	.else
		sub esi,2
		sub edi,2
	.endif

	dec ecx
	jne L2

	

	
	sub esi,6
	sub edi,6
	pop ecx
	dec ecx
	jne L1
	
	; update random edge
	mov esi,offset Board
	mov ecx,6
L3:
	mov eax,3
	call randomrange
	mov [esi],ax
	add esi,12
	loop L3
	
	mov esi,offset Board+12   ;(1,0)
	mov edi,offset Board+12+2 ;(1,1)
	mov ecx,4
Mov_num:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		mov [edi],bx
	.else
		add esi,12
		add edi,12
		dec ecx
		jne Mov_num
	.endif
	
	ret
	
Shift_Right ENDP


Shift_Left PROC
	
	
	mov ecx,4
	mov esi,offset Board+12+4   ;(1,2)
	mov edi,offset Board+12+2 	;(1,1)
	
L1:
	push ecx
	mov ecx,3
	
	
L2:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		add [edi],bx
		add esi,2
		add edi,2
		cld
		rep movsw
		sub esi,2
		sub edi,2
		mov ecx,1
	.elseif bx==[esi]
		.if bx >= 3
			mov bx,[esi]
			add [edi],bx
			add esi,2
			add edi,2
			cld
			rep movsw
			sub esi,2
			sub edi,2
			mov ecx,1
		.else
			add esi,2
			add edi,2
		.endif
	.elseif bx==2
		mov bx,[esi]
		.if bx==1
			add [edi],bx
			add esi,2
			add edi,2
			cld
			rep movsw
			sub esi,2
			sub edi,2
			mov ecx,1
		.else
			add esi,2
			add edi,2
		.endif
	.elseif bx==1
		mov bx,[esi]
		.if bx==2
			add [edi],bx
			add esi,2
			add edi,2
			cld
			rep movsw
			sub esi,2
			sub edi,2
			mov ecx,1
		.else
			add esi,2
			add edi,2
		.endif
	.else
		add esi,2
		add edi,2
	.endif
	
	dec ecx
	jne L2

	add esi,6
	add edi,6
	pop ecx
	dec ecx
	jne L1
	
	; update random edge
	mov esi,offset Board+12+10
	mov ecx,4
L3:
	mov eax,3
	call randomrange
	mov [esi],ax
	add esi,12
	loop L3
	
	mov esi,offset Board+12+10 ;(1,5)
	mov edi,offset Board+12+8 ;(1,4)
	mov ecx,4
Mov_num:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		mov [edi],bx
	.else
		add esi,12
		add edi,12
		dec ecx
		jne Mov_num
	.endif
	
	
	
	ret

Shift_Left ENDP

Shift_Down PROC
	
	mov ecx,4
	mov esi,offset Board+36+8 ;(3,4)
	mov edi,offset Board+48+8 ;(4,4)

L3:	
	push ecx
	mov ecx,3
L1:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		add [edi],bx
		sub esi,12
		sub edi,12
	L2:
		mov bx,[esi]
		mov [edi],bx
		sub esi,12
		sub edi,12
		loop L2
		add esi,12
		add edi,12
		mov ecx,1
	.elseif bx==[esi]
		.if bx>=3
			mov bx,[esi]
			add [edi],bx
			sub esi,12
			sub edi,12
		L6:
			mov bx,[esi]
			mov [edi],bx
			sub esi,12
			sub edi,12
			loop L6
			add esi,12
			add edi,12
			mov ecx,1
		.else
			sub esi,12
			sub edi,12
		.endif
	.elseif bx==2
		mov bx,[esi]
		.if bx==1
			add [edi],bx
			sub esi,12
			sub edi,12
		L4:
			mov bx,[esi]
			mov [edi],bx
			sub esi,12
			sub edi,12
			loop L4
			add esi,12
			add edi,12
			mov ecx,1
		.else
			sub esi,12
			sub edi,12
		.endif
	.elseif bx==1
		mov bx,[esi]
		.if bx==2
			add [edi],bx
			sub esi,12
			sub edi,12
		L5:
			mov bx,[esi]
			mov [edi],bx
			sub esi,12
			sub edi,12
			loop L5
			add esi,12
			add edi,12
			mov ecx,1
		.else
			sub esi,12
			sub edi,12
		.endif
	.else
		sub esi,12
		sub edi,12
	.endif 
	dec ecx
	jne L1

	add esi,36
	add edi,36
	sub esi,2
	sub edi,2
	
	pop ecx

	dec ecx
	jne L3
	
	; update random edge
	mov esi,offset Board
	mov ecx,6
Get_Rand:
	mov eax,3 ; number 0~2
	call randomrange
	mov [esi],ax
	add esi,2
	loop Get_Rand
	

	mov esi,offset Board+2   ;(0,1)
	mov edi,offset Board+12+2 ;(1,1)
	mov ecx,4
Mov_num:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		mov [edi],bx
	.else
		add esi,2
		add edi,2
		dec ecx
		jne Mov_num
	.endif
	
	ret
	
Shift_Down ENDP

Shift_Up PROC
	
	
	
	
	mov ecx,4
	mov esi,offset Board+24+2 ;(2,1)
	mov edi,offset Board+12+2 ;(1,1)

L3:	
	push ecx
	mov ecx,3
L1:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		add [edi],bx
		add esi,12
		add edi,12
	repmv_1:
		mov bx,[esi]
		mov [edi],bx
		add esi,12
		add edi,12
		loop repmv_1
		sub esi,12
		sub edi,12
		mov ecx,1
	.elseif bx==[esi]
		.if bx>=3
			mov bx,[esi]
			add [edi],bx
			add esi,12
			add edi,12
		repmv_2:
			mov bx,[esi]
			mov [edi],bx
			add esi,12
			add edi,12
			loop repmv_2
			sub esi,12
			sub edi,12
			mov ecx,1
		.else
			add esi,12
			add edi,12
		.endif
	.elseif bx==2
		mov bx,[esi]
		.if bx==1
			add [edi],bx
			add esi,12
			add edi,12
		repmv_3:
			mov bx,[esi]
			mov [edi],bx
			add esi,12
			add edi,12
			loop repmv_3
			sub esi,12
			sub edi,12
			mov ecx,1
		.else
			add esi,12
			add edi,12
		.endif
	.elseif bx==1
		mov bx,[esi]
		.if bx==2
			add [edi],bx
			add esi,12
			add edi,12
		repmv_4:
			mov bx,[esi]
			mov [edi],bx
			add esi,12
			add edi,12
			loop repmv_4
			sub esi,12
			sub edi,12
			mov ecx,1
		.else
			add esi,12
			add edi,12
		.endif
	.else
		add esi,12
		add edi,12
	.endif 
	dec ecx
	jne L1
	

	sub esi,36
	sub edi,36
	add esi,2
	add edi,2
	
	pop ecx

	dec ecx
	jne L3
	
	; update random edge
	mov esi,offset Board+60+2 ;(5,1)
	mov ecx,4
Get_Rand:
	mov eax,3 ; number 0~2
	call randomrange
	mov [esi],ax
	add esi,2
	loop Get_Rand
	
	
	mov esi,offset Board+60+2   ;(5,1)
	mov edi,offset Board+48+2 ;(4,1)
	mov ecx,4
Mov_num:
	mov bx,[edi]
	.if bx==0
		mov bx,[esi]
		mov [edi],bx
	.else
		add esi,2
		add edi,2
		dec ecx
		jne Mov_num
	.endif
	
	
	ret	
Shift_Up ENDP

Check_End PROC
	; Left-Right ;
	mov esi,offset Board+12+2;(1,1)
	mov edi,offset Board+12+4;(1,2)
	mov ecx,4
L1:
	push ecx
	mov ecx,3
L2:
	mov bx,[esi]
	.if bx==0
		je Continue
	.elseif bx==1
		mov bx,[edi]
		.if bx==2
			je Continue
		.endif
	.elseif bx==2
		mov bx,[edi]
		.if bx==1
			je Continue
		.endif
	.elseif bx==[edi]
		je Continue
	.endif
	
	add esi,2
	add edi,2
	loop L2
	
	mov bx,[esi]
	.if bx==0
		je Continue
	.endif
	
	pop ecx
	
	add esi,6
	add edi,6
	
	loop L1
	
	
	; Up-Down ;
	mov esi,offset Board+12+2
	mov edi,offset Board+24+2
	mov ecx,4
L3:
	push ecx
	mov ecx,3
L4:
	mov bx,[esi]
	.if bx==0
		je Continue
	.elseif bx==1
		mov bx,[edi]
		.if bx==2
			je Continue
		.endif
	.elseif bx==2
		mov bx,[edi]
		.if bx==1
			je Continue
		.endif
	.elseif bx==[edi]
		je Continue
	.endif
	add esi,12
	add edi,12
	
	loop L4
	mov bx,[esi]
	.if bx==0
		je Continue
	.endif
	
	sub esi,36
	sub edi,36
	
	add esi,2
	add edi,2
	pop ecx
	loop L3
	
	
	; Game End
	mov  edx,OFFSET Game_End_Msg
    call WriteString
	call crlf
	mov  edx,OFFSET Game_Score_Msg
    call WriteString
	call Calc_Score
	call crlf
	call WaitMsg
	call New_Game
	
	ret
	;invoke ExitProcess, 0
	
	
Continue:
	pop ecx
	ret
	
Check_End ENDP

Calc_Score PROC
	mov esi,offset Board+12+2
	push eax
	xor eax,eax
	push ecx
	mov ecx,4
L1:
	push ecx
	mov ecx,4
L2:
	; 用bx做計算才可以加到32bit
	xor ebx,ebx
	mov bx,[esi]
	
	add eax,ebx
	add esi,2
	
	loop L2
	add esi,4
	pop ecx
	loop L1
	pop ecx
	call writedec
	pop eax
	ret
Calc_Score ENDP

New_Game PROC

	call clrscr
	call Init
	invoke Display_Board,Game_Mode
	call crlf
	ret
New_Game ENDP

main PROC
	
	
	
	mov Game_Mode,4
	call New_Game
	
	
	
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
	.if Game_Mode==4
		call clrscr
	.endif
	call Shift_Right	
	invoke Display_Board,Game_Mode
	call crlf
	jmp Game
Get_A:
	.if Game_Mode==4
		call clrscr
	.endif
	call Shift_Left
	invoke Display_Board,Game_Mode
	call crlf
	jmp Game
Get_S:
	.if Game_Mode==4
		call clrscr
	.endif
	call Shift_Down
	invoke Display_Board,Game_Mode
	call crlf
	jmp Game
Get_W:
	.if Game_Mode==4
		call clrscr
	.endif
	call Shift_Up
	invoke Display_Board,Game_Mode
	call crlf
	jmp Game

main ENDP


END main


comment @

	http://programming.msjc.edu/asm/help/index.html

	小黑框的排版 加有的沒的
	1. Rule
	2. 拉大版面
	3. 顏色
	4. 不知道

@


