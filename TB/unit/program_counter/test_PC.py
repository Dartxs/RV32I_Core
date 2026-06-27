import cocotb
from cocotb.triggers import Timer, RisingEdge
from helpers import start_clock, tick
from rv32i_enums import PC_Sel

'''
RV32I Program Counter cocotb testbench
'''

async def init_test(dut):
    dut.rst_n.value = 0
    dut.PC_Sel.value = 0
    dut.op1.value = 0
    dut.imm.value = 0

    start_clock(dut)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await Timer(1, 'ns')

def comp_PC(dut, exp_PC, exp_def_PC):
    actual_PC = int(dut.PC.value)
    actual_def_PC = int(dut.default_PC.value)

    errors = []

    if(actual_PC != exp_PC):
        errors.append(f"PC expected 0x{exp_PC:08X}, got {actual_PC:08X}")
    if(actual_def_PC != exp_def_PC):
        errors.append(f"Default PC expected 0x{exp_def_PC:08X}, got {actual_def_PC:08X}")

    assert (not errors), (
        f"\n FAILED PROGRAM COUNTER TEST\n"
        + "\n".join(errors)
    )

@cocotb.test()
async def test_PC_basic(dut):

    await init_test(dut)

    #test PC increments by 4 after each clock edge
    for i in range (1,20):
        await tick(dut)
        comp_PC(dut, 4*i, 4*(i+1))

    #test reset
    dut.rst_n.value = 0
    await tick(dut)
    comp_PC(dut, 0, 4)

@cocotb.test()
async def test_PC_br_jal(dut):

    await init_test(dut)
    
    dut.PC_Sel.value = PC_Sel.BR_JAL
    
    dut.imm.value = 0x10
    await tick(dut)
    comp_PC(dut, 0x10, 0x14)

    dut.imm.value = 0xFFFFFFF8 #-8
    await tick(dut)
    comp_PC(dut, 0x8, 0xC)

@cocotb.test()
async def test_PC_jalr(dut):
    
    await init_test(dut)
    dut.PC_Sel.value = PC_Sel.JALR
    
    dut.op1.value = 0x00000100
    dut.imm.value = 0x00000010 
    
    await tick(dut)

    comp_PC(dut, 0x110, 0x114)

    dut.imm.value = 0xFFFFFFF8 #-8
    await tick(dut)
    comp_PC(dut, 0xF8, 0xFC)
    
    dut.imm.value = 0x1 #LSB gets cleared so this shouldn't affect the PC
    await tick(dut)
    comp_PC(dut, 0x100, 0x104)
    
