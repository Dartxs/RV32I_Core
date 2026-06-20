import cocotb
from cocotb.clock import Clock

def signed_cast(val):

    if(val & (1 << 31)): #check if MSB is 1(signed)
        return (val - (1 << 32)) #force python to interpret value as negative if signed
    else:
        return val
    
def start_clock(dut, period=10):
    clock = Clock(dut.clk, period, 'ns')
    cocotb.start_soon(clock.start())

def sign_extend(val, n):

    if(val & (1 << (n-1))):
        val |= ~((1 << n) - 1)
    return val & 0xFFFFFFFF