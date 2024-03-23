STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
	
STACK ENDS

DATA SEGMENT PARA 'DATA'
	; DW define word (16 bits)
	BALL_X DW 0Ah ; X position (column) of the ball 
	BALL_Y DW 0Ah ; Y position (line) of the ball
	BALL_SIZE DW 09h ;size of the ball (how many pixels does the ball have in width and height)

DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR 
	ASSUME CS:CODE, DS:DATA, SS:STACK ; ASSUME AS CODE,DATA ,STACK 	segments the respective registers
	PUSH DS 	; push to the stack DS segment
	SUB AX,AX   ; clean AX register
	PUSH AX		; push AX to the stack
	MOV AX,DATA ; save on the AX register the data content
	MOV DS,AX   ; save on the DS segment the contents of AX
	POP AX		; release the top item of the stack to the AX register
	POP AX		; release the top item of the stack to the AX register
				;MOV DL,'A'
				;MOV AH,6h
				;INT 21h
		MOV AH,00h ; set the config to video mode
		MOV AL,13h ; choose the video mode
		INT 10h ; execute the config
		
		;MOV AH,0Bh ; set the config 
		;MOV BH,00h ; to the background color
		;MOV BL,00h ; choose black as background color
		;INT 10H ; execute the configuration
		
		CALL DRAW_BALL
		
		
		RET
	MAIN ENDP
	
	DRAW_BALL PROC NEAR
	
		MOV CX,BALL_X ; set the initial column [x]
		MOV DX,BALL_Y ; set the initial line [y]	
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch ; set the config to writing pixel
			MOV AL,04h ; choose red as color
			MOV BH,00h ; set the page number 
			INT 10H    ; execute the config
			
			INC CX     ; CX += 1
			MOV AX,CX		   ; CX - BALL_X > BALL_SIZE (Y -> KEEP GOING (NEXT LINE), N -> GO TO THE NEXT COLUMN)
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X ; THE CX register goes back to the initial column
			INC DX    	  ; we advance one line
			
			MOV AX,DX		  ; DX - BALL_Y > BALL_SIZE ( Y -> EXIT THIS PROC,N -> go to the next line
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			
		RET
	DRAW_BALL ENDP

CODE ENDS
END