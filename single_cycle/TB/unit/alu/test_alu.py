import cocotb
from cocotb.triggers import Timer
import random
from single_cycle.TB.rv32i_enums import ALU_Ops
from single_cycle.TB.helpers import signed_cast

'''
RV32I ALU cocotb testbench with directed and randomized test for each operator

operations (ALU_op): add = 0, sub = 1, sll = 2, slt = 3, sltu = 4, xor = 5, srl = 6, sra = 7, or = 8, and = 9
operand1 (ALU_op1_ctrl): 0 = op1, 1 = PC
operand2 (ALU_op2_ctrl): 0 = op2, 1 = imm
'''

#helper functions
def init_ctrls(dut):
    #set ctrl to use op1 and op2, also set define PC value for safety
    dut.ALU_op1_ctrl.value = 0
    dut.ALU_op2_ctrl.value = 0
    dut.PC.value = 0
    
def compute_expected(op1, op2, operation):

    op1 &= 0xFFFFFFFF
    op2 &= 0xFFFFFFFF
    
    shamt = op2 & 0x1F #used only for shifting, max shift = 31; keep only lower 5 bits

    match operation:
        case ALU_Ops.ADD:
            result = (op1 + op2)
        case ALU_Ops.SUB:
            result = (op1 - op2)
        case ALU_Ops.SLL:
            result = (op1 << shamt)
        case ALU_Ops.SLT:
            result = int(signed_cast(op1) < signed_cast(op2)) #int cast returns 1 if true, 0 if false
        case ALU_Ops.SLTU:
            result = int(op1 < op2)
        case ALU_Ops.XOR:
            result = (op1 ^ op2)
        case ALU_Ops.SRL:
            result = (op1 >> shamt)
        case ALU_Ops.SRA:
            result = (signed_cast(op1) >> shamt)
        case ALU_Ops.OR:
            result = (op1 | op2) 
        case ALU_Ops.AND:
            result = (op1 & op2)
        case _:
            raise ValueError("Invalid ALU operation") #any other operation will raise this error
        
    return (result & 0xFFFFFFFF) #return results masked to 32 bits
    

async def run_case_dir(dut, op1, op2, operation): #directed test cases

    op1 &= 0xFFFFFFFF
    op2 &= 0xFFFFFFFF

    dut.ALU_op.value = operation
    dut.op1.value = op1
    dut.op2.value = op2

    await Timer(1, 'ns')

    expected = compute_expected(op1, op2, operation)
    actual = int(dut.ALU_out.value)
    assert (actual == expected), (
        f"\nFAILED ALU TEST\n"
        f"op = {operation.name} | op1 = 0x{op1:08X} | op2 = 0x{op2:08X}\n"
        f"expected = 0x{expected:08X} | actual = 0x{actual:08X}\n"
    )

async def run_case_rand(dut, operation): #random test cases
    op1 = random.getrandbits(32) 
    op2 = random.getrandbits(32)

    await run_case_dir(dut, op1, op2, operation)    


@cocotb.test()
async def test_alu_add(dut): 
    init_ctrls(dut)

    await run_case_dir(dut, 1, 1, ALU_Ops.ADD)
    await run_case_dir(dut, 0, 0, ALU_Ops.ADD)
    await run_case_dir(dut, -1, 1, ALU_Ops.ADD)
    await run_case_dir(dut, 0xFFFFFFFF, 0x1, ALU_Ops.ADD)
    await run_case_dir(dut, 0x7FFFFFFF, 1, ALU_Ops.ADD)
    await run_case_dir(dut, 0x80000000, -1, ALU_Ops.ADD)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.ADD)

@cocotb.test()
async def test_alu_sub(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 1, 1, ALU_Ops.SUB)
    await run_case_dir(dut, 0, 0, ALU_Ops.SUB)
    await run_case_dir(dut, 0, 1, ALU_Ops.SUB)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SUB)
    await run_case_dir(dut, 0, 0x80000000, ALU_Ops.SUB)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SUB)

@cocotb.test()
async def test_alu_sll(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 1, 1, ALU_Ops.SLL)
    await run_case_dir(dut, 0, 0, ALU_Ops.SLL)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SLL)
    await run_case_dir(dut, 1, 0xFFFFFFFF, ALU_Ops.SLL) #should just shift it 31 times
    
    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SLL)
    
@cocotb.test()
async def test_alu_slt(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.SLT)
    await run_case_dir(dut, 0, 1, ALU_Ops.SLT)
    await run_case_dir(dut, 0xFFFFFFFF, 0, ALU_Ops.SLT)
    await run_case_dir(dut, 0x7FFFFFFF, 0xFFFFFFFF, ALU_Ops.SLT)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SLT)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SLT)

@cocotb.test()
async def test_alu_sltu(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.SLTU)
    await run_case_dir(dut, 0, 1, ALU_Ops.SLTU)
    await run_case_dir(dut, 0xFFFFFFFF, 0, ALU_Ops.SLTU)
    await run_case_dir(dut, 0x7FFFFFFF, 0xFFFFFFFF, ALU_Ops.SLTU)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SLTU)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SLTU)
    
@cocotb.test()
async def test_alu_xor(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.XOR)
    await run_case_dir(dut, 0, 1, ALU_Ops.XOR)
    await run_case_dir(dut, 1, 1, ALU_Ops.XOR)
    await run_case_dir(dut, 0xFFFFFFFF, 0, ALU_Ops.XOR)
    await run_case_dir(dut, 0xFFFFFFFF, 0xFFFFFFFF, ALU_Ops.XOR)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.XOR)

@cocotb.test()
async def test_alu_srl(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.SRL)
    await run_case_dir(dut, 1, 1, ALU_Ops.SRL)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SRL)
    await run_case_dir(dut, 0xFFFFFFFF, 1, ALU_Ops.SRL)
    await run_case_dir(dut, 0xFFFFFFFF, 0xFFFFFFFF, ALU_Ops.SRL)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SRL)

@cocotb.test()
async def test_alu_sra(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.SRA)
    await run_case_dir(dut, 1, 1, ALU_Ops.SRA)
    await run_case_dir(dut, 0x80000000, 1, ALU_Ops.SRA)
    await run_case_dir(dut, 0xFFFFFFFF, 1, ALU_Ops.SRA)
    await run_case_dir(dut, 0xFFFFFFFF, 0xFFFFFFFF, ALU_Ops.SRA)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.SRA)

@cocotb.test()
async def test_alu_or(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.OR)
    await run_case_dir(dut, 0, 1, ALU_Ops.OR)
    await run_case_dir(dut, 1, 1, ALU_Ops.OR)
    await run_case_dir(dut, 0, 0xFFFFFFFF, ALU_Ops.OR)
    await run_case_dir(dut, 0xFFFFFFFF, 0xFFFFFFFF, ALU_Ops.OR)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.OR)


@cocotb.test()
async def test_alu_and(dut):
    init_ctrls(dut)

    await run_case_dir(dut, 0, 0, ALU_Ops.AND)
    await run_case_dir(dut, 0, 1, ALU_Ops.AND)
    await run_case_dir(dut, 1, 1, ALU_Ops.AND)
    await run_case_dir(dut, 0xFFFFFFFF, 0, ALU_Ops.AND)
    await run_case_dir(dut, 0xFFFFFFFF, 0xFFFFFFFF, ALU_Ops.AND)

    for i in range(500):
        await run_case_rand(dut, ALU_Ops.AND)