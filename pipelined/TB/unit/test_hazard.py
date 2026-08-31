import cocotb
from cocotb.triggers import Timer
from random import getrandbits
from rv32i_enums import Forward_Sel

'''
RV32I Hazard Unit cocotb testbench
'''

def compute_expected(reg_writeM, reg_writeW, rs, rdM, rdW):
    if((rdM != 0) and reg_writeM and (rs == rdM)):
        return Forward_Sel.FORWARD_MEM
    elif((rdW != 0) and reg_writeW and (rs == rdW)):
        return Forward_Sel.FORWARD_WB
    else:
        return Forward_Sel.NO_FORWARD

async def check_forward(dut, reg_writeM, reg_writeW, rs1E, rs2E, rdM, rdW):
    dut.reg_writeM.value = reg_writeM
    dut.reg_writeW.value = reg_writeW
    dut.rs1E.value = rs1E
    dut.rs2E.value = rs2E
    dut.rdM.value = rdM
    dut.rdW.value = rdW
    await Timer(1, 'ns')

    forwardA_act = Forward_Sel(int(dut.forwardA.value))
    forwardB_act = Forward_Sel(int(dut.forwardB.value))

    forwardA_exp = compute_expected(reg_writeM, reg_writeW, rs1E, rdM, rdW)
    forwardB_exp = compute_expected(reg_writeM, reg_writeW, rs2E, rdM, rdW)

    errors = []

    if(forwardA_act != forwardA_exp):
        errors.append(f"ForwardA expected {forwardA_exp.name} ({forwardA_exp}), \
                      got {forwardA_act.name} ({forwardA_act})")

    if(forwardB_act != forwardB_exp):
        errors.append(f"ForwardB expected {forwardB_exp.name} ({forwardB_exp}), \
                        got {forwardB_act.name} ({forwardB_act})")

    assert(not errors), (
        f"\n FAILED HAZARD UNIT TEST\n"
        f"reg_writeM = {bool(reg_writeM)} | reg_writeW = {bool(reg_writeW)} | \
            rs1E = {rs1E} | rs2E = {rs2E} | rdM = {rdM} | rdW = {rdW}\n"
        + "\n".join(errors)
    )

@cocotb.test()
async def test_forwarding(dut):

    #standard directed tests
    await check_forward(dut, 0, 1, 8, 0, 0, 8)
    await check_forward(dut, 1, 0, 8, 0, 8, 0)
    await check_forward(dut, 0, 1, 0, 8, 0, 8)
    await check_forward(dut, 1, 0, 0, 8, 8, 0)

    #smoke
    await check_forward(dut, 1, 1, 8, 0, 8, 8) #test forwarding priority
    await check_forward(dut, 1, 1, 0, 0, 0, 0) #test register x0 RAW

    #random with writes 
    for _ in range(100):
        await check_forward(dut, 1, 1, getrandbits(5), getrandbits(5), getrandbits(5), getrandbits(5))

    #random, writes disabled
    for _ in range(100):
        await check_forward(dut, 0, 0, getrandbits(5), getrandbits(5), getrandbits(5), getrandbits(5))

