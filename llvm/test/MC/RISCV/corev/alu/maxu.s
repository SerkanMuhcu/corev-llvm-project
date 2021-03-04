# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevalu -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.maxu t0, t1, t2
# CHECK-INSTR: cv.maxu t0, t1, t2
# CHECK-ENCODING: [0xb3,0x72,0x73,0x04]

cv.maxu a0, a1, a2
# CHECK-INSTR: cv.maxu a0, a1, a2
# CHECK-ENCODING: [0x33,0xf5,0xc5,0x04]
