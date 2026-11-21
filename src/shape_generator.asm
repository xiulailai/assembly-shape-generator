; ============================================================
; SHAPE GENERATION SYSTEM - NASM Assembly (64-bit Linux)
; ============================================================
; Fixed version with proper register handling and validation
; ============================================================

global _start

section .data
    ; Menu and prompts
    menu_title      db 10, "=== SHAPE GENERATION SYSTEM ===", 10, 0
    menu_title_len  equ $ - menu_title

    menu_opt1       db "1. Draw Rectangle", 10, 0
    menu_opt1_len   equ $ - menu_opt1

    menu_opt2       db "2. Draw Square", 10, 0
    menu_opt2_len   equ $ - menu_opt2

    menu_opt3       db "3. Draw Triangle (Right-angled)", 10, 0
    menu_opt3_len   equ $ - menu_opt3

    menu_opt4       db "4. Draw Circle (Approximation)", 10, 0
    menu_opt4_len   equ $ - menu_opt4

    menu_opt5       db "5. Exit", 10, 0
    menu_opt5_len   equ $ - menu_opt5

    prompt_choice   db 10, "Enter choice (1-5): ", 0
    prompt_choice_len equ $ - prompt_choice

    prompt_width    db "Enter width (1-80): ", 0
    prompt_width_len equ $ - prompt_width

    prompt_height   db "Enter height (1-30): ", 0
    prompt_height_len equ $ - prompt_height

    prompt_size     db "Enter size (1-30): ", 0
    prompt_size_len equ $ - prompt_size

    prompt_radius   db "Enter radius (1-15): ", 0
    prompt_radius_len equ $ - prompt_radius

    ; Error messages
    err_invalid     db 10, "ERROR: Invalid choice! Please enter 1-5.", 10, 0
    err_invalid_len equ $ - err_invalid

    err_range       db "ERROR: Value out of range!", 10, 0
    err_range_len   equ $ - err_range

    err_input       db "ERROR: Invalid input format!", 10, 0
    err_input_len   equ $ - err_input

    msg_exit        db 10, "Thank you for using Shape Generator!", 10, 0
    msg_exit_len    equ $ - msg_exit

    ; Drawing characters
    star            db '*'
    space           db ' '
    newline         db 10

    ; Input buffer
    input_buffer    times 10 db 0

section .bss
    choice          resb 1
    param1          resd 1      ; width/size/radius
    param2          resd 1      ; height
    current_row     resd 1
    current_col     resd 1

section .text

; ============================================================
; UTILITY FUNCTIONS
; ============================================================

; Print string to stdout
; Input: rsi = string address, rdx = length
print_string:
    push rax
    push rdi
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    syscall
    pop rdi
    pop rax
    ret

; Print single character
; Input: al = character to print
print_char:
    push rsi
    push rdx
    push rdi
    push rax

    mov byte [input_buffer], al
    lea rsi, [rel input_buffer]
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    pop rax
    pop rdi
    pop rdx
    pop rsi
    ret

; Print newline
print_newline:
    push rax
    mov al, 10
    call print_char
    pop rax
    ret

; Read input from stdin
; Output: rax = number read, or -1 on error
read_input:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    ; Clear input buffer
    lea rdi, [rel input_buffer]
    mov rcx, 10
    xor al, al
    rep stosb

    ; Read from stdin
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    lea rsi, [rel input_buffer]
    mov rdx, 10
    syscall

    ; Check if read was successful
    cmp rax, 0
    jle .error

    ; Convert string to number
    lea rsi, [rel input_buffer]
    xor rax, rax            ; result = 0
    xor rbx, rbx            ; temp for digit

.convert_loop:
    movzx rbx, byte [rsi]

    ; Check for newline or null
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done

    ; Check if digit
    cmp bl, '0'
    jb .error
    cmp bl, '9'
    ja .error

    ; result = result * 10 + digit
    sub bl, '0'
    imul rax, 10
    add rax, rbx

    inc rsi
    jmp .convert_loop

.error:
    mov rax, -1
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================
; SHAPE DRAWING FUNCTIONS
; ============================================================

; Draw Rectangle
; Input: [param1] = width, [param2] = height
draw_rectangle:
    push rax
    push rbx
    push rcx
    push rdx

    ; Initialize row counter
    mov dword [rel current_row], 0

.row_loop:
    mov eax, [rel current_row]
    cmp eax, [rel param2]
    jge .done

    ; Initialize column counter
    mov dword [rel current_col], 0

.col_loop:
    mov eax, [rel current_col]
    cmp eax, [rel param1]
    jge .end_row

    ; Print star
    mov al, '*'
    call print_char

    ; Increment column
    inc dword [rel current_col]
    jmp .col_loop

.end_row:
    call print_newline
    inc dword [rel current_row]
    jmp .row_loop

.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Draw Square
; Input: [param1] = size
draw_square:
    push rax

    ; Set height = width
    mov eax, [rel param1]
    mov [rel param2], eax
    call draw_rectangle

    pop rax
    ret

; Draw Right-angled Triangle
; Input: [param1] = size (height)
draw_triangle:
    push rax
    push rbx
    push rcx
    push rdx

    mov dword [rel current_row], 0

.row_loop:
    mov eax, [rel current_row]
    cmp eax, [rel param1]
    jge .done

    ; Number of stars = row number + 1
    mov ebx, eax
    inc ebx
    mov dword [rel current_col], 0

.col_loop:
    mov eax, [rel current_col]
    cmp eax, ebx
    jge .end_row

    mov al, '*'
    call print_char

    inc dword [rel current_col]
    jmp .col_loop

.end_row:
    call print_newline
    inc dword [rel current_row]
    jmp .row_loop

