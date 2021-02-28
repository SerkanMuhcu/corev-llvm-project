# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.avg.sc.h t0, t1, t2
# CHECK-INSTR: cv.avg.sc.h t0, t1, t2
# CHECK-ENCODING: [0xd7,0x42,0x73,0x10]

cv.avg.sc.h a0, a1, a2
# CHECK-INSTR: cv.avg.sc.h a0, a1, a2
# CHECK-ENCODING: [0x57,0xc5,0xc5,0x10]
