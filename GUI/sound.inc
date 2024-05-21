.CODE
;?sound effect:start
    sound_effect PROC NEAR
        ; Set up the tone parameters
        mov al, 0B6h    ; Set timer 2 mode (square wave generator)
        out 43h, al     ; Send mode command to timer 2
        mov ax, 0E9C4h  ; Set the frequency (adjust this for different tones)
        out 42h, al     ; Send low byte of frequency
        mov al, ah
        out 42h, al     ; Send high byte of frequency

        ; Enable speaker output
        in al, 61h      ; Read current value from port 61h
        or al, 3        ; Set bits 0 and 1 to enable speaker (bits 0 and 1)
        out 61h, al     ; Send the new value to port 61h

        ; Wait a bit for the sound to play
        mov cx, 0FFFFh   ; Adjust this delay for longer or shorter beeps
        delay_loop:
        loop delay_loop

        ; Disable speaker output
        in al, 61h      ; Read current value from port 61h
        and al, 0FCh    ; Clear bits 0 and 1 to disable speaker (bits 0 and 1)
        out 61h, al     ; Send the new value to port 61h

        RET
    sound_effect ENDP

    soundEffect PROC NEAR
        call sound_effect
        call sound_effect
    RET
    soundEffect ENDP
;?sound effect:end