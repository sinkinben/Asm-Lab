    ;��ʾ���򣨹�������dp85.asm
    ;��ʾ���������жϴ������򣨲���������ɼ��ظ�ʽ��
        section   text
        bits   16
    ;�ɼ��ع�������ͷ��������Ϣ
;
    Signature     db   "SIN "       ;ǩ����Ϣ
    Version       dw   1            ;��ʽ�汾
    Length        dw   end_of_text  ;�������򳤶�
    Entry         dw   Begin        ;����������ڵ��ƫ��
    ExpectedSeg   dw   0088H        ;���������������ڴ�������ʼ��ֵ
    Reserved      dd   0            ;����
;
    ;-------------------------------
    Begin:                              ;��ʾ����ĳ�ʼ��
        MOV   AX, 0                     ;׼�������ж�����
        MOV   DS, AX
        CLI                             ;���ж�
        MOV   WORD [0*4], int00h_handler;����0���ж�����֮ƫ��
        MOV   [0*4+2], CS               ;����0���ж�����֮��ֵ
        STI                             ;���ж�
        ;
        ;MOV   BH, 0
        ;MOV   AH, 14
        ;MOV   AL, '#'
        ;INT   10H                       ;Ϊ��ʾ�⣬��ʾ����
        ;
        ;MOV   AX, 600                   ;��ʾ������
        ;MOV   BL, 2
        ;DIV   BL                        ;�������������//@1
		;-----------------------------------------------------
		CLD
		MOV  AX,CS
		MOV  DS,AX		;DS=CS
		MOV  ES,AX		;ES=CS
		;print A=
		MOV SI, A
		CALL MyPutStr
		
		;input A str
		mov dx, buffer
		call GetStr
		MOV   AL, 0DH               ;�γɻس�����Ч��
		CALL  PutChar
		MOV   AL, 0AH
		CALL  PutChar
		
		;ת��A
		MOV  SI, buffer+1
		CALL DSTOB
		PUSH EAX
		
		;print B=
		mov si, B
		call MyPutStr
		
		;input B str
		MOV  DX, buffer
		CALL GetStr
		MOV   AL, 0DH               ;�γɻس�����Ч��
		CALL  PutChar
		MOV   AL, 0AH
		CALL  PutChar
		
		;ת��
		MOV  SI, buffer+1
		CALL DSTOB
		
		mov ebx,eax
		pop eax
		xor edx,edx		;eax div ebx = eax ... edx
		div ebx
		
		mov bl, [is_iret]
		test bl,bl
		jnz LABV
		
		;�����̺�����
		push eax
		push edx
		
		mov si, result
		call MyPutStr
		pop edx
		pop eax
		
		;print dec of eax
		call BIN2DEC
		
		push edx
		mov si, points
		call MyPutStr
		pop edx
		;print dec of edx
		mov eax,edx
		call BIN2DEC
		
		MOV   AL, 0DH               ;�γɻس�����Ч��
		CALL  PutChar
		MOV   AL, 0AH
		CALL  PutChar
		;-----------------------------------------------------
    LABV:
        ;
        MOV   AH, 14
        MOV   AL, 0DH                   ;�γɻس�
        INT   10H
        MOV   AL, 0AH                   ;�γɻ���
        INT   10H
        ;
        RETF                            ;���������ص���������
    ;-----------------------------------
    ;00H���жϴ������򣨳������жϴ�������
    int00h_handler:                      
        STI                             ;���ж�//@2
        PUSHA                           ;����ͨ�üĴ���//@3
        PUSH  DS                        ;����DS//@4
        MOV   BP, SP
        ;
        PUSH  CS
        POP   DS                        ;ʹDS=CS
        MOV   DX, mess                  ;ָ����ʾ��Ϣ
        CALL  PutStr                    ;��ʾ��ʾ��Ϣ
        ;
        ADD   WORD [BP+18], 2           ;�������ص�ַ! //@5
        ;
		inc byte [is_iret]
        POP   DS                        ;�ָ�DS
        POPA                            ;�ָ�ͨ�üĴ���
        ;
        IRET                            ;�жϷ���
        ;
	;----------------data buffer-----------------------------
	is_iret db 0
	points db "...",0
    mess   db   "#Divide Overflow!!!!", 0    ;��ʾ��Ϣ
	buffer:                         ;������
    db    9                     ;���������ַ�������
    db    "000000000",0           ;����ַ���
	A   DB "A=",0
	B   DB "B=",0
	result DB "A/B=",0
	;---------------------------------------------
    ;
    PutStr:                             ;��ʾ�ַ�������0��β��
		;����
		PUSH CS
		PUSH DS
		;
		PUSH  CS
        POP   DS                        ;ʹDS=CS
        MOV   BH, 0
        MOV   SI, DX                    ;DX=�ַ�����ʼ��ַƫ��
    .LAB1:
        LODSB
        OR    AL, AL
        JZ    .LAB2
        MOV   AH, 14
        INT   10H
        JMP   .LAB1
    .LAB2:
		POP DS
		POP CS
        RET
	;-----------------------------------------------
	;-------------------------------
    %define  Space      20H         ;�ո��
    %define  Enter      0DH         ;�س���
    %define  Backspace  08H         ;�˸�
    %define  Bell       07H         ;����
    ;�ӳ�������GetStr
    ;��    �ܣ�����һ���ַ���
    ;��ڲ�����DS:DX=�������׵�ַ
    ;˵    ������1����������һ���ֽ������ַ�������
    ;          ��2�����ص��ַ����Իس�����0DH����β
    GetStr:
        PUSH  SI
        MOV   SI, DX
        MOV   CL, [SI]              ;ȡ�û��������ַ�������
        CMP   CL, 1                 ;��С��1��ֱ�ӷ���
        JB    .Lab6
        ;
        INC   SI                    ;ָ���ַ������׵�ַ
        XOR   CH, CH                ;CH��Ϊ�ַ����е��ַ�������������
    .Lab1:
        CALL  GetChar               ;��ȡһ���ַ�
        OR    AL, AL                ;��Ϊ���ܼ���ֱ�Ӷ���//@1
        JZ    SHORT  .Lab1
        CMP   AL, Enter             ;��Ϊ�س�������ʾ�����ַ�������
        JZ    SHORT  .Lab5          ;ת�������
        CMP   AL,  Backspace        ;��Ϊ�˸��
        JZ    SHORT  .Lab4          ;ת�˸���
        CMP   AL, Space             ;��Ϊ����������ʾ�ַ�������//@2
        JB    SHORT  .Lab1
        ;
        cmp   al, '0'
        jb    short  .Lab1          ;С�����ַ�������
        cmp   al, '9'
        ja    short  .Lab1          ;�������ַ�������
        ;
        CMP   CL, 1                 ;�ַ����еĿռ��Ƿ����ࣿ
        JA    SHORT  .Lab3          ;�ǣ�ת�����ַ�������
    .Lab2:
        MOV   AL, Bell
        CALL  PutChar               ;��������
        JMP   SHORT  .Lab1          ;���������ַ�
        ;
    .Lab3:
        CALL  PutChar               ;��ʾ�ַ�
        MOV   [SI], AL              ;���浽�ַ���
        INC   SI                    ;�����ַ����еĴ��λ��
        INC   CH                    ;�����ַ����е��ַ�����
        DEC   CL                    ;�����ַ����еĿռ����
        JMP   SHORT  .Lab1          ;���������ַ�
        ;
    .Lab4:                          ;�˸���
        CMP   CH, 0                 ;�ַ������Ƿ����ַ���
        JBE   .Lab2                 ;û�У���������
        CALL  PutChar               ;������
        MOV   AL, Space
        CALL  PutChar               ;�ÿո�����ַ�
        MOV   AL, Backspace
        CALL  PutChar               ;�ٴι�����
        DEC   SI                    ;�����ַ����еĴ��λ��
        DEC   CH                    ;�����ַ����е��ַ�����
        INC   CL                    ;�����ַ����еĿռ����
        JMP   SHORT  .Lab1          ;���������ַ�
        ;
    .Lab5:
        MOV    [SI], AL             ;�������Ļس���
    .Lab6:
        POP   SI
        RET
