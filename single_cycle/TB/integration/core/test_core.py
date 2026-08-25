import cocotb
from cocotb.triggers import RisingEdge, Timer, NullTrigger
from cocotb.clock import Clock
from single_cycle.TB.helpers import start_clock, tick


'''
RV32I Full Core cocotb testbench
'''

# State of registers at EOP
EXPECTED_REGS = {
    1: 0x00000005,
    2: 0x0000000A,
    3: 0xFFFFFFFF,
    4: 0x0000000F,
    5: 0x00000005, 
    6: 0x00000000,
    7: 0x0000000F,
    8: 0x0000000F,
    9: 0x00001400,
    10: 0x00000005,
    11: 0xFFFFFFFF,
    12: 0x00000001,
    13: 0x00000001,
    14: 0x00000001,
    15: 0x00000000,
    16: 0x0000000F,
    17: 0x0000000F,
    18: 0x00000001,
    19: 0x00000000,
    20: 0x00001400,
    21: 0x00000005,
    22: 0xFFFFFFFF,
    23: 0xDEADB123,
    24: 0x00001060,
    25: 0x00000068,
    26: 0x00000004,
    27: 0xDEADB123,
    28: 0xFFFFB123,
    29: 0xFFFFFFB1,
    30: 0x0000B123,
    31: 0x000000B1
}

# State of memory at EOP
EXPECTED_MEM = {
    1: 0xDEADB123,
    2: 0xB1232323
}

DONE_PC = 0xE4  # PC should stay at this count at the end with no branch/jal errors
FAIL_PC = 0xE8  # PC stays at this count if there are branch/jal errors
TIMEOUT = 1000  # cycles before timeout

async def init_test(dut):
    dut.rst_n.value = 0
    start_clock(dut)
    await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1
    await Timer(1, 'ns')

async def run_program(dut):
    
    for cycles in range(TIMEOUT):
        await tick(dut)
        PC = int(dut.PC.value)

        if (PC == DONE_PC):
            return 'done', cycles
        
        if (PC == FAIL_PC):
            return 'fail', cycles
        
    return 'timeout', TIMEOUT

def comp_reg(dut):

    errors = []
    
    for reg, expected in EXPECTED_REGS.items():
        actual = int(dut.register_file.registers[reg].value)

        if (actual != expected):
            errors.append(
                f"x{reg:<2d}: expected 0x{expected:08X} | actual 0x{actual:08X}\n"
            )

    return errors

def comp_mem(dut):
    
    errors = []

    for addr, expected in EXPECTED_MEM.items():
        actual = int(dut.data_memory.memory[addr].value)

        if(actual != expected):
            errors.append(
                f"0x{addr:08X}: expected 0x{expected:08X} | actual 0x{actual:08X}\n"
            )

    return errors

@cocotb.test()
async def test_core_integration(dut):
    
    await init_test(dut)


    status, cycles = await run_program(dut)

    assert (status != 'timeout'), (
        f"\nTimeout after {cycles} cycles\n"
        f"CPU likely stuck in expected loop\n"
    )

    assert (status != 'fail'), (
        f"\nCPU reached fail label after {cycles} cycles\n"
        f"A branch/jal was taken/not-taken incorrectly\n"
    )

    cocotb.log.info(f"CPU reached done label after {cycles} cycles\n")

    reg_errors = comp_reg(dut)
    mem_errors = comp_mem(dut)

    errors_combined = []

    if(reg_errors):
        errors_combined.append("REGISTER MISMATCH:")
        errors_combined.extend(reg_errors)
    if(mem_errors):
        errors_combined.append("MEMORY MISMATCH:")
        errors_combined.extend(mem_errors)

    assert (not errors_combined),"\nFAILED INTEGRATION TEST\n" + "\n".join(errors_combined)