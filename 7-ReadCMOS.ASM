    ;��ʾ���򣨹�������dp81.asm
    ;������ʾ��ǰʱ�䣨����������ɼ��ظ�ʽ��
        section   text
        bits   16
    ;�ɼ��ظ�ʽ��ͷ��
;
    Signature     db   "SIN "       ;ǩ����Ϣ
    Version       dw   1            ;��ʽ�汾
    Length        dw   end_of_text  ;�������򳤶�
    Entry         dw   Begin        ;����������ڵ��ƫ��
    ExpectedSeg   dw   0088H        ;���������������ڴ�������ʼ��ֵ
    Reserved      dd   0            ;����
;
    ;
    Begin:
        PUSH  CS
        POP   DS                    ;���ݶ���������ͬ
    NEXT:
        MOV   AL, 2                 ;�ֵ�Ԫ��ַ
        OUT   70H, AL               ;׼����ȡ�ֵ�Ԫ
        IN    AL, 71H               ;����ֵBCD��
        MOV   [minute], AL          ;����֮
        ;
        MOV   AL, 0                 ;�뵥Ԫ��ַ
        OUT   70H, AL               ;׼����ȡ�뵥Ԫ
        IN    AL, 71H               ;����ֵBCD��
        MOV   [second], AL          ;����֮
        ;
		MOV	  AL, 4
		OUT   70H, AL
		IN    AL, 71H
		MOV   [hour], AL
		;
		
		MOV	  AL, 09H
		OUT   70H, AL
		IN    AL, 71H
		MOV   [year], AL
		;
		
		MOV	  AL, 08H
		OUT   70H, AL
		IN    AL, 71H
		MOV   [month], AL
		;
		MOV	  AL, 07H
		OUT   70H, AL
		IN    AL, 71H
		MOV   [day], AL
		;
		MOV AL, [year]
		CALL EchoBCD
		MOV AL,'/'
		CALL PutChar
		MOV AL,[month]
		CALL EchoBCD
		MOV AL,'/'
		CALL PutChar
		MOV AL,[day]
		CALL EchoBCD
		MOV AL,' ' 
		CALL PutChar
		
		
		MOV   AL,[hour]
		CALL  EchoBCD
		MOV   AL, ':'
		CALL  PutChar
        MOV   AL, [minute]
        CALL  EchoBCD               ;��ʾʱ�ӵķ�ֵ
        MOV   AL, ':'
        CALL  PutChar               ;��ʾ�����
        MOV   AL, [second]
        CALL  EchoBCD               ;��ʾʱ�ӵ���ֵ
        MOV   AL, 0DH               ;�γɻس�����Ч��
        CALL  PutChar
        MOV   AL, 0AH
        CALL  PutChar
        ;
        MOV   AH, 0                 ;�ȴ��������û�����
        INT   16H
        CMP   AL, 0DH               ;������س���������
        JNZ   NEXT                  ;�����ٴ���ʾ��ǰʱ��
        ;
        RETF                        ;���������ص���������
    ;
    EchoBCD:                        ;��ʾ2λBCD��
        PUSH  AX
        SHR   AL, 4                 ;�Ѹ�λBCD��ת��ASCII��
        ADD   AL, '0'
        CALL  PutChar               ;��ʾ֮
        POP   AX
        AND   AL, 0FH               ;�ѵ�λBCD��ת��ASCII��
        ADD   AL, '0'
        CALL  PutChar               ;��ʾ֮
        RET
   PutChar:                         ;TTY��ʽ��ʾһ���ַ�
        MOV   BH, 0
        MOV   AH, 14
        INT   10H
        RET
        ;
		;*********************   
		; �ӳ�����ʾ�ַ�   
		; ��ڲ�����DS:DX=����ַ   
		; ����ֵ����   
		;*********************   
	PutStr:   
		push ax   
        mov ah,09h   
        int 21h   
        pop ax   
        ret  
    second   DB   0                 ;��BCD�뱣�浥Ԫ
    minute   DB   0                 ;��BCD�뱣�浥Ԫ
	hour     DB   0
	year db 0
	month db 0
	day db 0
    end_of_text:                    ;����λ��