"""
gen_lui_test.py - directed test vector generator for the LUI instruction.

Produces lui_test.hex, a tiny program that exercises LUI across several
corner cases, then halts. Paired with tb_lui.sv, which checks the resulting
register-file contents.

Cases covered:
  - basic upper-immediate load            (x20 = 0x10000000)
  - arbitrary 20-bit pattern              (x5  = 0xDEADB000)
  - all-ones upper field (no sign-ext!)   (x6  = 0xFFFFF000)
  - LUI + ADDI "load 32-bit constant"     (x7  = 0x12345678)
  - MSB set, confirm no sign extension    (x8  = 0x80000000)
"""

def addi(rd, rs1, imm):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x13

def lui(rd, imm20):
    imm20 &= 0xFFFFF
    return (imm20 << 12) | (rd << 7) | 0x37

def beq(rs1, rs2, offset):
    o = offset & 0x1FFF
    b12   = (o >> 12) & 1
    b10_5 = (o >>  5) & 0x3F
    b4_1  = (o >>  1) & 0xF
    b11   = (o >> 11) & 1
    return (b12 << 31) | (b10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (0 << 12) | (b4_1 << 8) | (b11 << 7) | 0x63

prog = [
    lui(20, 0x10000),     # x20 = 0x10000000
    lui(5,  0xDEADB),     # x5  = 0xDEADB000
    lui(6,  0xFFFFF),     # x6  = 0xFFFFF000
    lui(7,  0x12345),     # x7  = 0x12345000
    addi(7, 7, 0x678),    # x7  = 0x12345678
    lui(8,  0x80000),     # x8  = 0x80000000
    beq(0, 0, 0),         # halt (branch to self)
]

with open("lui_test.hex", "w") as f:
    for instr in prog:
        f.write(f"{instr:08X}\n")

print(f"wrote {len(prog)} instructions to lui_test.hex")
