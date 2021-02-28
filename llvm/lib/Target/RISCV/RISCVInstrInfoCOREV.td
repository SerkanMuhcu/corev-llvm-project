//===-- RISCVInstrInfoCOREV.td - CORE-V instructions -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the CORE-V instructions.
//
//===----------------------------------------------------------------------===//

include "RISCVInstrFormatsCOREV.td"

def CVUImm1AsmOperand : AsmOperandClass {
  let Name = "CVUImm1";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidCVUImm1";
}

class CVUImmAsmOperand<int width> : AsmOperandClass {
  let Name = "CVUImm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def cv_uimm1 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isUInt<1>(Imm);}]> {
  let ParserMatchClass = CVUImm1AsmOperand;
  let DecoderMethod = "decodeUImmOperand<1>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<1>(Imm);
    return false;
  }];
  let OperandType = "OPERAND_UIMM1";
  let OperandNamespace = "RISCVOp";
}

def cv_uimm5 : Operand<XLenVT>,
               ImmLeaf<XLenVT, [{return isUInt<5>(Imm) && (Imm & 1) == 0;}]> {
  let ParserMatchClass = CVUImmAsmOperand<5>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeUImmOperand<5>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<5>(Imm) && (Imm & 1) == 0;
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_UIMM5";
  let OperandNamespace = "RISCVOp";
}

def cv_uimm6 : Operand<XLenVT>,
               ImmLeaf<XLenVT, [{return isUInt<6>(Imm);}]> {
  let ParserMatchClass = CVUImmAsmOperand<6>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeUImmOperand<6>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<6>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_UIMM6";
  let OperandNamespace = "RISCVOp";
}

def cv_uimm12 : Operand<XLenVT>,
                ImmLeaf<XLenVT, [{return isUInt<12>(Imm) && (Imm & 1) == 0;}]> {
  let ParserMatchClass = CVUImmAsmOperand<12>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeUImmOperand<12>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<12>(Imm) && (Imm & 1) == 0;
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_UIMM12";
  let OperandNamespace = "RISCVOp";
}

//===----------------------------------------------------------------------===//
// CORE-V specific instructions
//===----------------------------------------------------------------------===//

let Predicates = [HasExtXCoreVHwlp], hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
  def CV_STARTI  : RVInstHwlp_i<0b000, (ins cv_uimm1:$imm1, cv_uimm12:$imm12),
                                "cv.starti", "$imm1, $imm12">,
                   Sched<[]>;
  def CV_ENDI    : RVInstHwlp_i<0b001, (ins cv_uimm1:$imm1, cv_uimm12:$imm12),
                                "cv.endi", "$imm1, $imm12">,
                   Sched<[]>;
  def CV_COUNT   : RVInstHwlp_r<0b010, (ins cv_uimm1:$imm1, GPR:$rs1),
                                "cv.count", "$imm1, $rs1">,
                   Sched<[]>;
  def CV_COUNTI  : RVInstHwlp_i<0b011, (ins cv_uimm1:$imm1, uimm12:$imm12),
                                "cv.counti", "$imm1, $imm12">,
                   Sched<[]>;
  def CV_SETUP   : RVInstHwlp_ri<0b100, (ins cv_uimm1:$imm1, GPR:$rs1, cv_uimm12:$imm12),
                                 "cv.setup", "$imm1, $rs1, $imm12">,
                   Sched<[]>;
  def CV_SETUPI  : RVInstHwlp_ii<0b101, (ins cv_uimm1:$imm1, uimm12:$imm12, cv_uimm5:$imm5),
                              "cv.setupi", "$imm1, $imm12, $imm5">,
                Sched<[]>;
} // Predicates = [HasExtXCoreVHwlp], hasSideEffects = 1, mayLoad = 0, mayStore = 0

let Predicates = [HasExtXCoreVMac], hasSideEffects = 0, mayLoad = 0, mayStore = 0, Constraints = "$rd = $rd_wb" in {
  // 32x32 bit macs
  def CV_MAC      : RVInstMac<0b0100001, 0b000, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2),
                              "cv.mac", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_MSU      : RVInstMac<0b0100001, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2),
                              "cv.msu", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;

  // Signed 16x16 bit macs with imm
  def CV_MACSN    : RVInstMac16I<0b10, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.macsn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACHHSN  : RVInstMac16I<0b11, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.machhsn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACSRN   : RVInstMac16I<0b10, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.macsrn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACHHSRN : RVInstMac16I<0b11, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.machhsrn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;

  // Unsigned 16x16 bit macs with imm
  def CV_MACUN    : RVInstMac16I<0b00, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.macun", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACHHUN  : RVInstMac16I<0b01, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.machhun", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACURN   : RVInstMac16I<0b00, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.macurn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MACHHURN : RVInstMac16I<0b01, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.machhurn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
} // Predicates = [HasExtXCoreVMac], hasSideEffects = 0, mayLoad = 0, mayStore = 0, Constraints = "$rd = $rd_wb"

