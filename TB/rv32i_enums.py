from enum import IntEnum

'''
ALU_op encoding: add = 0, sub = 1, sll = 2, slt = 3, sltu = 4, xor = 5, srl = 6, sra = 7, or = 8, and = 9
branch_op encoding: beq = 0, bne = 1, blt = 2, bge = 3, bltu = 4, bgeu = 5
'''

class ALU_Ops(IntEnum):
    ADD = 0
    SUB = 1
    SLL = 2
    SLT = 3
    SLTU = 4
    XOR = 5
    SRL = 6
    SRA = 7
    OR = 8
    AND = 9

class Branch_Ops(IntEnum):
    BEQ = 0
    BNE = 1
    BLT = 2
    BGE = 3
    BLTU = 4
    BGEU = 5