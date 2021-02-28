# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.sub.div2 t0, t1, t2
# CHECK-INSTR: cv.sub.div2 t0, t1, t2
# CHECK-ENCODING: [0xd7,0x22,0x73,0x64]

cv.sub.div2 a0, a1, a2
# CHECK-INSTR: cv.sub.div2 a0, a1, a2
# CHECK-ENCODING: [0x57,0xa5,0xc5,0x64]
