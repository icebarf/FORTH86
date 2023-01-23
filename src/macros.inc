; native - define a native forth word, it is composed of native assembly routines
;   args: arg1 - word name (quoted-string)
;         arg2 - part of word identifier (will be used as assembly label)
;         arg3 - flags
%define PREV_WORD 0
%macro native 3
%strlen WORD_LEN %1
section .data
%%PREV_WORD: dq PREV_WORD
dq WORD_LEN
db %1, 0
db %3
extok_%+ %2:
    dq impl_ %+ %2

section .text
impl_ %+ %2:

%define PREV_WORD %%PREV_WORD
%endmacro

; colon - define a colon forth word, it is composed of other native or colon words
;   args: arg1 - word name (quoted-string)
;         arg2 - part of word identifier (will be used as assembly label)
;         arg3 - flags
%macro colon 3
%strlen WORD_LEN %1
section .data
%%PREV_WORD: dq PREV_WORD
dq WORD_LEN
db %1, 0
db %3
extok_%+ %2:
    dq impl_docolon
%define PREV_WORD %%PREV_WORD
%endmacro

; overloads for previous macros, with flags (arg3) being the optional parameter
%macro native 2
native %1, %2, 0
%endmacro

%macro colon 2
colon %1, %2, 0
%endmacro
