# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.cmpne.sci.b t0, t1, 0
# CHECK-INSTR: cv.cmpne.sci.b t0, t1, 0
# CHECK-ENCODING: [0xd7,0x72,0x03,0x0c]

cv.cmpne.sci.b t0, t1, 16
# CHECK-INSTR: cv.cmpne.sci.b t0, t1, 16
# CHECK-ENCODING: [0xd7,0x72,0x83,0x0c]

cv.cmpne.sci.b a0, zero, 31
# CHECK-INSTR: cv.cmpne.sci.b a0, zero, 31
# CHECK-ENCODING: [0x57,0x75,0xf0,0x0e]
