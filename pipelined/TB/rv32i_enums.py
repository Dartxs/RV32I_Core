from enum import IntEnum

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
    PCp4 = 2

class Forward_Sel(IntEnum):
    NO_FORWARD = 0b00
    FORWARD_MEM = 0b01
    FORWARD_WB = 0b10