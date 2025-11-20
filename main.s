/*
Copyright (c) 2025 Christmas_Missionary - BSD Zero Clause License
*/

.global _start
.align 4

argv_one_to_val:
  add x1, x1, #8             // argv -> argv + 1
  ldr x1, [x1]               // argv[1]

  ldrb w19, [x1]             // argv[1][0]
  sub w19, w19, #48          // '0' and '9' -> 0 and 9
  cmp w19, #9
    cset x13, ls
    cmp x13, xzr             // bool x10 = (x9 >= 0 && x9 <= 9);
      b.eq mov_one           // if (x10 == 0) {goto mov_one;}

  add x1, x1, #1             // argv[1] + 1
  ldrb w20, [x1]             // argv[1][1]
  cmp w20, wzr               // if null byte, go to single_calc
    b.eq single_calc
  sub w20, w20, #48
  cmp w20, #9
    cset x13, ls
    cmp x13, xzr
      b.eq single_calc
  
  mov w21, #10
  madd x1, x19, x21, x20
  b read_bytes
single_calc:
  mov x1, x19
  b read_bytes
mov_one:
  mov x1, #1
  b read_bytes

close_then_get_out:
  mov x0, x9
  mov x16, #6                // sys_close
  svc 0
get_out:
// to avoid `abort`
  mov x0, #1
  adr	x1, nothing
  mov	x2, #19
	mov x16, #4                // sys_write
	svc 0
  mov x0, #1                 // reset x0 after return of sys_write
	mov x16, #1                // sys_exit
	svc 0

_start: 
// get number from 1-99 from argv[1]
  cmp x0, #1
    b.gt argv_one_to_val
    b.le mov_one

read_bytes:
  cmp x1, xzr
    b.eq mov_one
  cmp x1, #99
    b.hi mov_one
  mov x15, x1 // 1-99 in x15 for now

// open /dev/urandom
  adr x0, urandom
  mov x1, xzr                // O_RDONLY
  mov x2, 0x284              // (RW-R--R--)       
  mov x16, #5                // sys_open
  svc 0
  cmp x0, #2                 // ENOENT
    b.eq get_out

// read 16 bytes from /dev/urandom
  sub sp, sp, #16
  mov x9, x0                 // Save file id
  mov x1, sp                      
  mov x2, #16
  mov x16, #3                // sys_read
  svc 0
  cmp x0, xzr
    b.eq close_then_get_out  // if no bytes read
  
// close /dev/urandom
  mov x0, x9
  mov x16, #6                // sys_close
  svc 0

// load strings
  adr x10, heads
  adr x11, tails

  mov x19, xzr // i = 0
  ldp x20, x21, [sp]
  add sp, sp, #16
  
  mov	x2, #6                 // 6 bytes long for both strings
	mov x16, #4                // sys_write

// x15 is size, x19 is i, x20 is big, x21 is little, x22 and x23 are temps
loop_writes:
  and x23, x21, #1
  lsr x21, x21, #1
  and x22, x20, #0x8000000000000000
  orr x21, x21, x22
  lsl x20, x20, #1

// write either heads or tails
  cmp x23, xzr
    csel x1, x10, x11, eq
  mov x0, #1                 // reset x0 after each sys_write
	svc 0

  add x19, x19, #1           // i++
  cmp x19, x15               // (i <= x15)
    b.lt loop_writes

sys_exit:
  mov x0, xzr
	mov x16, #1
	svc 0

urandom: .asciz "/dev/urandom"
heads: .ascii "Heads\n"
tails: .ascii "Tails\n"
nothing: .ascii "Couldn't open RNG!\n"
