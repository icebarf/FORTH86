AS := nasm
ASFLAGS := -felf64 -Fdwarf -g
LD := ld

BIN := forth86

OBJ :=  src/main.o		\
		libx86/lib.o	\
		libx86/dict.o	\

all: $(BIN)

$(OBJ): %.o : %.asm
	$(AS) $(ASFLAGS) $<

$(BIN): $(OBJ)
	ld -o $(BIN) $^

clean:
	rm -rf $(BIN) $(OBJ)