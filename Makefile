AS := nasm
ASFLAGS := -felf64 -Fdwarf -g
LD := ld

BIN := forthress

OBJ :=  src/main.o		\
		libx86/lib.o	\
		libx86/dict.o	\

INC :=  src/		\

.PHONY: init clean


all: $(BIN)

newbuild: init $(BIN)

rebuild: clean $(BIN)

init:
	git submodule update --init --recursive --remote libx86
	command -v nasm || (echo "nasm not installed"; sh -c 'exit 1')

$(OBJ): %.o : %.asm
	$(AS) $(ASFLAGS) $<	 -I $(INC)

$(BIN): $(OBJ)
	ld -o $(BIN) $^

clean:
	rm -rf $(BIN) $(OBJ)