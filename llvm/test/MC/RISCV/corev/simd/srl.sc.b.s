# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.srl.sc.b t0, t1, t2
# CHECK-INSTR: cv.srl.sc.b t0, t1, t2
# CHECK-ENCODING: [0xd7,0x52,0x73,0x40]

cv.srl.sc.b a0, a1, a2
# CHECK-INSTR: cv.srl.sc.b a0, a1, a2
# CHECK-ENCODING: [0x57,0xd5,0xc5,0x40]
