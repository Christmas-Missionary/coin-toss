/*
Copyright (c) 2025 Christmas_Missionary - BSD Zero Clause License
*/

.global _start
.align 4

close_then_get_out:
  mov x0, x9
  mov x16, #6                // sys_close
  svc 0
get_out: // to avoid `abort`
  mov x0, #1
  adr	x1, nothing
  mov	x2, #19
	mov x16, #4                // sys_write
	svc 0
  mov x0, #1                 // reset x0 after return of sys_write
	mov x16, #1                // sys_exit
	svc 0

_start: 
// open /dev/urandom
  adr x0, urandom
  mov x1, xzr                // O_RDONLY
  mov x2, 0x284              // (RW-R--R--)       
  mov x16, #5                // sys_open
  svc 0
  cmp x0, #2                 // ENOENT
    beq get_out

// read from /dev/urandom
  mov x9, x0                 // Save file id
  mov x1, sp                      
  mov x2, #1
  mov x16, #3                // sys_read
  svc 0
  cmp x0, xzr
    beq close_then_get_out   // if no bytes read
  
// close /dev/urandom
  mov x0, x9
  mov x16, #6                // sys_close
  svc 0

// load strings
  adr x10, heads
  adr x11, tails

// w9 = (*(char *)sp) & 1
  ldrb w9, [sp]
  and w9, w9, #1

// write either heads or tails
  cmp w9, wzr
    csel x1, x10, x11, eq
	mov x0, #1
  mov	x2, #6
	mov x16, #4                // sys_write
	svc 0

  mov x0, xzr
	mov x16, #1                // sys_exit
	svc 0

urandom: .asciz "/dev/urandom"
heads: .ascii "Heads\n"
tails: .ascii "Tails\n"
nothing: .ascii "Couldn't open RNG!\n"
