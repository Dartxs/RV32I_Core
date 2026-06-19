import cocotb
from cocotb.triggers import Timer, RisingEdge
import random
from helpers import start_clock, signed_cast
from rv32i_enums import Funct3

'''
RV32I Data Memory cocotb testbench
'''

async def init_test(dut):
    dut.rst_n.value = 0
    dut.mem_write.value = 0
    dut.mem_read.value = 0
    dut.funct3.value = 0
    dut.address.value = 0
    dut.write_data.value = 0
    
    start_clock(dut)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await Timer(1, 'ns')

async def mem_write(dut, addr, data, funct3):
    dut.address.value = addr
    dut.write_data.value = data
    dut.funct3.value = funct3

    dut.mem_write.value = 1
    await RisingEdge(dut.clk)
    dut.mem_write.value = 0
    await Timer(1, 'ns')

async def comp_read(dut, addr, expected, funct3):
    dut.address.value = addr
    dut.funct3.value = funct3

    dut.mem_read.value = 1
    await Timer(1, 'ns')
    actual = int(dut.read_data.value)
    dut.mem_read.value = 0

    assert (actual == expected), (
        f"\nFAILED READ TEST\n"
        f"address = 0x{addr:08X} | funct3 = 0b{funct3:03b} ({funct3.name})\n"
        f"expected 0x{expected:08X} | actual 0x{actual:08X}\n"
    )

@cocotb.test()
async def test_mem_word(dut):

    await init_test(dut)

    expected = {}

    for i in range(500):
        addr = random.getrandbits(11) & 0x7FC
        data = random.getrandbits(32)
        expected[addr] = data
        await mem_write(dut, addr, data, Funct3.WORD)

    for addr, data in expected.items():
        await comp_read(dut, addr, data, Funct3.WORD)

@cocotb.test()
async def test_mem_halfword(dut):

    await init_test(dut)

    expected = {}

    for i in range(500):
        addr = random.getrandbits(11) & 0x7FE
        data = random.getrandbits(16)
        expected[addr] = data
        await mem_write(dut, addr, data, Funct3.HALFWORD)

    for addr, data in expected.items():
        await comp_read(dut, addr, signed_cast(data), Funct3.HALFWORD)
        await comp_read(dut, addr, data, Funct3.HALFWORD_U) #Verify unsigned halfword loads

@cocotb.test()
async def test_mem_byte(dut):

    await init_test(dut)

    expected = {}

    for i in range(500):
        addr = random.getrandbits(11)
        data = random.getrandbits(8)
        expected[addr] = data
        await mem_write(dut, addr, data, Funct3.BYTE)

    for addr, data in expected.items():
        await comp_read(dut, addr, signed_cast(data), Funct3.BYTE)
        await comp_read(dut, addr, data, Funct3.BYTE_U)

@cocotb.test()
async def test_mem_misaligned(dut):

    await init_test(dut)

    await mem_write(dut, 0, 0xDEADBEEF, Funct3.WORD)

    #These writes should be ignored
    await mem_write(dut, 1, 0xC0C0C0C0, Funct3.WORD) #attempt to write WORD to address 1
    await mem_write(dut, 3, 0x1234, Funct3.HALFWORD) #attempt to write HALFWORD to address 3
    
    #Check that address 0 should still contain 0xDEADBEEF using read
    await comp_read(dut, 0, 0xDEADBEEF, Funct3.WORD)

    #These reads should output 0 
    await comp_read(dut, 1, 0, Funct3.WORD)
    await comp_read(dut, 1, 0, Funct3.HALFWORD)

