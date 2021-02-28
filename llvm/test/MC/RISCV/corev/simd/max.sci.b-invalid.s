# RUN: not llvm-mc -triple=riscv32 --mattr=+xcorevsimd %s 2>&1 \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ERROR

cv.max.sci.b t0, t1, -33
# CHECK-ERROR: immediate must be an integer in the range [-32, 31]

cv.max.sci.b t0, t1, 32
# CHECK-ERROR: immediate must be an integer in the range [-32, 31]

cv.max.sci.b t0, t1, a0
# CHECK-ERROR: immediate must be an integer in the range [-32, 31]

cv.max.sci.b t0, 0, 0
# CHECK-ERROR: invalid operand for instruction

cv.max.sci.b 0, t1, 0
# CHECK-ERROR: invalid operand for instruction

cv.max.sci.b t0, t1
# CHECK-ERROR: too few operands for instruction

cv.max.sci.b t0, t1, 0, 0
# CHECK-ERROR: invalid operand for instruction
