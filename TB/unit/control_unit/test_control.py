import cocotb
from cocotb.triggers import Timer
from rv32i_enums import Opcodes, WB_ctrl, PC_Sel

'''
RV32I Control Unit cocotb testbench 
'''

CONTROL_TRUTH_TABLE = [
    (Opcodes.LOAD, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.MEM, 
                           ALU_op1 = 0, ALU_op2 = 1, 
                           mem_read = 1, mem_write = 0, reg_write = 1)),
    (Opcodes.STORE, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 1, 
                           mem_read = 0, mem_write = 1, reg_write = 0)),
    (Opcodes.BRANCH, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 0)),
    (Opcodes.BRANCH, 1, dict(PC_Sel = PC_Sel.BR_JAL, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 0)),
    (Opcodes.JALR, 0, dict(PC_Sel = PC_Sel.JALR, WB_ctrl = WB_ctrl.DEF_PC, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 1)), 
    (Opcodes.JAL, 0, dict(PC_Sel = PC_Sel.BR_JAL, WB_ctrl = WB_ctrl.DEF_PC, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 1)),   
    (Opcodes.OPIMM, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 1, 
                           mem_read = 0, mem_write = 0, reg_write = 1)), 
    (Opcodes.OPR, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 1)),        
    (Opcodes.AUIPC, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 1, ALU_op2 = 1, 
                           mem_read = 0, mem_write = 0, reg_write = 1)), 
    (Opcodes.LUI, 0, dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.IMM, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 1))                                                                                                     
]

async def check_control(dut, opcode, branch_taken, expected):
    dut.opcode.value = opcode
    dut.branch_taken.value = branch_taken
    await Timer(1, 'ns')

    errors = []
    def check_output(output, actual, exp):
        if actual != exp:
            errors.append(f" {output} expected {exp}, got {actual}")

    check_output("PC_Sel", int(dut.PC_Sel.value), expected["PC_Sel"])
    check_output("WB_ctrl", int(dut.writeback_ctrl.value), expected["WB_ctrl"])
    check_output("ALU_op1", int(dut.ALU_op1_ctrl.value), expected["ALU_op1"])
    check_output("ALU_op2", int(dut.ALU_op2_ctrl.value), expected["ALU_op2"])
    check_output("mem_read", int(dut.mem_read.value), expected["mem_read"])
    check_output("mem_write", int(dut.mem_write.value), expected["mem_write"])
    check_output("reg_write", int(dut.reg_write.value), expected["reg_write"])

    assert not errors, (
        f"\n FAILED CONTROL UNIT TEST\n"
        f"opcode = 0b{opcode:07b} ({opcode.name}) | branch_taken = {branch_taken} ({bool(branch_taken)})\n"
        + "\n".join(errors)
    )

@cocotb.test()
async def test_control_truth_table(dut):
    #Verify outputs for each opcode according to truth table
    for opcode, branch_taken, expected in CONTROL_TRUTH_TABLE:
        await check_control(dut, opcode, branch_taken, expected)

@cocotb.test()
async def test_control_branching(dut):
    #Verify branch_taken signal won't affect outputs if opcode isn't branch
    for opcode, _, expected in CONTROL_TRUTH_TABLE:
        if (opcode != Opcodes.BRANCH):
            await check_control(dut, opcode, 1, expected)

@cocotb.test()
async def test_control_invalid(dut):
    #Verify signals set to assigned safe defaults if opcode is invalid
    safe_def = dict(PC_Sel = PC_Sel.DEFAULT, WB_ctrl = WB_ctrl.ALU, 
                           ALU_op1 = 0, ALU_op2 = 0, 
                           mem_read = 0, mem_write = 0, reg_write = 0)
    
    await check_control(dut, 0b0000000, 0, safe_def)
    await check_control(dut, 0b1111111, 0 , safe_def)