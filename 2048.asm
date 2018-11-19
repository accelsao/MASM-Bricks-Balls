INCLUDE Irvine32.inc

main          EQU start@0

.data
	Board	BYTE  "...3......"
			BYTE  ".........."
			BYTE  ".........."
			BYTE  ".........."
			BYTE  "...4......"
			BYTE  ".........."
			BYTE  ".........."
			BYTE  "........2."
			BYTE  ".........."
			BYTE  ".........O"
.code


init PROC
	mov ecx,10
	mov esi,offset Board
L1:
	push ecx
	mov ecx,10
	
L2:
	mov al,'0'
	mov [esi],al
	inc esi	
	loop L2
	pop ecx
	loop L1
	
	mov esi,offset Board
	mov al,'X'
	mov [esi],al
	mov [esi+9],al
	mov [esi+90],al
	mov [esi+99],al
	
	ret
	
init ENDP


print PROC
	mov ecx,10
	mov esi,offset Board
L3:
	push ecx
	mov ecx,10
L4:	
	mov ax,[esi]
	call writeChar
	inc esi
	loop L4	
	call crlf	
	pop ecx
	loop L3
	
	
	ret
print ENDP


main PROC
	call init
	call print
	
main ENDP


END main