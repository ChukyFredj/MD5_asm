BITS 64

section .bss
    state resb 16      ; Buffer for state
    message resb 64    ; Buffer pour message
    hex_result resb 33 ; Buffer pour résultat hexadécimal (32 caractères + terminateur nul)

section .data
    hex_digits db "0123456789abcdef", 0

section .text
global _start
global MD5_Transform

; MD5_Transform
; Routine de transformation MD5 optimisée pour processeurs x86-64

%define UseLea 0

%macro AA 5
%if UseLea
    lea %2, [%2 + %3 + %5]
%else
    add %1, %3
    add %1, %4
%endif
%endmacro

%macro JJ 4
%if %4 = 0
    %if M1
        ror rbp, 32
        %define M1 0
    %endif
    AA %1, rax, %2, ebp, rbp
%elif %4 = 1
    %if M1 = 0
        ror rbp, 32
        %define M1 1
    %endif
    AA %1, rax, %2, ebp, rbp
%elif %4 = 2
    %if M2
        ror r8, 32
        %define M2 0
    %endif
    AA %1, rax, %2, r8d, r8
%elif %4 = 3
    %if M2 = 0
        ror r8, 32
        %define M2 1
    %endif
    AA %1, rax, %2, r8d, r8
%elif %4 = 4
    %if M3
        ror r9, 32
        %define M3 0
    %endif
    AA %1, rax, %2, r9d, r9
%elif %4 = 5
    %if M3 = 0
        ror r9, 32
        %define M3 1
    %endif
    AA %1, rax, %2, r9d, r9
%elif %4 = 6
    %if M4
        ror r10, 32
        %define M4 0
    %endif
    AA %1, rax, %2, r10d, r10
%elif %4 = 7
    %if M4 = 0
        ror r10, 32
        %define M4 1
    %endif
    AA %1, rax, %2, r10d, r10
%elif %4 = 8
    %if M5
        ror r11, 32
        %define M5 0
    %endif
    AA %1, rax, %2, r11d, r11
%elif %4 = 9
    %if M5 = 0
        ror r11, 32
        %define M5 1
    %endif
    AA %1, rax, %2, r11d, r11
%elif %4 = 10
    %if M6
        ror r12, 32
        %define M6 0
    %endif
    AA %1, rax, %2, r12d, r12
%elif %4 = 11
    %if M6 = 0
        ror r12, 32
        %define M6 1
    %endif
    AA %1, rax, %2, r12d, r12
%elif %4 = 12
    %if M7
        ror r13, 32
        %define M7 0
    %endif
    AA %1, rax, %2, r13d, r13
%elif %4 = 13
    %if M7 = 0
        ror r13, 32
        %define M7 1
    %endif
    AA %1, rax, %2, r13d, r13
%elif %4 = 14
    %if M8
        ror r14, 32
        %define M8 0
    %endif
    AA %1, rax, %2, r14d, r14
%elif %4 = 15
    %if M8 = 0
        ror r14, 32
        %define M8 1
    %endif
    AA %1, rax, %2, r14d, r14
%endif
%endmacro

%macro FF 8
    JJ %1, %5, %6, %7
    mov esi, %2
    not esi
    and esi, %4
    mov edi, %3
    and edi, %2
    or esi, edi
    add %1, esi
    rol %1, %5
    add %1, %2
%endmacro

%macro GG 8
    JJ %1, %5, %6, %7
    mov esi, %4
    not esi
    and esi, %3
    mov edi, %4
    and edi, %2
    or esi, edi
    add %1, esi
    rol %1, %5
    add %1, %2
%endmacro

%macro HH 8
    JJ %1, %5, %6, %7
    mov esi, %4
    xor esi, %3
    xor esi, %2
    add %1, esi
    rol %1, %5
    add %1, %2
%endmacro

%macro II 8
    JJ %1, %5, %6, %7
    mov esi, %4
    not esi
    or esi, %2
    xor esi, %3
    add %1, esi
    rol %1, %5
    add %1, %2
%endmacro

