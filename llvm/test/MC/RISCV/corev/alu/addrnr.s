# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevalu -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.addrnr t0, t1, t2
# CHECK-INSTR: cv.addrnr t0, t1, t2
# CHECK-ENCODING: [0xdb,0x62,0x73,0x40]

cv.addrnr a0, a1, a2
# CHECK-INSTR: cv.addrnr a0, a1, a2
# CHECK-ENCODING: [0x5b,0xe5,0xc5,0x40]
