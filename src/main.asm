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

native '+', plus
    pop rax
    add [rsp], rax
    jmp do_nextw

native '.Q', quit
    xor edi, edi
    call exit
    jmp do_nextw

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
    push rbp
    mov rbp, rsp

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

    .more_else:
        mov rdi, unknown_word
        call print_string
        jmp .exit

.exit:
    xor edi, edi
    call exit

global _start
_start:
    mov forth_rstack, return_stack
    mov forth_memory, memory_cells
    jmp interpreter_loop 