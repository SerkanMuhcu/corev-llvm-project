# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.shuffle.h t0, t1, t2
# CHECK-INSTR: cv.shuffle.h t0, t1, t2
# CHECK-ENCODING: [0xd7,0x02,0x73,0xc0]

cv.shuffle.h a0, a1, a2
# CHECK-INSTR: cv.shuffle.h a0, a1, a2
# CHECK-ENCODING: [0x57,0x85,0xc5,0xc0]
