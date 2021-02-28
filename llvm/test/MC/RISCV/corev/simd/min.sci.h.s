# RUN: llvm-mc -triple=riscv32 --mattr=+xcorevsimd -show-encoding %s \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INSTR

cv.min.sci.h t0, t1, 0
# CHECK-INSTR: cv.min.sci.h t0, t1, 0
# CHECK-ENCODING: [0xd7,0x62,0x03,0x20]

cv.min.sci.h t0, t1, 16
# CHECK-INSTR: cv.min.sci.h t0, t1, 16
# CHECK-ENCODING: [0xd7,0x62,0x83,0x20]

cv.min.sci.h a0, zero, 31
# CHECK-INSTR: cv.min.sci.h a0, zero, 31
# CHECK-ENCODING: [0x57,0x65,0xf0,0x22]
