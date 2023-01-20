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

%define PREV_NATIVE_WORD 0
%macro native 3
%strlen WORD_LEN %1
section .data
%%PREV_NATIVE_WORD: dq PREV_NATIVE_WORD
dq WORD_LEN
db %1, 0
extok_nat_ %+ %2:
    dq %2 %+ _impl

section .text
%2 %+ _impl:

%define PREV_NATIVE_WORD %%PREV_NATIVE_WORD
%endmacro

%define PREV_COLON_WORD 0
%macro colon 2
%strlen WORD_LEN %1
section .data
%%PREV_COLON_WORD: dq PREV_COLON_WORD
dq WORD_LEN
db %1, 0
extok_col_ %+ %2:

%define PREV_COLON_WORD %%PREV_COLON_WORD
%endmacro