MD5_Transform:
    ; sauvegarder les registres que l'appelant exige de restaurer
    push rbx
    push rsi
    push rdi
    push rbp
    push r12
    push r13
    push r14

    ; Premier paramètre passé dans RCX, deuxième - dans RDX
    ; State   - dans RCX
    ; Message - dans RDX

    %define M1 0
    %define M2 0
    %define M3 0
    %define M4 0
    %define M5 0
    %define M6 0
    %define M7 0
    %define M8 0

    mov r14, rdx ; Maintenant, l'offset du buffer du message est dans R14
    mov rsi, rcx ; Maintenant, l'offset de la structure d'état est dans RSI
    push rsi     ; State -> Stack
    mov eax, [rsi]
    mov ebx, [rsi + 4]
    mov ecx, [rsi + 8]
    mov edx, [rsi + 12]

    mov rbp, [r14 + 4 * 0]
    FF eax, ebx, ecx, edx, 0, 7, 0d76aa478h, rax  ; 1
    FF edx, eax, ebx, ecx, 1, 12, 0e8c7b756h, rdx  ; 2
    mov r8, [r14 + 4 * 2]
    FF ecx, edx, eax, ebx, 2, 17, 0242070dbh, rcx  ; 3
    FF ebx, ecx, edx, eax, 3, 22, 0c1bdceeeh, rbx  ; 4
    mov r9, [r14 + 4 * 4]
    FF eax, ebx, ecx, edx, 4, 7, 0f57c0fafh, rax  ; 5
    FF edx, eax, ebx, ecx, 5, 12, 04787c62ah, rdx  ; 6
    mov r10, [r14 + 4 * 6]
    FF ecx, edx, eax, ebx, 6, 17, 0a8304613h, rcx  ; 7
    FF ebx, ecx, edx, eax, 7, 22, 0fd469501h, rbx  ; 8
    mov r11, [r14 + 4 * 8]
    FF eax, ebx, ecx, edx, 8, 7, 0698098d8h, rax  ; 9
    FF edx, eax, ebx, ecx, 9, 12, 08b44f7afh, rdx  ; 10
    mov r12, [r14 + 4 * 10]
    FF ecx, edx, eax, ebx, 10, 17, 0ffff5bb1h, rcx  ; 11
    FF ebx, ecx, edx, eax, 11, 22, 0895cd7beh, rbx  ; 12
    mov r13, [r14 + 4 * 12]
    FF eax, ebx, ecx, edx, 12, 7, 06b901122h, rax  ; 13
    FF edx, eax, ebx, ecx, 13, 12, 0fd987193h, rdx  ; 14
    mov r14, [r14 + 4 * 14]
    FF ecx, edx, eax, ebx, 14, 17, 0a679438eh, rcx  ; 15
    FF ebx, ecx, edx, eax, 15, 22, 049b40821h, rbx  ; 16

    GG eax, ebx, ecx, edx, 1, 5, 0f61e2562h, rax  ; 17
    GG edx, eax, ebx, ecx, 6, 9, 0c040b340h, rdx  ; 18
    GG ecx, edx, eax, ebx, 11, 14, 0265e5a51h, rcx  ; 19
    GG ebx, ecx, edx, eax, 0, 20, 0e9b6c7aah, rbx  ; 20
    GG eax, ebx, ecx, edx, 5, 5, 0d62f105dh, rax  ; 21
    GG edx, eax, ebx, ecx, 10, 9, 002441453h, rdx  ; 22
    GG ecx, edx, eax, ebx, 15, 14, 0d8a1e681h, rcx  ; 23
    GG ebx, ecx, edx, eax, 4, 20, 0e7d3fbc8h, rbx  ; 24
    GG eax, ebx, ecx, edx, 9, 5, 021e1cde6h, rax  ; 25
    GG edx, eax, ebx, ecx, 14, 9, 0c33707d6h, rdx  ; 26
    GG ecx, edx, eax, ebx, 3, 14, 0f4d50d87h, rcx  ; 27
    GG ebx, ecx, edx, eax, 8, 20, 0455a14edh, rbx  ; 28
    GG eax, ebx, ecx, edx, 13, 5, 0a9e3e905h, rax  ; 29
    GG edx, eax, ebx, ecx, 2, 9, 0fcefa3f8h, rdx  ; 30
    GG ecx, edx, eax, ebx, 7, 14, 0676f02d9h, rcx  ; 31
    GG ebx, ecx, edx, eax, 12, 20, 08d2a4c8ah, rbx  ; 32

    HH eax, ebx, ecx, edx, 5, 4, 0fffa3942h, rax  ; 33
    HH edx, eax, ebx, ecx, 8, 11, 08771f681h, rdx  ; 34
    HH ecx, edx, eax, ebx, 11, 16, 06d9d6122h, rcx  ; 35
    HH ebx, ecx, edx, eax, 14, 23, 0fde5380ch, rbx  ; 36
    HH eax, ebx, ecx, edx, 1, 4, 0a4beea44h, rax  ; 37
    HH edx, eax, ebx, ecx, 4, 11, 04bdecfa9h, rdx  ; 38
    HH ecx, edx, eax, ebx, 7, 16, 0f6bb4b60h, rcx  ; 39
    HH ebx, ecx, edx, eax, 10, 23, 0bebfbc70h, rbx  ; 40
    HH eax, ebx, ecx, edx, 13, 4, 0289b7ec6h, rax  ; 41
    HH edx, eax, ebx, ecx, 0, 11, 0eaa127fah, rdx  ; 42
    HH ecx, edx, eax, ebx, 3, 16, 0d4ef3085h, rcx  ; 43
    HH ebx, ecx, edx, eax, 6, 23, 004881d05h, rbx  ; 44
    HH eax, ebx, ecx, edx, 9, 4, 0d9d4d039h, rax  ; 45
    HH edx, eax, ebx, ecx, 12, 11, 0e6db99e5h, rdx  ; 46
    HH ecx, edx, eax, ebx, 15, 16, 01fa27cf8h, rcx  ; 47
    HH ebx, ecx, edx, eax, 2, 23, 0c4ac5665h, rbx  ; 48

    II eax, ebx, ecx, edx, 0, 6, 0f4292244h, rax  ; 49
    II edx, eax, ebx, ecx, 7, 10, 0432aff97h, rdx  ; 50
    II ecx, edx, eax, ebx, 14, 15, 0ab9423a7h, rcx  ; 51
    II ebx, ecx, edx, eax, 5, 21, 0fc93a039h, rbx  ; 52
    II eax, ebx, ecx, edx, 12, 6, 0655b59c3h, rax  ; 53
    II edx, eax, ebx, ecx, 3, 10, 08f0ccc92h, rdx  ; 54
    II ecx, edx, eax, ebx, 10, 15, 0ffeff47dh, rcx  ; 55
    II ebx, ecx, edx, eax, 1, 21, 085845dd1h, rbx  ; 56
    II eax, ebx, ecx, edx, 8, 6, 06fa87e4fh, rax  ; 57
    II edx, eax, ebx, ecx, 15, 10, 0fe2ce6e0h, rdx  ; 58
    II ecx, edx, eax, ebx, 6, 15, 0a3014314h, rcx  ; 59
    II ebx, ecx, edx, eax, 13, 21, 04e0811a1h, rbx  ; 60
    II eax, ebx, ecx, edx, 4, 6, 0f7537e82h, rax  ; 61
    II edx, eax, ebx, ecx, 11, 10, 0bd3af235h, rdx  ; 62
    II ecx, edx, eax, ebx, 2, 15, 02ad7d2bbh, rcx  ; 63
    II ebx, ecx, edx, eax, 9, 21, 0eb86d391h, rbx  ; 64

    pop rsi            ; obtenir le pointeur d'état de la pile
    add [rsi], eax
    add [rsi + 4], ebx
    add [rsi + 8], ecx
    add [rsi + 12], edx

    ; restaurer les registres volatiles
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rdi
    pop rsi
    pop rbx

    ret

