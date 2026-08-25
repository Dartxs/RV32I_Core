import cocotb
from cocotb.triggers import Timer
import random
from single_cycle.TB.rv32i_enums import Branch_Ops
from single_cycle.TB.helpers import signed_cast

'''
RV32I Branch Unit cocotb testbench

branch_op encoding: beq = 0, bne = 1, blt = 2, bge = 3, bltu = 4, bgeu = 5
'''

def compute_expected(op1, op2, branch_op):

    match branch_op:
        case Branch_Ops.BEQ:
            return (op1 == op2)
        case Branch_Ops.BNE:
            return (op1 != op2)
        case Branch_Ops.BLT:
            return (signed_cast(op1) < signed_cast(op2))
        case Branch_Ops.BGE:
            return (signed_cast(op1) >= signed_cast(op2))
        case Branch_Ops.BLTU:
            return (op1 < op2)
        case Branch_Ops.BGEU:
            return (op1 >= op2)
        
    return False

async def check_branch(dut, op1, op2, branch_op):

    op1 &= 0xFFFFFFFF
    op2 &= 0xFFFFFFFF

    dut.op1.value = op1
    dut.op2.value = op2
    dut.branch_op.value = branch_op

    await Timer(1, 'ns')
    
    expected = int(compute_expected(op1, op2, branch_op))
    actual = int(dut.branch_taken.value)
    assert (actual == expected), (
        f"\nFAILED BRANCH TEST\n"
        f"branch op = {branch_op.name} | op1 = 0x{op1:08X} | op2 = 0x{op2:08X}\n"
        f"expected branch_taken = {expected} ({bool(expected)}) | actual = {actual} ({bool(actual)})\n"
    )

@cocotb.test()
async def test_branch_equal(dut):
    #test BEQ and BNE
    await check_branch(dut, 8, 8, Branch_Ops.BEQ)
    await check_branch(dut, 8, 8, Branch_Ops.BNE)
    await check_branch(dut, 8, 9, Branch_Ops.BEQ)
    await check_branch(dut, 8, 9, Branch_Ops.BNE)
    
@cocotb.test()
async def test_branch_signed(dut):
    #test BLT and BGE
    await check_branch(dut, 0xFFFFFFFF, 0, Branch_Ops.BLT)
    await check_branch(dut, 0xFFFFFFFF, 0, Branch_Ops.BGE)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFF, Branch_Ops.BLT)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFF, Branch_Ops.BGE)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFE, Branch_Ops.BLT)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFE, Branch_Ops.BGE)

@cocotb.test()
async def test_branch_unsigned(dut):
    #test BLTU and BGEU
    await check_branch(dut, 0, 0xFFFFFFFF, Branch_Ops.BLTU)
    await check_branch(dut, 0, 0xFFFFFFFF, Branch_Ops.BGEU)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFF, Branch_Ops.BLTU)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFF, Branch_Ops.BGEU)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFE, Branch_Ops.BLTU)
    await check_branch(dut, 0xFFFFFFFF, 0xFFFFFFFE, Branch_Ops.BGEU)

@cocotb.test()
async def test_branch_edges(dut):
    #Zero, max/min values

    await check_branch(dut, 0, 0, Branch_Ops.BEQ)
    await check_branch(dut, 0, 0, Branch_Ops.BNE)

    await check_branch(dut, 0x7FFFFFFF, 0x80000000, Branch_Ops.BLT)
    await check_branch(dut, 0x7FFFFFFF, 0x80000000, Branch_Ops.BGE)

    await check_branch(dut, 0x80000000, 0x7FFFFFFF, Branch_Ops.BLT)
    await check_branch(dut, 0x80000000, 0x7FFFFFFF, Branch_Ops.BGE)

@cocotb.test()
async def test_branch_random(dut):
    #Test against python reference model

    for i in range(500):
        op1 = random.getrandbits(32)
        op2 = random.getrandbits(32)
        branch_op = random.choice(list(Branch_Ops))
        await check_branch(dut, op1, op2, branch_op)


