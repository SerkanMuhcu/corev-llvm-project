# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.shuffle0.sci.b t0, t1, 0
# CHECK-INSTR: cv.shuffle0.sci.b t0, t1, 0
# CHECK-ENCODING: [0xd7,0x72,0x03,0xc0]

cv.shuffle0.sci.b t0, t1, 32
# CHECK-INSTR: cv.shuffle0.sci.b t0, t1, 32
# CHECK-ENCODING: [0xd7,0x72,0x03,0xc1]

cv.shuffle0.sci.b a0, zero, 63
# CHECK-INSTR: cv.shuffle0.sci.b a0, zero, 63
# CHECK-ENCODING: [0x57,0x75,0xf0,0xc3]
