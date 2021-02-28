# RUN: not llvm-mc -triple=riscv32 --mattr=+xcorevsimd %s 2>&1 \
# RUN:        | FileCheck %s --check-prefixes=CHECK-ERROR

cv.add.div8 t0, t1, 0
# CHECK-ERROR: invalid operand for instruction

cv.add.div8 t0, 0, t2
# CHECK-ERROR: invalid operand for instruction

cv.add.div8 0, t1, t2
# CHECK-ERROR: invalid operand for instruction

cv.add.div8 t0, t1
# CHECK-ERROR: too few operands for instruction

cv.add.div8 t0, t1, t2, a0
# CHECK-ERROR: invalid operand for instruction
