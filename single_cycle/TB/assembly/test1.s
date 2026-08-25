.text
.globl _start
_start:
    # Test 1: ADDI
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 10     # x2 = 10
    addi x3, x0, -1     # x3 = -1 (tests sign extension)

    # Test 2: R-TYPE
    add  x4, x1, x2     # x4 = 15
    sub  x5, x2, x1     # x5 = 5
    and  x6, x1, x2     # x6 = 5 & 10 = 0
    or   x7, x1, x2     # x7 = 5 | 10 = 15
    xor  x8, x1, x2     # x8 = 5 ^ 10 = 15
    sll  x9, x1, x2     # x9 = 5 << 10 = 5120
    srl  x10, x9, x2    # x10 = 5120 >> 10 = 5
    sra  x11, x3, x1    # x11 = -1 >>> 5 = -1 (arithmetic shift preserves sign)
    slt  x12, x1, x2    # x12 = (5 < 10) = 1
    slt  x13, x3, x1	# x13 = (-1 < 5) = 1			 	
    sltu x14, x1, x3    # x14 = (5 < 0xFFFFFFFF) unsigned = 1

	# Test 3: I-TYPE (ALU excluding ADDI)
    andi  x15, x1, 10   # x15 = 5 & 10 = 0
    ori   x16, x1, 10   # x16 = 5 | 10 = 15
    xori  x17, x1, 10   # x17 = 5 ^ 10 = 15
   	slti x18, x3, 1 	# x18 = (-1 < 1) = 1
    sltiu x19, x3, 1	# x19 = (0xFFFFFFFF < 1) unsigned = 0
   	slli  x20, x1, 10   # x20 = 5 << 10 = 5120
    srli  x21, x20, 10  # x21 = 5120 >> 10 = 5
    srai  x22, x3, 5   	# x22 = -1 >>> 5 = -1 
    
    # Test 4: UPPER IMMEDIATE
    lui x23, 0xDEADB	# x23 = 0xDEADB << 12 = 0xDEADB000
    addi x23, x23, 0x123	# x23 = 0xDEADB123 
    AUIPC x24, 0x1 		# PC = 24*4, x24 = 0x1000 + PC = 0x1000 + 24*4 = 0x1000 + 0x60 = 0x1060
    
    # Test 5: JUMP
    jal x25, skip 		# x25 = PC + 4, jump to label 'skip'
    jal x0, branch_test	# jalr jumps back here to move on to branch tests
    jal x0, fail 		# should never get executed
    
skip:
	jalr x0, x25, 0		# Jump back to address of instruction stored in register x25, return address discarded

	# Test 6: BRANCH
branch_test:
    beq x1, x2, fail	# 5 == 10, false -> should not branch
    beq x3, x3, bne_test # -1 == -1, true -> should branch
    jal x0, fail		# should never get executed
    
bne_test:
	bne x1, x1, fail	# 5 != 5, false -> should not branch
    bne x1, x3, blt_test # 5 != -1, true -> should branch
    jal x0, fail		# should never get executed
    
blt_test:
	blt x2, x3, fail	# 10 < -1, false -> should not branch
    blt x1, x2, bge_test # 5 < 10, true -> should branch
    jal x0, fail		# should never get executed

bge_test:
	bge x3, x2, fail	# -1 >= 10, false -> should not branch
    bge x2, x1, bltu_test # 10 >= 5, true -> should branch
    jal x0, fail		# should never get executed
    
bltu_test:
	bltu x3, x1, fail	# 0xFFFFFFFF < 5 (unsigned), false -> should not branch
    bltu x1, x3, bgeu_test # 5 < 0xFFFFFFFF (unsigned), true -> should branch
    jal x0, fail		# should never get executed
    
bgeu_test:
	bgeu x1, x3, fail	# 5 >= 0xFFFFFFFF (unsigned), false -> should not branch
    bgeu x3, x1, store_test # 0xFFFFFFFF >= 5 (unsigned), true -> should branch
    jal x0, fail		# should never get executed
    
	# Test 6: STORE, x23 = 0xDEADBEEF
store_test:
    addi x26, x0, 4		# x26 = 4, use as base address
	sw x23, 0(x26) 		# mem[7:4] = 0xDEADB123
  	sh x23, 6(x26)		# mem[11:10] = 0xB123
    sb x23, 5(x26) 		# mem[9] = 0x23
    sb x23, 4(x26)		# mem[8] = 0x23
    
	# Test 7: LOAD
    lw x27, 0(x26)		# x27 = mem[7:4] = 0xDEADB123
    lh x28, 6(x26)		# x28 = mem[11:10] (sign extended) = 0xFFFFB123
    lb x29, 7(x26) 		# x29 = mem[11] (sign extended) = 0xFFFFFFB1
    lhu x30, 6(x26) 	# x30 = mem[11:10] = 0xB123
    lbu x31, 7(x26) 	# x31 = mem[11] = 0xB1
    
done:
    jal x0, done    	# infinite loop, test sequence done

fail:
	jal x0, fail		# infinite loop, test error


