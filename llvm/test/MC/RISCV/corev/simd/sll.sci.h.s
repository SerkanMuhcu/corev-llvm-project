# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.sll.sci.h t0, t1, 0
# CHECK-INSTR: cv.sll.sci.h t0, t1, 0
# CHECK-ENCODING: [0xd7,0x62,0x03,0x50]

cv.sll.sci.h t0, t1, 32
# CHECK-INSTR: cv.sll.sci.h t0, t1, 32
# CHECK-ENCODING: [0xd7,0x62,0x03,0x51]

cv.sll.sci.h a0, zero, 63
# CHECK-INSTR: cv.sll.sci.h a0, zero, 63
# CHECK-ENCODING: [0x57,0x65,0xf0,0x53]
