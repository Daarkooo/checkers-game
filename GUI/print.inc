.DATA
    strDS   DB  'DS: $'
    strCS   DB  'CS: $'
    strSS   DB  'SS: $'
    strES   DB  'ES: $'
    strSI   DB  'SI: $'
    strDI   DB  'DI: $'
    strAX   DB  'AX: $'
    strBX   DB  'BX: $'
    strCX   DB  'CX: $'
    strDX   DB  'DX: $'
    newLine DB  10, 13, '$'

.CODE
    __printDecimal PROC
        PUSH BP
        MOV BP, SP

        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI

        MOV AX, [BP + 4]
        MOV CX, 10

        MOV BX, 0FFFFh
        PUSH BX

        printDecimal_L1:
            XOR DX, DX
            DIV CX
            PUSH DX
            TEST AX, AX
        JNZ printDecimal_L1

        POP DX

        printDecimal_L2:
            CMP DX, 0FFFFh
            JZ printDecimal_end

            ADD DL, '0'
            MOV AX, 0200h
            INT 21h

            POP DX
        JMP printDecimal_L2

        printDecimal_end:

        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX

        MOV SP, BP
        POP BP
        RET 2
    __printDecimal ENDP

    printDecimal MACRO num
        PUSH AX

        MOV AX, num
        PUSH AX

        CALL __printDecimal
        POP AX
    ENDM

    print_string MACRO ref
        PUSH AX
        PUSH DX

        MOV AX, 0900h
        LEA DX, ref
        INT 21h

        POP DX
        POP AX
    ENDM

    printSegments MACRO
        print_string strCS
        printDecimal CS
        print_string newLine

        print_string strDS
        printDecimal DS
        print_string newLine

        print_string strSS
        printDecimal SS
        print_string newLine

        print_string strES
        printDecimal ES
        print_string newLine
        print_string newLine
    ENDM

    liveUsage PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI

        print_string strAX
        printDecimal AX
        print_string newLine

        print_string strBX
        printDecimal BX
        print_string newLine

        print_string strCX
        printDecimal CX
        print_string newLine

        print_string strDX
        printDecimal DX
        print_string newLine

        print_string strSI
        printDecimal SI
        print_string newLine

        print_string strDI
        printDecimal DI
        print_string newLine

        print_string newLine

        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX

        RET
    liveUsage ENDP