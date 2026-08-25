from enum import IntEnum

'''
ALU_op encoding: add = 0, sub = 1, sll = 2, slt = 3, sltu = 4, xor = 5, srl = 6, sra = 7, or = 8, and = 9
branch_op encoding: beq = 0, bne = 1, blt = 2, bge = 3, bltu = 4, bgeu = 5
opcode encoding: load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, opR_ins = 7'b01_100_11, auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;
writeback encoding: WB_ALU = 0, WB_mem = 1, WB_def_PC = 2, WB_imm = 3
PC select encoding: PC_default = 0, PC_BR_JAL = 1, PC_JALR = 2
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

class Opcodes(IntEnum):
    LOAD = 0b0000011
    STORE = 0b0100011
    BRANCH = 0b1100011
    JALR = 0b1100111
    JAL = 0b1101111
    OPIMM = 0b0010011
    OPR = 0b0110011
    AUIPC = 0b0010111
    LUI = 0b0110111

class WB_ctrl(IntEnum):
    ALU = 0
    MEM = 1
    DEF_PC = 2
    IMM = 3

class PC_Sel(IntEnum):
    DEFAULT = 0
    BR_JAL = 1
    JALR = 2

class Funct3(IntEnum):
    BYTE = 0b000
    HALFWORD = 0b001
    WORD = 0b010
    BYTE_U = 0b100
    HALFWORD_U = 0b101
