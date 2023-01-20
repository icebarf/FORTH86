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
extern print_int64
extern read_char
extern read_word

; native - define a native forth word, it is composed of native assembly routines
;   args: arg1 - word name (quoted-string)
;         arg2 - part of word identifier (will be used as assembly label)
;         arg3 - flags
%define PREV_NATIVE_WORD 0
%macro native 3
%strlen WORD_LEN %1
section .data
%%PREV_NATIVE_WORD: dq PREV_NATIVE_WORD
dq WORD_LEN
db %1, 0
db %3
extok_nat_ %+ %2:
    dq %2 %+ _impl

section .text
%2 %+ _impl:

%define PREV_NATIVE_WORD %%PREV_NATIVE_WORD
%endmacro

; colon - define a colon forth word, it is composed of other native or colon words
;   args: arg1 - word name (quoted-string)
;         arg2 - part of word identifier (will be used as assembly label)
;         arg3 - flags
%define PREV_COLON_WORD 0
%macro colon 3
%strlen WORD_LEN %1
%%PREV_COLON_WORD: dq PREV_COLON_WORD
dq WORD_LEN
db %1, 0
db %3
extok_col_ %+ %2:

%define PREV_COLON_WORD %%PREV_COLON_WORD
%endmacro

; overloads for previous macros, with flags (arg3) being the optional parameter
%macro native 2
native %1, %2, 0
%endmacro

%macro colon 2
colon %1, %2, 0
%endmacro

; machine reserved data
; reserve memory cells and return stack
; data stack will be the machine's own stack during execution
section .bss
resq 65535
forth_memory: resq 1
resq 1023
return_stack: resq 1


%define cfa code_from_address
section .text
global _start
; code_from_address - finds the ext_nat or ext_col value from a word 
;                     skip over the header metadata basically
;   args: rdi (arg1) - address of the word header
code_from_address:
    mov rax, [rdi + 8]
    add rax, 18
    add rdi, rax
    mov rax, rdi
    ret

native '+', plus
    pop rax
    add [rsp], rax
    jmp _start.back

_start:
    push rbp
    mov rbp, rsp
    sub rsp, 2

    mov rdi, rsp
    mov rsi, 1
    call read_word
    cmp rax, rsp
    jne .end
    cmp rdx, 1
    jne .end

    mov rdi, rax
    mov rsi, PREV_NATIVE_WORD
    call find_word
    test rax, rax
    jz .end

    mov rdi, rax
    call cfa
    push 2
    push 5
    jmp [rax]
.back:
    pop rdi
    call print_int64

    add rsp, 2
    pop rbp

.end:
    xor edi, edi
    call exit