# FORTH86

FORTH86 is an implementation of forthress, a FORTH dialect as described in Igor Zhirkov's Low Level Programming. This implementation is currently a work in progress, which I hopefully will finish by the end of January 2023.

Please report any bugs that you find, the interpreter is still in its early/alpha stage.

Happy hacking! 😁

## Building

Have `git`, `make` and `nasm` installed on your machine (At&T syntax with `as` compilation soon mayhaps?)

```bash
$ git clone https://github.com/icebarf/FORTH86
$ cd FORTH86
$ make newbuild
$ ./forthress
```

## Documentation

### Sizes or Limits
- Cell Size: 8 bytes
- Memory Cells: 65536 bytes
- Input Buffer: 1024 bytes
- Return Address Stack: 1024 * 'Cell Size' bytes

### List of words implemented

#### Meta

- `q` quit the interpreter

#### Input/Output

- `.` Pops off an integer from stack top, and prints it

#### Arithmetic

- `N` any integer, is pushed to the data stack
- `+`
- `-`
- `*`
- `/`
- `%`

#### Logical

- `=` pop two arguments, compares them, writes `1` on equality, otherwise 0
- `not` complement of top argument on the data stack (should be 0 or 1)
- `and` logical and, writes 1 if both condition satisfy, oterhwise 0
- `or` logical or
- `<` less than
- `>` greater than
- `<=` less than and equals
- `>=` greater than and equals
- `falsy` checks if value is falsy. Anything non-zero is a truthy value. writes 1 if truthy, otherwise 0

#### Data Stack manipulators

- `rot` moves 3rd element to top, pushes down the first two (a b c -- b c a)
- `swap` swaps the top two elements on the data stack
- `dup` duplicates the element on data stack top (a -- a a)
- `drop` drops the top element on data stack (a -- )

#### Machine Memory manipulators

- `mem` store FORTH machine starting memory address on data stack
- `!` (address data -- ) store data from stack starting at address
- `c!` (address char -- ) store a single byte at address
- `@` (address -- value) read one memory cell and store that value on stack
- `c@` (address -- char ) reads a byte from address and store that value on the stack.
