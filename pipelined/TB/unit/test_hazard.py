import cocotb
from cocotb.triggers import Timer
from random import getrandbits
from rv32i_enums import Forward_Sel, WB_ctrl

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
    
def compute_expected_loadhaz(writeback_ctrlE, rs1D, rs2D, rdE):
    if((rdE != 0) and (writeback_ctrlE == WB_ctrl.MEM)):
        return ((rs1D == rdE) or (rs2D == rdE))
        
    return False

async def check_hazards(dut, reg_writeM, reg_writeW, rs1E, rs2E, rdM, rdW, writeback_ctrlE, rs1D, rs2D, rdE, flush):
    dut.reg_writeM.value = reg_writeM
    dut.reg_writeW.value = reg_writeW
    dut.rs1E.value = rs1E
    dut.rs2E.value = rs2E
    dut.rdM.value = rdM
    dut.rdW.value = rdW
    dut.writeback_ctrlE.value = writeback_ctrlE
    dut.rs1D.value = rs1D
    dut.rs2D.value = rs2D
    dut.rdE.value = rdE
    dut.flush.value = flush
    
    await Timer(1, 'ns')

    forwardA_act = Forward_Sel(int(dut.forwardA.value))
    forwardB_act = Forward_Sel(int(dut.forwardB.value))
    stallF_act = bool(dut.stallF.value)
    stallFD_act = bool(dut.stallFD.value)
    flushFD_act = bool(dut.flushFD.value)
    flushDE_act = bool(dut.flushDE.value)

    forwardA_exp = compute_expected(reg_writeM, reg_writeW, rs1E, rdM, rdW)
    forwardB_exp = compute_expected(reg_writeM, reg_writeW, rs2E, rdM, rdW)
    stalls_exp = compute_expected_loadhaz(writeback_ctrlE, rs1D, rs2D, rdE)
    flushDE_exp = bool(stalls_exp or flush)

    alu_use_haz_errors = []
    load_use_haz_errors = []
    control_haz_errors = []
    

    if(forwardA_act != forwardA_exp):
        alu_use_haz_errors.append(f"ForwardA expected {forwardA_exp.name} ({forwardA_exp}), "
                                + f"got {forwardA_act.name} ({forwardA_act})")

    if(forwardB_act != forwardB_exp):
        alu_use_haz_errors.append(f"ForwardB expected {forwardB_exp.name} ({forwardB_exp}), "
                                + f"got {forwardB_act.name} ({forwardB_act})")
    
    if((flushFD_act != flush) or (flushDE_act != flushDE_exp)):
        control_haz_errors.append(f"flushFD and flushDE expected {bool(flush)}, "
                                + f"got flushFD = {flushFD_act}, flushDE = {flushDE_act}")
    
    if(not flush):
        if((stalls_exp != stallF_act) or (stalls_exp != stallFD_act) or (flushDE_exp != flushDE_act)):
            load_use_haz_errors.append(f"stalls and flushDE expected {stalls_exp}, "
                                    + f"got stallF = {stallF_act}, stallFD = {stallFD_act}, flushDE = {flushDE_act}")

    if(alu_use_haz_errors or load_use_haz_errors or control_haz_errors):
        print(f"\n FAILED HAZARD UNIT TEST\n")

    assert(not alu_use_haz_errors), (
        f"ALU use hazard:\n"
        f"reg_writeM = {bool(reg_writeM)} | reg_writeW = {bool(reg_writeW)} | "
        + f"rs1E = {rs1E} | rs2E = {rs2E} | rdM = {rdM} | rdW = {rdW}\n"
        + "\n".join(alu_use_haz_errors)
    )
    
    assert(not load_use_haz_errors), (
        f"Load use hazard:\n"
        f"writeback_ctrlE = {WB_ctrl(writeback_ctrlE).name} | rdE = {rdE} | "
        + f"rs1D = {rs1D} | rs2D = {rs2D}\n"
        + "\n".join(load_use_haz_errors)
    ) 

    assert(not control_haz_errors), (
        f"Control hazard:\n"
        + "\n".join(load_use_haz_errors)
    ) 
    

@cocotb.test()
async def test_forwarding(dut):

    #standard directed tests
    await check_hazards(dut, 0, 1, 8, 0, 0, 8, 0, 0, 0, 0, 0)
    await check_hazards(dut, 1, 0, 8, 0, 8, 0, 0, 0, 0, 0, 0)
    await check_hazards(dut, 0, 1, 0, 8, 0, 8, 0, 0, 0, 0, 0)
    await check_hazards(dut, 1, 0, 0, 8, 8, 0, 0, 0, 0, 0, 0)

    #smoke
    await check_hazards(dut, 1, 1, 8, 0, 8, 8, 0, 0, 0, 0, 0) #test forwarding priority
    await check_hazards(dut, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0) #test register x0 RAW

    #random with writes 
    for _ in range(100):
        await check_hazards(dut, 1, 1, getrandbits(5), getrandbits(5), getrandbits(5), getrandbits(5), 0, 0, 0, 0, 0)

    #random, writes disabled
    for _ in range(100):
        await check_hazards(dut, 0, 0, getrandbits(5), getrandbits(5), getrandbits(5), getrandbits(5), 0, 0, 0, 0, 0)


@cocotb.test()
async def test_loadhaz_forwarding(dut):
    
    #standard directed tests
    await check_hazards(dut, 0, 0, 0, 0, 0, 0, WB_ctrl.MEM, 8, 0, 8, 0)
    await check_hazards(dut, 0, 0, 0, 0, 0, 0, WB_ctrl.MEM, 0, 8, 8, 0)
    await check_hazards(dut, 0, 0, 0, 0, 0, 0, WB_ctrl.MEM, 8, 8, 8, 0)
    await check_hazards(dut, 0, 0, 0, 0, 0, 0, WB_ctrl.ALU, 8, 8, 8, 0)
    
    #smoke
    await check_hazards(dut, 1, 1, 8, 8, 8, 8, WB_ctrl.MEM, 8, 8, 8, 0) #chained dependencies
    await check_hazards(dut, 0, 0 ,0, 0, 0, 0, WB_ctrl.MEM, 0, 0, 0, 0) #register x0 RAW
    
    #random 
    for _ in range(1000):
        await check_hazards(dut, 1, 1, getrandbits(5), getrandbits(5), getrandbits(5), getrandbits(5), WB_ctrl.MEM, getrandbits(5), getrandbits(5), getrandbits(5), 0)
        
@cocotb.test()
async def test_controlhaz(dut):
    
    await check_hazards(dut, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1) #test flush asserted
    await check_hazards(dut, 1, 1, 8, 8, 8, 8, 0, 0, 0, 0, 1) #test ALU forwarding with flush asserted
    
    
    
        