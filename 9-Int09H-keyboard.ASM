    ;��ʾ���򣨹�������dp84.asm
    ;��ʾ�����жϴ������򣨲���������ɼ��ظ�ʽ��
    PORT_KEY_DAT   EQU   0x60
    PORT_KEY_STA   EQU   0x64
    ;
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
    Begin:
		MOV AX,CS
		MOV DS,AX	;DS=CS
		;
		MOV SI,tips1
		CALL PutStr
		
		MOV SI,tips2
		CALL PutStr
		
		;
		MOV SI,09H*4
		MOV AX,0	
		MOV ES,AX	;ES=0
		;
		MOV AX,[ES:SI]		;ԭ�ж�ƫ��
		MOV [old09h], AX
		MOV AX,[ES:SI+2]	;ԭ�ж϶�ֵ
		MOV [old09h+2], AX
		
		
        MOV   AX, 0                     ;׼�������ж�����
        MOV   DS, AX
        CLI
        MOV   WORD [9*4], int09h_handler
        MOV   [9*4+2], CS               ;�����µļ����жϴ�������
        STI
        ;
    Next:                               ;��ʾ�������ʾ����
        MOV   AH, 0                     ;���ü���I/O����
        INT   16H                       ;��ȡ�û�����
        ;
        MOV   AH, 14                    ;��ʾȡ�õ��ַ���������
        INT   10H
        ;
		;CMP   AL, ' '					
		;JZ    restore_09H_handler
		;
        CMP   AL, 0DH                   ;�س�����
        JNZ   Next                      ;�������
		

        ;
        MOV   AH, 14                    ;Ϊ����ʾЧ��
        MOV   AL, 0AH                   ;��ʾһ������
        INT   10H
        ;
        ;RETF                            ;���������ص���������
	restore_09H_handler:
		MOV AX,0
		MOV ES,AX
		MOV SI, 09H*4
		MOV EAX, [CS:old09h]
		MOV [ES:SI], EAX
		RETF
    ;-----------------------------------
    int09h_handler:                     ;�µ�9�ż����жϴ�������
        PUSHA                           ;����ͨ�üĴ���
        ;
        MOV   AL, 0ADH
        OUT   PORT_KEY_STA, AL          ;��ֹ���̷������ݵ��ӿ�
        ;
        IN    AL, PORT_KEY_DAT          ;�Ӽ��̽ӿڶ�ȡ����ɨ����
        ;
        STI                             ;���ж�
        CALL  Int09hfun                 ;�����ع���
        ;
        CLI                             ;���ж�
        MOV   AL, 0AEH
        OUT   PORT_KEY_STA, AL          ;�������̷������ݵ��ӿ�
        ;
        MOV   AL, 20H                   ;֪ͨ�жϿ�����8259A
        OUT   20H, AL                   ;��ǰ�жϴ����Ѿ�����
        ;
        POPA                            ;�ָ�ͨ�üĴ���
        ;
        IRET                            ;�жϷ���
    ;-----------------------------------
    Int09hfun:                          ;��ʾ9H���жϴ�������ľ��幦��
        CMP   AL, 1CH                   ;�жϻس�����ɨ����
        JNZ   .LAB1                     ;�ǻس�����ת
        MOV   AH, AL                    ;�س���������ɨ����
        MOV   AL, 0DH                   ;�س���ASCII��
        JMP   SHORT .LAB2
    .LAB1:                              ;��ʶ����QWERTYUIOPʮ����
        CMP   AL, 10H                   ;�ж���ĸQ��ɨ����
        JB    .LAB3                     ;���ڣ���ֱ�Ӷ���
        CMP   AL, 19H                   ;�ж���ĸP��ɨ����
        JA    .LAB3                     ;���ڣ���ֱ�Ӷ���
        MOV   AH, AL                    ;����ɨ����
        ADD   AL, 20H                   ;����ʾ����ת�ɶ�Ӧ��ASCII��
    .LAB2:
        CALL  Enqueue                   ;���浽���̻�����
    .LAB3:
        RET                             ;����
    ;-----------------------------------
    Enqueue:                            ;��ɨ�����ASCII�������̻�����
        PUSH  DS                        ;����DS
        MOV   BX, 40H
        MOV   DS, BX                    ;DS=0040H
        MOV   BX, [001CH]               ;ȡ���е�βָ��
        MOV   SI, BX                    ;SI=����βָ��
        ADD   SI, 2                     ;SI=��һ������λ��
        CMP   SI, 003EH                 ;Խ������������
        JB    .LAB1                     ;û�У�ת
        MOV   SI, 001EH                 ;�ǵģ�ѭ����������ͷ��
    .LAB1:
        CMP   SI, [001AH]               ;�����ͷָ��Ƚ�
        JZ    .LAB2                     ;��ȱ�ʾ�������Ѿ���
        MOV   [BX], AX                  ;��ɨ�����ASCII���������
        MOV    [001CH], SI              ;�������βָ��
    .LAB2:
        POP   DS                        ;�ָ�DS
        RET                             ;����
	;-----------------------------------------------
	old09h   DD   0                 ;���ڱ���ԭ09H���ж�����
	tips1	DB "Here is the new INT 09H keyboard handler",0ah,0dh,0
	tips2	DB "Q=0 W=2 ... P=9",0ah,0dh,0
	;-----------------------------------------------
	;------------------------------------------------
	;------------------;
;��ڲ���SI
PutStr:
LODSB
OR AL,AL
JZ PutStr_OK
MOV AH,14
INT 10H
JMP SHORT PutStr
PutStr_OK:
RET
;------------------;
    end_of_text:                        ;����λ��