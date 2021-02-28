# RUN: not llvm-mc -triple=riscv32 --mattr=+xcorevsimd %s 2>&1 \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ERROR

cv.cplxconj t0, 0
# CHECK-ERROR: invalid operand for instruction

cv.cplxconj 0, t1
# CHECK-ERROR: invalid operand for instruction

cv.cplxconj t0
# CHECK-ERROR: too few operands for instruction

cv.cplxconj t0, t1, t2
# CHECK-ERROR: invalid operand for instruction
