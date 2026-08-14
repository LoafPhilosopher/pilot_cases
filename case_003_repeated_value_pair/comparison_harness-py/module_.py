import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_
import _dafny
import System_

# Module: module_

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Counterexample(noArgsParameter__):
        d_0_values_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 4)
        d_0_values_ = nw0_
        rhs0_ = 0
        rhs1_ = 1
        rhs2_ = 1
        rhs3_ = 0
        lhs0_ = d_0_values_
        lhs1_ = 0
        lhs2_ = d_0_values_
        lhs3_ = 1
        lhs4_ = d_0_values_
        lhs5_ = 2
        lhs6_ = d_0_values_
        lhs7_ = 3
        lhs0_[lhs1_] = rhs0_
        lhs2_[lhs3_] = rhs1_
        lhs4_[lhs5_] = rhs2_
        lhs6_[lhs7_] = rhs3_
        d_1_generatedX_: int
        d_2_generatedY_: int
        out0_: int
        out1_: int
        out0_, out1_ = default__.ChooseWitnesses(d_0_values_)
        d_1_generatedX_ = out0_
        d_2_generatedY_ = out1_
        d_3_groundX_: int
        d_4_groundY_: int
        out2_: int
        out3_: int
        out2_, out3_ = default__.Search(d_0_values_)
        d_3_groundX_ = out2_
        d_4_groundY_ = out3_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "input:        "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(_dafny.SeqWithoutIsStrInference((d_0_values_)[::])))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "ground truth: ("))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_3_groundX_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_4_groundY_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ")\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "generated:    ("))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_generatedX_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_2_generatedY_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ")\n"))).VerbatimString(False))
        d_5_threeValues_: _dafny.Array
        nw1_ = _dafny.Array(int(0), 6)
        d_5_threeValues_ = nw1_
        rhs4_ = 0
        rhs5_ = 1
        rhs6_ = 2
        lhs8_ = d_5_threeValues_
        lhs9_ = 0
        lhs10_ = d_5_threeValues_
        lhs11_ = 1
        lhs12_ = d_5_threeValues_
        lhs13_ = 2
        lhs8_[lhs9_] = rhs4_
        lhs10_[lhs11_] = rhs5_
        lhs12_[lhs13_] = rhs6_
        rhs7_ = 2
        rhs8_ = 1
        rhs9_ = 0
        lhs14_ = d_5_threeValues_
        lhs15_ = 3
        lhs16_ = d_5_threeValues_
        lhs17_ = 4
        lhs18_ = d_5_threeValues_
        lhs19_ = 5
        lhs14_[lhs15_] = rhs7_
        lhs16_[lhs17_] = rhs8_
        lhs18_[lhs19_] = rhs9_
        d_6_generatedX2_: int
        d_7_generatedY2_: int
        out4_: int
        out5_: int
        out4_, out5_ = default__.ChooseWitnesses(d_5_threeValues_)
        d_6_generatedX2_ = out4_
        d_7_generatedY2_ = out5_
        d_8_groundX2_: int
        d_9_groundY2_: int
        out6_: int
        out7_: int
        out6_, out7_ = default__.Search(d_5_threeValues_)
        d_8_groundX2_ = out6_
        d_9_groundY2_ = out7_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\ninput:        "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(_dafny.SeqWithoutIsStrInference((d_5_threeValues_)[::])))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "ground truth: ("))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_8_groundX2_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_9_groundY2_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ")\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "generated:    ("))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_6_generatedX2_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_7_generatedY2_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ")\n"))).VerbatimString(False))

    @staticmethod
    def ChooseWitnesses(values):
        x: int = int(0)
        y: int = int(0)
        x = 0
        d_10_foundX_: bool
        d_10_foundX_ = False
        d_11_i_: int
        d_11_i_ = 0
        while ((d_11_i_) < ((values).length(0))) and (not(d_10_foundX_)):
            d_12_j_: int
            d_12_j_ = (d_11_i_) + (1)
            while ((d_12_j_) < ((values).length(0))) and (not(d_10_foundX_)):
                if ((values)[d_11_i_]) == ((values)[d_12_j_]):
                    x = (values)[d_11_i_]
                    d_10_foundX_ = True
                elif True:
                    pass
                d_12_j_ = (d_12_j_) + (1)
            d_11_i_ = (d_11_i_) + (1)
        y = 0
        d_13_foundY_: bool
        d_13_foundY_ = False
        d_11_i_ = 0
        while ((d_11_i_) < ((values).length(0))) and (not(d_13_foundY_)):
            d_14_j_: int
            d_14_j_ = (d_11_i_) + (1)
            while ((d_14_j_) < ((values).length(0))) and (not(d_13_foundY_)):
                if (((values)[d_11_i_]) == ((values)[d_14_j_])) and (((values)[d_11_i_]) != (x)):
                    y = (values)[d_11_i_]
                    d_13_foundY_ = True
                elif True:
                    pass
                d_14_j_ = (d_14_j_) + (1)
            d_11_i_ = (d_11_i_) + (1)
        return x, y

    @staticmethod
    def Search(a):
        p: int = int(0)
        q: int = int(0)
        d_15_d_: _dafny.Array
        nw2_ = _dafny.Array(int(0), ((a).length(0)) - (2))
        d_15_d_ = nw2_
        d_16_i_: int
        d_16_i_ = 0
        while (d_16_i_) < ((d_15_d_).length(0)):
            rhs10_ = -1
            rhs11_ = (d_16_i_) + (1)
            lhs20_ = d_15_d_
            lhs21_ = d_16_i_
            lhs20_[lhs21_] = rhs10_
            d_16_i_ = rhs11_
        rhs12_ = 0
        rhs13_ = 0
        rhs14_ = 1
        d_16_i_ = rhs12_
        p = rhs13_
        q = rhs14_
        while True:
            d_17_k_: int
            d_17_k_ = (d_15_d_)[(a)[d_16_i_]]
            if (d_17_k_) == (-1):
                index0_ = (a)[d_16_i_]
                (d_15_d_)[index0_] = d_16_i_
            elif True:
                if (p) != (q):
                    rhs15_ = (a)[d_16_i_]
                    rhs16_ = (a)[d_16_i_]
                    p = rhs15_
                    q = rhs16_
                elif (p) == ((a)[d_16_i_]):
                    pass
                elif True:
                    q = (a)[d_16_i_]
                    return p, q
            d_16_i_ = (d_16_i_) + (1)
        return p, q