;-------------------------------
;-------------------------------

PutChar:                        ;��ʾһ���ַ�
    MOV   BH, 0
    MOV   AH, 14
    INT   10H
    RET
    ;
GetChar:                        ;��������һ���ַ�
    MOV   AH, 0
    INT   16H
    RET
;-------------------------------
;-------------------------------
    DSTOB:                          ;�����ִ�ת���ɶ�Ӧ�Ķ�����ֵ
        XOR   EAX, EAX
        XOR   EDX, EDX
    .next:
        LODSB                       ;ȡһ�����ַ�
        CMP   AL, 0DH
        JZ    .ok
        AND   AL, 0FH
        IMUL  EDX, 10
        ADD   EDX, EAX
        JMP   SHORT .next
    .ok:
        MOV   EAX, EDX              ;EAX���ض�����ֵ
        RET
;-------------------------------
;-------------------------------
BIN2DEC:
	PUSH EDX
	PUSH EBX
	PUSH ECX
	XOR EDX,EDX
	XOR ECX,ECX
	MOV EBX,10
	CMP EAX,0
	JNE BIN2DEC_LOOP
	MOV AL,'0'
	CALL PutChar
	RET
BIN2DEC_LOOP:
	CMP EAX,0
	JE  BIN2DEC_OK
	DIV EBX
	ADD EDX,'0'
	PUSH EDX
	INC ECX
	XOR EDX,EDX
	JMP BIN2DEC_LOOP
BIN2DEC_OK:
	POP EDX
	MOV AL, DL
	CALL PutChar
	LOOP BIN2DEC_OK
	POP ECX
	POP EBX
	POP EDX
	RET
;-------------------------------
;----------------------------
;SIָ���ַ���
MyPutStr:
	LODSB
	OR AL,AL
	JZ MyPutStr_OK
	MOV AH,14
	INT 10H
	JMP SHORT MyPutStr
MyPutStr_OK:
	RET
;-------------------------------
    end_of_text:                        ;����λ��