.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Draw Circle (using Midpoint Circle Algorithm)
; Input: [param1] = radius
draw_circle:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov r12d, [rel param1]      ; r12 = radius

    ; Calculate grid dimensions
    mov ecx, r12d
    shl ecx, 1                  ; diameter = 2 * radius
    inc ecx                     ; +1 for center
    mov r15d, ecx               ; save grid size

    ; Initialize row counter
    mov dword [rel current_row], 0

.row_loop:
    mov eax, [rel current_row]
    cmp eax, r15d
    jge .done

    ; Initialize column counter
    mov dword [rel current_col], 0

.col_loop:
    mov eax, [rel current_col]
    cmp eax, r15d
    jge .end_row

    ; Check if this point should be drawn
    ; Use Midpoint Circle Algorithm to determine

    ; Calculate relative position from center
    mov r8d, [rel current_col]
    sub r8d, r12d               ; dx = col - radius

    mov r9d, [rel current_row]
    sub r9d, r12d               ; dy = row - radius

    ; Calculate distance squared: dx² + dy²
    mov eax, r8d
    imul eax, eax               ; dx²
    mov r10d, eax

    mov eax, r9d
    imul eax, eax               ; dy²
    add r10d, eax               ; dist² in r10d

    ; Calculate radius²
    mov eax, r12d
    imul eax, eax               ; radius²
    mov r11d, eax

    ; Calculate inner radius² (radius - 1)²
    mov eax, r12d
    dec eax
    cmp eax, 0
    jl .use_zero
    imul eax, eax
    jmp .got_inner
.use_zero:
    xor eax, eax
.got_inner:
    mov r13d, eax               ; inner_radius²

    ; Check if point is on the circle edge
    ; inner_radius² <= dist² <= radius²
    cmp r10d, r13d
    jl .print_space             ; too close to center
    cmp r10d, r11d
    jg .print_space             ; too far from center

    ; Print star (on circle edge)
    mov al, '*'
    call print_char
    jmp .next_col

.print_space:
    mov al, ' '
    call print_char

.next_col:
    inc dword [rel current_col]
    jmp .col_loop

.end_row:
    call print_newline
    inc dword [rel current_row]
    jmp .row_loop

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================
; MAIN PROGRAM
; ============================================================

_start:
    ; Main program loop
main_loop:
    ; Display menu
    lea rsi, [rel menu_title]
    mov rdx, menu_title_len
    call print_string

    lea rsi, [rel menu_opt1]
    mov rdx, menu_opt1_len
    call print_string

    lea rsi, [rel menu_opt2]
    mov rdx, menu_opt2_len
    call print_string

    lea rsi, [rel menu_opt3]
    mov rdx, menu_opt3_len
    call print_string

    lea rsi, [rel menu_opt4]
    mov rdx, menu_opt4_len
    call print_string

    lea rsi, [rel menu_opt5]
    mov rdx, menu_opt5_len
    call print_string

    ; Get user choice
    lea rsi, [rel prompt_choice]
    mov rdx, prompt_choice_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    mov [rel choice], al

    ; Process choice
    cmp byte [rel choice], 1
    je handle_rectangle
    cmp byte [rel choice], 2
    je handle_square
    cmp byte [rel choice], 3
    je handle_triangle
    cmp byte [rel choice], 4
    je handle_circle
    cmp byte [rel choice], 5
    je exit_program

    ; Invalid choice
    jmp invalid_choice

; ============================================================
; MENU HANDLERS
; ============================================================

handle_rectangle:
    ; Get width
    lea rsi, [rel prompt_width]
    mov rdx, prompt_width_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    ; Validate width (1-80)
    cmp rax, 1
    jl invalid_range
    cmp rax, 80
    jg invalid_range

    mov [rel param1], eax

    ; Get height
    lea rsi, [rel prompt_height]
    mov rdx, prompt_height_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    ; Validate height (1-30)
    cmp rax, 1
    jl invalid_range
    cmp rax, 30
    jg invalid_range

    mov [rel param2], eax

    call print_newline
    call draw_rectangle
    jmp main_loop

handle_square:
    ; Get size
    lea rsi, [rel prompt_size]
    mov rdx, prompt_size_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    ; Validate size (1-30)
    cmp rax, 1
    jl invalid_range
    cmp rax, 30
    jg invalid_range

    mov [rel param1], eax

    call print_newline
    call draw_square
    jmp main_loop

handle_triangle:
    ; Get size
    lea rsi, [rel prompt_size]
    mov rdx, prompt_size_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    ; Validate size (1-30)
    cmp rax, 1
    jl invalid_range
    cmp rax, 30
    jg invalid_range

    mov [rel param1], eax

    call print_newline
    call draw_triangle
    jmp main_loop

handle_circle:
    ; Get radius
    lea rsi, [rel prompt_radius]
    mov rdx, prompt_radius_len
    call print_string

    call read_input
    cmp rax, -1
    je invalid_input

    ; Validate radius (1-15) - reduced to prevent overflow
    cmp rax, 1
    jl invalid_range
    cmp rax, 15
    jg invalid_range

    mov [rel param1], eax

    call print_newline
    call draw_circle
    jmp main_loop

; ============================================================
; ERROR HANDLERS
; ============================================================

invalid_choice:
    lea rsi, [rel err_invalid]
    mov rdx, err_invalid_len
    call print_string
    jmp main_loop

invalid_input:
    lea rsi, [rel err_input]
    mov rdx, err_input_len
    call print_string
    jmp main_loop

invalid_range:
    lea rsi, [rel err_range]
    mov rdx, err_range_len
    call print_string
    jmp main_loop

; ============================================================
; EXIT
; ============================================================

exit_program:
    lea rsi, [rel msg_exit]
    mov rdx, msg_exit_len
    call print_string

    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; exit code 0