let Predicates = [HasExtXCoreVMac], hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  // Signed 16x16 bit muls
  def CV_MULS     : RVInstMac16<0b10, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                                "cv.muls", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_MULHHS   : RVInstMac16<0b11, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                                "cv.mulhhs", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;

  // Signed 16x16 bit muls with imm
  def CV_MULSN    : RVInstMac16I<0b10, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulsn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULHHSN  : RVInstMac16I<0b11, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulhhsn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULSRN   : RVInstMac16I<0b10, 0b100, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulsrn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULHHSRN : RVInstMac16I<0b11, 0b100, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulhhsrn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;

  // Unsigned 16x16 bit muls
  def CV_MULU     : RVInstMac16<0b00, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                                "cv.mulu", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_MULHHU   : RVInstMac16<0b01, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                                "cv.mulhhu", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;

  // Unsigned 16x16 bit muls with imm
  def CV_MULUN    : RVInstMac16I<0b00, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulun", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULHHUN  : RVInstMac16I<0b01, 0b000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulhhun", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULURN   : RVInstMac16I<0b00, 0b100, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulurn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
  def CV_MULHHURN : RVInstMac16I<0b01, 0b100, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$imm5),
                                 "cv.mulhhurn", "$rd, $rs1, $rs2, $imm5", []>,
                    Sched<[]>;
} // Predicates = [HasExtXCoreVMac], hasSideEffects = 0, mayLoad = 0, mayStore = 0

let Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD" in {
  // SIMD ALU Operations
  def CV_ADD_H     : RVInstSimd<0b0000000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.add.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_ADD_SC_H  : RVInstSimd<0b0000000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.add.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_ADD_SCI_H : RVInstSimd_sci<0b000000, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.add.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_ADD_B     : RVInstSimd<0b0000000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.add.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_ADD_SC_B  : RVInstSimd<0b0000000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.add.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_ADD_SCI_B : RVInstSimd_sci<0b000000, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.add.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_ADD_DIV2 : RVInstSimd<0b0101110, 0b010, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.add.div2", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_ADD_DIV4 : RVInstSimd<0b0101110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.add.div4", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_ADD_DIV8 : RVInstSimd<0b0101110, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.add.div8", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;

  def CV_SUB_H     : RVInstSimd<0b0000100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.sub.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SUB_SC_H  : RVInstSimd<0b0000100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.sub.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SUB_SCI_H : RVInstSimd_sci<0b000010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.sub.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_SUB_B     : RVInstSimd<0b0000100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.sub.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SUB_SC_B  : RVInstSimd<0b0000100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.sub.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SUB_SCI_B : RVInstSimd_sci<0b000010, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.sub.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_SUB_DIV2 : RVInstSimd<0b0110010, 0b010, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.sub.div2", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_SUB_DIV4 : RVInstSimd<0b0110010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.sub.div4", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_SUB_DIV8 : RVInstSimd<0b0110010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.sub.div8", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;

  def CV_AVG_H     : RVInstSimd<0b0001000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.avg.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AVG_SC_H  : RVInstSimd<0b0001000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.avg.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AVG_SCI_H : RVInstSimd_sci<0b000100, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.avg.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_AVG_B     : RVInstSimd<0b0001000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.avg.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AVG_SC_B  : RVInstSimd<0b0001000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.avg.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AVG_SCI_B : RVInstSimd_sci<0b000100, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.avg.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_AVGU_H     : RVInstSimd<0b0001100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                 "cv.avgu.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_AVGU_SC_H  : RVInstSimd<0b0001100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                 "cv.avgu.sc.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_AVGU_SCI_H : RVInstSimd_sci<0b000110, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                     "cv.avgu.sci.h", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_AVGU_B     : RVInstSimd<0b0001100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                 "cv.avgu.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_AVGU_SC_B  : RVInstSimd<0b0001100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                 "cv.avgu.sc.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_AVGU_SCI_B : RVInstSimd_sci<0b000110, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                     "cv.avgu.sci.b", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;

  def CV_MIN_H     : RVInstSimd<0b0010000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.min.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MIN_SC_H  : RVInstSimd<0b0010000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.min.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MIN_SCI_H : RVInstSimd_sci<0b001000, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.min.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_MIN_B     : RVInstSimd<0b0010000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.min.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MIN_SC_B  : RVInstSimd<0b0010000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.min.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MIN_SCI_B : RVInstSimd_sci<0b001000, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.min.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_MINU_H     : RVInstSimd<0b0010100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                 "cv.minu.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MINU_SC_H  : RVInstSimd<0b0010100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                 "cv.minu.sc.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MINU_SCI_H : RVInstSimd_sci<0b001010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                     "cv.minu.sci.h", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_MINU_B     : RVInstSimd<0b0010100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                 "cv.minu.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MINU_SC_B  : RVInstSimd<0b0010100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                 "cv.minu.sc.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MINU_SCI_B : RVInstSimd_sci<0b001010, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                     "cv.minu.sci.b", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;

  def CV_MAX_H     : RVInstSimd<0b0011000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.max.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MAX_SC_H  : RVInstSimd<0b0011000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.max.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MAX_SCI_H : RVInstSimd_sci<0b001100, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.max.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_MAX_B     : RVInstSimd<0b0011000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.max.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MAX_SC_B  : RVInstSimd<0b0011000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.max.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_MAX_SCI_B : RVInstSimd_sci<0b001100, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.max.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_MAXU_H     : RVInstSimd<0b0011100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                 "cv.maxu.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MAXU_SC_H  : RVInstSimd<0b0011100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                 "cv.maxu.sc.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MAXU_SCI_H : RVInstSimd_sci<0b001110, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                     "cv.maxu.sci.h", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_MAXU_B     : RVInstSimd<0b0011100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                 "cv.maxu.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MAXU_SC_B  : RVInstSimd<0b0011100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                 "cv.maxu.sc.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_MAXU_SCI_B : RVInstSimd_sci<0b001110, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                     "cv.maxu.sci.b", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;

  def CV_SRL_H     : RVInstSimd<0b0100000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.srl.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRL_SC_H  : RVInstSimd<0b0100000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.srl.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRL_SCI_H : RVInstSimd_sci<0b010000, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                    "cv.srl.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_SRL_B     : RVInstSimd<0b0100000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.srl.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRL_SC_B  : RVInstSimd<0b0100000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.srl.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRL_SCI_B : RVInstSimd_sci<0b010000, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                    "cv.srl.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_SRA_H     : RVInstSimd<0b0100100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.sra.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRA_SC_H  : RVInstSimd<0b0100100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.sra.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRA_SCI_H : RVInstSimd_sci<0b010010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                    "cv.sra.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_SRA_B     : RVInstSimd<0b0100100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.sra.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRA_SC_B  : RVInstSimd<0b0100100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.sra.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SRA_SCI_B : RVInstSimd_sci<0b010010, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                    "cv.sra.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_SLL_H     : RVInstSimd<0b0101000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.sll.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SLL_SC_H  : RVInstSimd<0b0101000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.sll.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SLL_SCI_H : RVInstSimd_sci<0b010100, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                    "cv.sll.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_SLL_B     : RVInstSimd<0b0101000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.sll.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SLL_SC_B  : RVInstSimd<0b0101000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.sll.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_SLL_SCI_B : RVInstSimd_sci<0b010100, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                    "cv.sll.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_OR_H     : RVInstSimd<0b0101100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                               "cv.or.h", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_OR_SC_H  : RVInstSimd<0b0101100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                               "cv.or.sc.h", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_OR_SCI_H : RVInstSimd_sci<0b010110, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                   "cv.or.sci.h", "$rd, $rs1, $Imm6", []>,
                    Sched<[]>;
  def CV_OR_B     : RVInstSimd<0b0101100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                               "cv.or.b", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_OR_SC_B  : RVInstSimd<0b0101100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                               "cv.or.sc.b", "$rd, $rs1, $rs2", []>,
                    Sched<[]>;
  def CV_OR_SCI_B : RVInstSimd_sci<0b010110, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                   "cv.or.sci.b", "$rd, $rs1, $Imm6", []>,
                    Sched<[]>;

  def CV_XOR_H     : RVInstSimd<0b0110000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.xor.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_XOR_SC_H  : RVInstSimd<0b0110000, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.xor.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_XOR_SCI_H : RVInstSimd_sci<0b011000, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.xor.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_XOR_B     : RVInstSimd<0b0110000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.xor.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_XOR_SC_B  : RVInstSimd<0b0110000, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.xor.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_XOR_SCI_B : RVInstSimd_sci<0b011000, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.xor.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  def CV_AND_H     : RVInstSimd<0b0110100, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                "cv.and.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AND_SC_H  : RVInstSimd<0b0110100, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                "cv.and.sc.h", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AND_SCI_H : RVInstSimd_sci<0b011010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                    "cv.and.sci.h", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;
  def CV_AND_B     : RVInstSimd<0b0110100, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                "cv.and.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AND_SC_B  : RVInstSimd<0b0110100, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                "cv.and.sc.b", "$rd, $rs1, $rs2", []>,
                     Sched<[]>;
  def CV_AND_SCI_B : RVInstSimd_sci<0b011010, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                    "cv.and.sci.b", "$rd, $rs1, $Imm6", []>,
                     Sched<[]>;

  let rs2 = 0 in
  def CV_ABS_H : RVInstSimd<0b0111000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1),
                            "cv.abs.h", "$rd, $rs1", []>,
                 Sched<[]>;
  let rs2 = 0 in
  def CV_ABS_B : RVInstSimd<0b0111000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1),
                            "cv.abs.b", "$rd, $rs1", []>,
                 Sched<[]>;

  def CV_EXTRACT_H  : RVInstSimd_sci<0b011110, 0b110, (outs GPR:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                     "cv.extract.h", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_EXTRACT_B  : RVInstSimd_sci<0b011110, 0b111, (outs GPR:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                     "cv.extract.b", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_EXTRACTU_H : RVInstSimd_sci<0b100100, 0b110, (outs GPR:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                     "cv.extractu.h", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;
  def CV_EXTRACTU_B : RVInstSimd_sci<0b100100, 0b111, (outs GPR:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                     "cv.extractu.b", "$rd, $rs1, $Imm6", []>,
                      Sched<[]>;

  let Constraints = "$rd_wb = $rd" in
  def CV_INSERT_H : RVInstSimd_sci<0b101100, 0b110, (outs CorevV2:$rd_wb), (ins CorevV2:$rd, GPR:$rs1, cv_uimm6:$Imm6),
                                   "cv.insert.h", "$rd, $rs1, $Imm6", []>,
                    Sched<[]>;
  let Constraints = "$rd_wb = $rd" in
  def CV_INSERT_B : RVInstSimd_sci<0b101100, 0b111, (outs CorevV2:$rd_wb), (ins CorevV4:$rd, GPR:$rs1, cv_uimm6:$Imm6),
                                   "cv.insert.b", "$rd, $rs1, $Imm6", []>,
                    Sched<[]>;

  // Dop Product Instructions
  def CV_DOTUP_H     : RVInstSimd<0b1000000, 0b000, (outs GPR:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.dotup.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTUP_SC_H  : RVInstSimd<0b1000000, 0b100, (outs GPR:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.dotup.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTUP_SCI_H : RVInstSimd_sci<0b100000, 0b110, (outs GPR:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                      "cv.dotup.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_DOTUP_B     : RVInstSimd<0b1000000, 0b001, (outs GPR:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.dotup.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTUP_SC_B  : RVInstSimd<0b1000000, 0b101, (outs GPR:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.dotup.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTUP_SCI_B : RVInstSimd_sci<0b100000, 0b111, (outs GPR:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                      "cv.dotup.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_DOTUSP_H     : RVInstSimd<0b1000100, 0b000, (outs GPR:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.dotusp.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_DOTUSP_SC_H  : RVInstSimd<0b1000100, 0b100, (outs GPR:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                   "cv.dotusp.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_DOTUSP_SCI_H : RVInstSimd_sci<0b100010, 0b110, (outs GPR:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                       "cv.dotusp.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_DOTUSP_B     : RVInstSimd<0b1000100, 0b001, (outs GPR:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.dotusp.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_DOTUSP_SC_B  : RVInstSimd<0b1000100, 0b101, (outs GPR:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                   "cv.dotusp.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_DOTUSP_SCI_B : RVInstSimd_sci<0b100010, 0b111, (outs GPR:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                       "cv.dotusp.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  def CV_DOTSP_H     : RVInstSimd<0b1001100, 0b000, (outs GPR:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.dotsp.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTSP_SC_H  : RVInstSimd<0b1001100, 0b100, (outs GPR:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.dotsp.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTSP_SCI_H : RVInstSimd_sci<0b100110, 0b110, (outs GPR:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.dotsp.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_DOTSP_B     : RVInstSimd<0b1001100, 0b001, (outs GPR:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.dotsp.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTSP_SC_B  : RVInstSimd<0b1001100, 0b101, (outs GPR:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.dotsp.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_DOTSP_SCI_B : RVInstSimd_sci<0b100110, 0b111, (outs GPR:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.dotsp.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

} // Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD"

let Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD", Constraints = "$rd = $rd_wb" in {

  def CV_SDOTUP_H     : RVInstSimd<0b1010000, 0b000, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.sdotup.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTUP_SC_H  : RVInstSimd<0b1010000, 0b100, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, GPR:$rs2),
                                   "cv.sdotup.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTUP_SCI_H : RVInstSimd_sci<0b101000, 0b110, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, cv_uimm6:$Imm6),
                                       "cv.sdotup.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_SDOTUP_B     : RVInstSimd<0b1010000, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.sdotup.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTUP_SC_B  : RVInstSimd<0b1010000, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, GPR:$rs2),
                                   "cv.sdotup.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTUP_SCI_B : RVInstSimd_sci<0b101000, 0b111, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, cv_uimm6:$Imm6),
                                       "cv.sdotup.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  def CV_SDOTUSP_H     : RVInstSimd<0b1010100, 0b000, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, CorevV2:$rs2),
                                    "cv.sdotusp.h", "$rd, $rs1, $rs2", []>,
                         Sched<[]>;
  def CV_SDOTUSP_SC_H  : RVInstSimd<0b1010100, 0b100, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, GPR:$rs2),
                                    "cv.sdotusp.sc.h", "$rd, $rs1, $rs2", []>,
                         Sched<[]>;
  def CV_SDOTUSP_SCI_H : RVInstSimd_sci<0b101010, 0b110, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, simm6:$Imm6),
                                        "cv.sdotusp.sci.h", "$rd, $rs1, $Imm6", []>,
                         Sched<[]>;
  def CV_SDOTUSP_B     : RVInstSimd<0b1010100, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, CorevV4:$rs2),
                                    "cv.sdotusp.b", "$rd, $rs1, $rs2", []>,
                         Sched<[]>;
  def CV_SDOTUSP_SC_B  : RVInstSimd<0b1010100, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, GPR:$rs2),
                                    "cv.sdotusp.sc.b", "$rd, $rs1, $rs2", []>,
                         Sched<[]>;
  def CV_SDOTUSP_SCI_B : RVInstSimd_sci<0b101010, 0b111, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, simm6:$Imm6),
                                        "cv.sdotusp.sci.b", "$rd, $rs1, $Imm6", []>,
                         Sched<[]>;

  def CV_SDOTSP_H     : RVInstSimd<0b1011100, 0b000, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.sdotsp.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTSP_SC_H  : RVInstSimd<0b1011100, 0b100, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, GPR:$rs2),
                                   "cv.sdotsp.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTSP_SCI_H : RVInstSimd_sci<0b101110, 0b110, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, simm6:$Imm6),
                                       "cv.sdotsp.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_SDOTSP_B     : RVInstSimd<0b1011100, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.sdotsp.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTSP_SC_B  : RVInstSimd<0b1011100, 0b101, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, GPR:$rs2),
                                   "cv.sdotsp.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_SDOTSP_SCI_B : RVInstSimd_sci<0b101110, 0b111, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV4:$rs1, simm6:$Imm6),
                                       "cv.sdotsp.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

} // Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, Constraints = "$rd = $rd_wb", DecoderNamespace = "COREV_SIMD"

let Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD" in {
  // Shuffle & Pack instructions
  def CV_SHUFFLE_H      : RVInstSimd<0b1100000, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.shuffle.h", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_SHUFFLE_SCI_H  : RVInstSimd_sci<0b110000, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                         "cv.shuffle.sci.h", "$rd, $rs1, $Imm6", []>,
                          Sched<[]>;
  def CV_SHUFFLE_B      : RVInstSimd<0b1100000, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                     "cv.shuffle.b", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_SHUFFLE0_SCI_B : RVInstSimd_sci<0b110000, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                         "cv.shuffle0.sci.b", "$rd, $rs1, $Imm6", []>,
                          Sched<[]>;
  def CV_SHUFFLE1_SCI_B : RVInstSimd_sci<0b111010, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                         "cv.shuffle1.sci.b", "$rd, $rs1, $Imm6", []>,
                          Sched<[]>;
  def CV_SHUFFLE2_SCI_B : RVInstSimd_sci<0b111100, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                         "cv.shuffle2.sci.b", "$rd, $rs1, $Imm6", []>,
                          Sched<[]>;
  def CV_SHUFFLE3_SCI_B : RVInstSimd_sci<0b111110, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                         "cv.shuffle3.sci.b", "$rd, $rs1, $Imm6", []>,
                          Sched<[]>;
  def CV_PACK           : RVInstSimd<0b1101000, 0b000, (outs CorevV2:$rd), (ins GPR:$rs1, GPR:$rs2),
                                     "cv.pack", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_PACK_H         : RVInstSimd<0b1101001, 0b000, (outs CorevV2:$rd), (ins GPR:$rs1, GPR:$rs2),
                                     "cv.pack.h", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
} // Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD"

let Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD", Constraints = "$rd = $rd_wb" in {

  def CV_SHUFFLE2_H : RVInstSimd<0b1100100, 0b000, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, CorevV2:$rs2),
                                 "cv.shuffle2.h", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;

  def CV_SHUFFLE2_B : RVInstSimd<0b1100100, 0b001, (outs GPR:$rd_wb), (ins GPR:$rd, CorevV2:$rs1, CorevV2:$rs2),
                                 "cv.shuffle2.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_PACKHI_B   : RVInstSimd<0b1101100, 0b001, (outs CorevV4:$rd_wb), (ins CorevV4:$rd, GPR:$rs1, GPR:$rs2),
                                 "cv.packhi.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;
  def CV_PACKLO_B   : RVInstSimd<0b1110000, 0b001, (outs CorevV4:$rd_wb), (ins CorevV4:$rd, GPR:$rs1, GPR:$rs2),
                                 "cv.packlo.b", "$rd, $rs1, $rs2", []>,
                      Sched<[]>;

} // Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD", Constraints = "$rd = $rd_wb"

let Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD" in {
  // SIMD Comparison Operations
  def CV_CMPEQ_H     : RVInstSimd<0b0000010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmpeq.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPEQ_SC_H  : RVInstSimd<0b0000010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmpeq.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPEQ_SCI_H : RVInstSimd_sci<0b000001, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmpeq.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPEQ_B     : RVInstSimd<0b0000010, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmpeq.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPEQ_SC_B  : RVInstSimd<0b0000010, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmpeq.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPEQ_SCI_B : RVInstSimd_sci<0b000001, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmpeq.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPNE_H     : RVInstSimd<0b0000110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmpne.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPNE_SC_H  : RVInstSimd<0b0000110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmpne.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPNE_SCI_H : RVInstSimd_sci<0b000011, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmpne.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPNE_B     : RVInstSimd<0b0000110, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmpne.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPNE_SC_B  : RVInstSimd<0b0000110, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmpne.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPNE_SCI_B : RVInstSimd_sci<0b000011, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmpne.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPGT_H     : RVInstSimd<0b0001010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmpgt.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGT_SC_H  : RVInstSimd<0b0001010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmpgt.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGT_SCI_H : RVInstSimd_sci<0b000101, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmpgt.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPGT_B     : RVInstSimd<0b0001010, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmpgt.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGT_SC_B  : RVInstSimd<0b0001010, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmpgt.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGT_SCI_B : RVInstSimd_sci<0b000101, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmpgt.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPGE_H     : RVInstSimd<0b0001110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmpge.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGE_SC_H  : RVInstSimd<0b0001110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmpge.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGE_SCI_H : RVInstSimd_sci<0b000111, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmpge.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPGE_B     : RVInstSimd<0b0001110, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmpge.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGE_SC_B  : RVInstSimd<0b0001110, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmpge.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPGE_SCI_B : RVInstSimd_sci<0b000111, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmpge.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPLT_H     : RVInstSimd<0b0010010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmplt.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLT_SC_H  : RVInstSimd<0b0010010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmplt.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLT_SCI_H : RVInstSimd_sci<0b001001, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmplt.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPLT_B     : RVInstSimd<0b0010010, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmplt.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLT_SC_B  : RVInstSimd<0b0010010, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmplt.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLT_SCI_B : RVInstSimd_sci<0b001001, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmplt.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPLE_H     : RVInstSimd<0b0010110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                  "cv.cmple.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLE_SC_H  : RVInstSimd<0b0010110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                  "cv.cmple.sc.h", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLE_SCI_H : RVInstSimd_sci<0b001011, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, simm6:$Imm6),
                                      "cv.cmple.sci.h", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;
  def CV_CMPLE_B     : RVInstSimd<0b0010110, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                  "cv.cmple.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLE_SC_B  : RVInstSimd<0b0010110, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                  "cv.cmple.sc.b", "$rd, $rs1, $rs2", []>,
                       Sched<[]>;
  def CV_CMPLE_SCI_B : RVInstSimd_sci<0b001011, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, simm6:$Imm6),
                                      "cv.cmple.sci.b", "$rd, $rs1, $Imm6", []>,
                       Sched<[]>;

  def CV_CMPGTU_H     : RVInstSimd<0b0011010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.cmpgtu.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGTU_SC_H  : RVInstSimd<0b0011010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                   "cv.cmpgtu.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGTU_SCI_H : RVInstSimd_sci<0b001101, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpgtu.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_CMPGTU_B     : RVInstSimd<0b0011010, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.cmpgtu.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGTU_SC_B  : RVInstSimd<0b0011010, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                   "cv.cmpgtu.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGTU_SCI_B : RVInstSimd_sci<0b001101, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpgtu.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  def CV_CMPGEU_H     : RVInstSimd<0b0011110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.cmpgeu.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGEU_SC_H  : RVInstSimd<0b0011110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                   "cv.cmpgeu.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGEU_SCI_H : RVInstSimd_sci<0b001111, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpgeu.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_CMPGEU_B     : RVInstSimd<0b0011110, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.cmpgeu.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGEU_SC_B  : RVInstSimd<0b0011110, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                   "cv.cmpgeu.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPGEU_SCI_B : RVInstSimd_sci<0b001111, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpgeu.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  def CV_CMPLTU_H     : RVInstSimd<0b0100010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.cmpltu.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLTU_SC_H  : RVInstSimd<0b0100010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                   "cv.cmpltu.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLTU_SCI_H : RVInstSimd_sci<0b010001, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpltu.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_CMPLTU_B     : RVInstSimd<0b0100010, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.cmpltu.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLTU_SC_B  : RVInstSimd<0b0100010, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                   "cv.cmpltu.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLTU_SCI_B : RVInstSimd_sci<0b010001, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpltu.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  def CV_CMPLEU_H     : RVInstSimd<0b0100110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                   "cv.cmpleu.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLEU_SC_H  : RVInstSimd<0b0100110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, GPR:$rs2),
                                   "cv.cmpleu.sc.h", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLEU_SCI_H : RVInstSimd_sci<0b010011, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpleu.sci.h", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;
  def CV_CMPLEU_B     : RVInstSimd<0b0100110, 0b001, (outs CorevV4:$rd), (ins CorevV4:$rs1, CorevV4:$rs2),
                                   "cv.cmpleu.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLEU_SC_B  : RVInstSimd<0b0100110, 0b101, (outs CorevV4:$rd), (ins CorevV4:$rs1, GPR:$rs2),
                                   "cv.cmpleu.sc.b", "$rd, $rs1, $rs2", []>,
                        Sched<[]>;
  def CV_CMPLEU_SCI_B : RVInstSimd_sci<0b010011, 0b111, (outs CorevV4:$rd), (ins CorevV4:$rs1, cv_uimm6:$Imm6),
                                       "cv.cmpleu.sci.b", "$rd, $rs1, $Imm6", []>,
                        Sched<[]>;

  // SIMD Complex-number Operations
  def CV_SUBROTMJ       : RVInstSimd<0b0110110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.subrotmj", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_SUBROTMJ_DIV2  : RVInstSimd<0b0110110, 0b010, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.subrotmj.div2", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_SUBROTMJ_DIV4  : RVInstSimd<0b0110110, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.subrotmj.div4", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_SUBROTMJ_DIV8  : RVInstSimd<0b0110110, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.subrotmj.div8", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  let rs2 = 0 in
  def CV_CPLXCONJ       : RVInstSimd<0b0101110, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1),
                                     "cv.cplxconj", "$rd, $rs1", []>,
                          Sched<[]>;
  def CV_CPLXMUL_R      : RVInstSimd<0b0101010, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.r", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_R_DIV2 : RVInstSimd<0b0101010, 0b010, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.r.div2", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_R_DIV4 : RVInstSimd<0b0101010, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.r.div4", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_R_DIV8 : RVInstSimd<0b0101010, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.r.div8", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_I      : RVInstSimd<0b0101011, 0b000, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.i", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_I_DIV2 : RVInstSimd<0b0101011, 0b010, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.i.div2", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_I_DIV4 : RVInstSimd<0b0101011, 0b100, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.i.div4", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;
  def CV_CPLXMUL_I_DIV8 : RVInstSimd<0b0101011, 0b110, (outs CorevV2:$rd), (ins CorevV2:$rs1, CorevV2:$rs2),
                                     "cv.cplxmul.i.div8", "$rd, $rs1, $rs2", []>,
                          Sched<[]>;

} // Predicates = [HasExtXCoreVSimd], hasSideEffects = 0, mayLoad = 0, mayStore = 0, DecoderNamespace = "COREV_SIMD"


//===----------------------------------------------------------------------===//
// CORE-V specific helper fragments
//===----------------------------------------------------------------------===//

def powerOf2 : ImmLeaf<XLenVT, [{ return isPowerOf2_32(Imm); }]>;

def shiftRound : PatFrag<(ops node:$value, node:$shiftAmount),
                         (sra (add node:$value, powerOf2), node:$shiftAmount), [{

  if (auto powerOf2 = dyn_cast<ConstantSDNode>(N->getOperand(0)->getOperand(1)))
    return (powerOf2->getZExtValue() << 1) == (1U << N->getConstantOperandVal(1));
  return false;
}]>;

def ushiftRound : PatFrag<(ops node:$value, node:$shiftAmount),
                          (srl (add node:$value, powerOf2), node:$shiftAmount), [{

  if (auto powerOf2 = dyn_cast<ConstantSDNode>(N->getOperand(0)->getOperand(1)))
    return (powerOf2->getZExtValue() << 1) == (1U << N->getConstantOperandVal(1));
  return false;
}]>;

//===----------------------------------------------------------------------===//
// Patterns for MAC operations
//===----------------------------------------------------------------------===//

def muls   : PatFrag<(ops node:$rs1, node:$rs2),
                     (mul (sext_inreg node:$rs1, i16), (sext_inreg node:$rs2, i16))>;
def mulhhs : PatFrag<(ops node:$rs1, node:$rs2),
                     (mul (sra node:$rs1, (i32 16)), (sra node:$rs2, (i32 16)))>;
def mulu   : PatFrag<(ops node:$rs1, node:$rs2),
                     (mul (and node:$rs1, 0xffff), (and node:$rs2, 0xffff))>;
def mulhhu : PatFrag<(ops node:$rs1, node:$rs2),
                     (mul (srl node:$rs1, (i32 16)), (srl node:$rs2, (i32 16)))>;

def macs   : PatFrag<(ops node:$rd, node:$rs1, node:$rs2),
                     (add node:$rd, (muls node:$rs1, node:$rs2))>;
def machhs : PatFrag<(ops node:$rd, node:$rs1, node:$rs2),
                     (add node:$rd, (mulhhs node:$rs1, node:$rs2))>;
def macu   : PatFrag<(ops node:$rd, node:$rs1, node:$rs2),
                     (add node:$rd, (mulu node:$rs1, node:$rs2))>;
def machhu : PatFrag<(ops node:$rd, node:$rs1, node:$rs2),
                     (add node:$rd, (mulhhu node:$rs1, node:$rs2))>;


let Predicates = [HasExtXCoreVMac] in {

def : Pat<(add GPR:$rd, (mul GPR:$rs1, GPR:$rs2)),
          (CV_MAC GPR:$rd, GPR:$rs1, GPR:$rs2)>;
def : Pat<(sub GPR:$rd, (mul GPR:$rs1, GPR:$rs2)),
          (CV_MSU GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<(muls GPR:$rs1, GPR:$rs2),
          (CV_MULS GPR:$rs1, GPR:$rs2)>;
def : Pat<(mulhhs GPR:$rs1, GPR:$rs2),
          (CV_MULHHS GPR:$rs1, GPR:$rs2)>;
def : Pat<(sra (muls GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULSN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(sra (mulhhs GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULHHSN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(shiftRound (muls GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULSRN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(shiftRound (mulhhs GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULHHSRN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<(mulu GPR:$rs1, GPR:$rs2),
          (CV_MULU GPR:$rs1, GPR:$rs2)>;
def : Pat<(mulhhu GPR:$rs1, GPR:$rs2),
          (CV_MULHHU GPR:$rs1, GPR:$rs2)>;
def : Pat<(srl (mulu GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULUN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(srl (mulhhu GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULHHUN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(ushiftRound (mulu GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULURN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(ushiftRound (mulhhu GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MULHHURN GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<(sra (macs GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACSN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(sra (machhs GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACHHSN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(shiftRound (macs GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACSRN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(shiftRound (machhs GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACHHSRN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<(srl (macu GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACUN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(srl (machhu GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACHHUN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(ushiftRound (macu GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACURN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;
def : Pat<(ushiftRound (machhu GPR:$rd, GPR:$rs1, GPR:$rs2), uimm5:$Is3),
          (CV_MACHHURN GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;


}
