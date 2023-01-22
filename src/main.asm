;;  This file is part of FORTH86
;;  FORTH86 is free software: you can redistribute it and/or modify it 
;;  under the terms of the GNU General Public License as published by the 
;;  Free Software Foundation, either version 3 of the License, 
;;  or (at your option) any later version.
;;  This program is distributed in the hope that it will be useful, 
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of 
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
;;  See the GNU General Public License for more details.
;;  You should have received a copy of the GNU General Public License 
;;  along with this program. If not, see <https://www.gnu.org/licenses/>. 

extern exit
extern find_word
extern parse_int64
extern print_int64
extern print_newline
extern print_string
extern read_char
extern read_word


%include "macros.inc"

%define forth_rstack r15
%define forth_pc     r14
%define forth_word   r13
%define forth_memory r12
%define exec_token   rax

section .data
unknown_word: db "Unknown word, please check documentation", 0xa, 0

program_stub: dq 0
extok_interpret: dq .interpreter
.interpreter: dq interpreter_loop

; machine reserved data
; reserve memory cells and return stack
; data stack will be the machine's own stack during execution
section .bss
memory_cells: resq 65536
input_buf: resb 1024
resq 1023
return_stack: resq 1


%define cfa code_from_address
section .text

;; Forth words

; arithmetic operations, I don't check for CF and OF yet.
; until I can think of a good way to check for overflows
; I will leave it unimplemented

native '+', plus
    pop rax
    add [rsp], rax
    jmp do_nextw

native '-', minus
    pop rax
    sub [rsp], rax  ; [rsp] - rax
    jmp do_nextw

native '*', multiply
    xor edx, edx
    pop rax
    imul qword[rsp]
    mov [rsp], rax
    jmp do_nextw

native '/', divide
    pop rax ; second
    pop rdx ; first ( 2 3 -- ) - rax : 3, rdx : 2 ; order as pushed to stack 
    push rax
    mov rax, rdx
    xor edx, edx
    idiv qword [rsp]
    mov [rsp], rax
    jmp do_nextw

native '%', remainder
    pop rax
    pop rdx
    push rax
    mov rax, rdx
    xor edx, edx
    idiv qword[rsp]
    mov [rsp], rdx
    jmp do_nextw

native '.', print_num
    pop rdi
    call print_int64
    call print_newline
    jmp do_nextw

; logical words
native '=', equality
    pop rax
    cmp rax, [rsp]
    jne .not_eq
    mov qword[rsp], 1
    jmp do_nextw
.not_eq:
    mov qword[rsp], 0
    jmp do_nextw

native 'and', and
    cmp qword[rsp], 0
    je .false
    cmp qword[rsp+8], 0
    je .false
    pop rax
    mov qword[rsp], 1
    jmp do_nextw
.false:
    pop rax
    mov qword[rsp], 0
    jmp do_nextw

native 'not', not
    xor qword[rsp], 1
    jmp do_nextw

native '<', less
    pop rax
    cmp qword[rsp], rax
    jnl .nless
    push qword 1
    jmp do_nextw
.nless:
    push qword 0
    jmp do_nextw

native '<=', less_eq
    pop rax
    cmp qword[rsp], rax
    jnle .nlesseq
    push qword 1
    jmp do_nextw
.nlesseq:
    push qword 0
    jmp do_nextw

; stack manipulation

native 'rot', rotate
    mov r8, [rsp+16]    ;a
    mov r9, [rsp+8]     ;b
    mov r10, [rsp]      ;c
    mov [rsp], r8
    mov [rsp+8], r10
    mov [rsp+16], r9
    jmp do_nextw

native 'swap', swap
    mov r8, [rsp]
    mov r9, [rsp+8]
    mov [rsp], r9
    mov [rsp+8], r8
    jmp do_nextw

native 'dup', duplicate
    push qword[rsp]
    jmp do_nextw

native 'drop', drop
    add rsp, 8
    jmp do_nextw

; meta words
native 'q', quit
    xor edi, edi
    call exit
    jmp do_nextw

; code_from_address - finds the ext_nat or ext_col value from a word 
;                     skip over the header metadata basically
;   args: rdi (arg1) - address of the word header
;   return: rax  - address of `extok_` in the header
code_from_address:
    mov rax, [rdi + 8]
    add rax, 18
    add rdi, rax
    mov rax, rdi
    ret

do_colon:
    sub forth_rstack, 8
    mov [forth_rstack], forth_pc
    add forth_word, 8
    mov forth_pc, forth_word
    jmp do_nextw

do_exit:
    mov forth_pc, [forth_rstack]
    add forth_rstack, 8
    jmp do_nextw

do_nextw:
    mov forth_word, [forth_pc]
    add forth_pc, 8
    jmp [forth_word]


interpreter_loop:
    mov rdi, input_buf
    mov rsi, 1024
    call read_word
    test rdx, rdx
    jz .exit

    mov rdi, input_buf
    mov rsi, PREV_WORD
    call find_word
    test rax, rax
    jz .else
    
    mov rdi, rax
    call cfa            ; returns extok_ in rax, which is aliased to exec_token
    mov [program_stub], exec_token
    mov forth_pc, program_stub
    jmp do_nextw

.else:
    mov rdi, input_buf
    call parse_int64
    test rdx, rdx
    jz .more_else
    push qword rax
    jmp interpreter_loop

    .more_else:
        mov rdi, unknown_word
        call print_string
        jmp .exit

.exit:
    pop rbp
    xor edi, edi
    call exit

global _start
_start:
    push rbp
    mov rbp, rsp
    mov forth_rstack, return_stack
    mov forth_memory, memory_cells
    jmp interpreter_loop 