import cocotb
from cocotb.triggers import Timer, RisingEdge
import random
from helpers import start_clock

'''
RV32I Register File cocotb testbench

RTL module is reset at the start of each test to ensure no reads to undefined values
'''

async def init_test(dut):
    dut.rst_n.value = 0
    dut.dbug_addr.value = 0

    start_clock(dut)
    await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    await Timer(1, 'ns')

async def comp_read_rs1(dut, rs1, expected):
    dut.rs1.value = rs1

    await Timer(1, 'ns')

    actual = int(dut.op1.value)
    
    assert (actual == expected), ( 
        f"\nFAILED READ TEST\n"
        f" rs1 = 0x{rs1:02X}\n"
        f"expected op1 = 0x{expected:08X} | actual op1 = 0x{actual:08X}\n"
    ) 

async def comp_read_rs2(dut, rs2, expected):
    dut.rs2.value = rs2

    await Timer(1, 'ns')

    actual = int(dut.op2.value)
    
    assert (actual == expected), ( 
        f"\nFAILED READ TEST\n"
        f" rs2 = 0x{rs2:02X}\n"
        f"expected op2 = 0x{expected:08X} | actual op2 = 0x{actual:08X}\n"
    ) 

async def reg_write(dut, rd, val):
    dut.reg_write.value = 1
    dut.rd.value = rd
    dut.writeback_data.value = val

    await RisingEdge(dut.clk)

    dut.reg_write.value = 0
    
    await Timer(1, 'ns')


@cocotb.test()
async def test_regfile_smoke(dut):

    #test reset
    await init_test(dut)
    dut.rd.value = 0
    dut.reg_write.value = 0
    dut.writeback_data.value = 0

    dut.rst_n.value = 1

    for i in range (32):
        await comp_read_rs1(dut, i, 0)
        await comp_read_rs2(dut, i, 0)

    #test write to x0
    await reg_write(dut, 0, 0xC0C0C0C0) # attempt write non-zero to register x0

    await comp_read_rs1(dut, 0, 0) #compare value in x0 to 0 to ensure previous write was ignored by RTL module
    await comp_read_rs2(dut, 0, 0)
        

@cocotb.test()
async def test_regfile_readwrite(dut):

    await init_test(dut)
    expected_list = [0] * 32

    #random read write tests
    for i in range (1000):

        addr_write = random.randint(0, 31)
        addr_read1 = random.randint(0, 31)
        addr_read2 = random.randint(0, 31)
        write_val = random.getrandbits(32)

        if(addr_write != 0):
            expected_list[addr_write] = write_val

        await reg_write(dut, addr_write, write_val)

        await comp_read_rs1(dut, addr_read1, expected_list[addr_read1])
        await comp_read_rs2(dut, addr_read2, expected_list[addr_read2])

