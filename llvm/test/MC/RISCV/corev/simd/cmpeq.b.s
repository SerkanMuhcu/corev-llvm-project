# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.cmpeq.b t0, t1, t2
# CHECK-INSTR: cv.cmpeq.b t0, t1, t2
# CHECK-ENCODING: [0xd7,0x12,0x73,0x04]

cv.cmpeq.b a0, a1, a2
# CHECK-INSTR: cv.cmpeq.b a0, a1, a2
# CHECK-ENCODING: [0x57,0x95,0xc5,0x04]
