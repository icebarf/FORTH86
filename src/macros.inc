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
