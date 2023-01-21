# FORTH86

FORTH86 is an implementation of forthress, a FORTH dialect as described in Igor Zhirkov's Low Level Programming. This implementation is currently a work in progress, which I hopefully will finish by the end of January 2023.

Please report any bugs that you find, the interpreter is still in its early/alpha stage.

Happy hacking! 😁

<details>
<summary>Documentation</summary>
<br>

### Sizes or Limits
- Cell Size: 8 bytes
- Memory Cells: 65536 bytes
- Input Buffer: 1024 bytes
- Return Address Stack: 1024 * 'Cell Size' bytes

### List of words implemented

#### Input/Output
- `.` Pops off an integer from stack top, and prints it

#### Arithmetic

- `N` any integer, is pushed to the stack
- `+`
- `-`
- `*`
- `/`
- `%`

#### Logical
- `=` pop two arguments, compares them, writes `1` on equality, otherwise 0
- `not` complement of top argument on the stack (should be 0 or 1)

</details>