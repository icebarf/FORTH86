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


section .data
unknown_word: db "Unknown word, please check documentation", 0xa, 0
data_stack_bp: dq 0
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

section .text

%include "lib.inc"
%include "dict.inc"
%include "words_impl.inc"

; code_from_address - finds the ext_nat or ext_col value from a word 
;                     skip over the header metadata basically
;   args: rdi (arg1) - address of the word header
;   return: rax  - address of `extok_` in the header
%define cfa code_from_address
code_from_address:
    mov rax, [rdi + CELL_SIZE]
    add rax, 18
    add rdi, rax
    mov rax, rdi
    ret

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
    mov [data_stack_bp], rsp
    mov forth_rstack, return_stack
    jmp interpreter_loop