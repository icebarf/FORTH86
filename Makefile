AS := nasm
ASFLAGS := -felf64 -Fdwarf -g
LD := ld

BIN := forthress

OBJ :=  src/main.o		\
		libx86/lib.o	\
		libx86/dict.o	\

INC :=  src/		\

all: $(BIN)

$(OBJ): %.o : %.asm
	$(AS) $(ASFLAGS) $<	 -I $(INC)

$(BIN): $(OBJ)
	ld -o $(BIN) $^

clean:
	rm -rf $(BIN) $(OBJ)