convert_to_hex:
    mov rsi, rcx                ; Pointeur vers le buffer d'état
    mov rdi, rdx                ; Pointeur vers le buffer du résultat hexadécimal
    mov rbx, hex_digits         ; Pointeur vers les chiffres hexadécimaux

    xor r8, r8                  ; Effacer r8 (index pour le résultat hexadécimal)
    .convert_loop:
        mov r9, r8
        shr r9, 1               ; r9 = r8 / 2
        mov al, byte [rsi + r9] ; Charger un octet depuis l'état
        test r8, 1
        jz .convert_high_nibble
        shr al, 4

    .convert_high_nibble:
        and al, 0xF
        movzx rax, al           ; Zéro-étendre al dans rax pour éviter un index incorrect
        mov bl, [rbx + rax]
        mov [rdi + r8], bl
        inc r8
        cmp r8, 32
        jb .convert_loop

    mov byte [rdi + 32], 0       ; Terminateur nul
    ret

_start:
    ; Initialiser l'état et le message
    lea rcx, [state]
    lea rdx, [message]
    mov rdi, rdx         ; Initialiser rdi avec l'adresse du buffer du message
    mov rax, "tset"      ; Charger "test" dans le message (en ordre inversé car little-endian)
    stosd

    ; Initialiser l'état avec des valeurs par défaut pour éviter des erreurs d'accès mémoire
    mov rdi, rcx
    mov rax, 0x67452301
    stosd
    mov rax, 0xefcdab89
    stosd
    mov rax, 0x98badcfe
    stosd
    mov rax, 0x10325476
    stosd

    ; Appeler la fonction MD5_Transform
    lea rcx, [state]
    lea rdx, [message]
    call MD5_Transform

    ; Convertir l'état en chaîne hexadécimale
    lea rcx, [state]
    lea rdx, [hex_result]
    call convert_to_hex

    ; Afficher le résultat
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    lea rsi, [hex_result]   ; pointeur vers le résultat hexadécimal
    mov rdx, 32             ; nombre d'octets
    syscall

    ; Sortie du programme
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; statut: 0
    syscall
