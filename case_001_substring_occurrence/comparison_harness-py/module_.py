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
        d_0_source_: _dafny.Seq
        d_0_source_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "a"))
        d_1_pattern_: _dafny.Seq
        d_1_pattern_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "b"))
        d_2_originalOk_: bool
        d_3_originalIndex_: int
        out0_: bool
        out1_: int
        out0_, out1_ = default__.FindFirstOccurrence(d_0_source_, d_1_pattern_)
        d_2_originalOk_ = out0_
        d_3_originalIndex_ = out1_
        d_4_generatedOk_: bool
        d_5_generatedIndex_: int
        out2_: bool
        out3_: int
        out2_, out3_ = default__.ComputeWitness(d_0_source_, d_1_pattern_)
        d_4_generatedOk_ = out2_
        d_5_generatedIndex_ = out3_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "input: source=\""))).VerbatimString(False))
        _dafny.print((d_0_source_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\", pattern=\""))).VerbatimString(False))
        _dafny.print((d_1_pattern_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\"\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "ground truth: ok="))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_2_originalOk_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", index="))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_3_originalIndex_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "generated:    ok="))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_4_generatedOk_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ", index="))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_5_generatedIndex_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

    @staticmethod
    def ComputeWitness(source, pattern):
        ok: bool = False
        index: int = int(0)
        ok = False
        index = 0
        d_6_i_: int
        d_6_i_ = 0
        while (d_6_i_) <= (len(source)):
            if (pattern) <= (_dafny.SeqWithoutIsStrInference((source)[d_6_i_::])):
                ok = True
                index = d_6_i_
                return ok, index
            d_6_i_ = (d_6_i_) + (1)
        return ok, index

    @staticmethod
    def FindFirstOccurrence(str1, str2):
        found: bool = False
        i: int = int(0)
        if (len(str2)) == (0):
            rhs0_ = True
            rhs1_ = 0
            found = rhs0_
            i = rhs1_
        elif (len(str1)) < (len(str2)):
            rhs2_ = False
            rhs3_ = 0
            found = rhs2_
            i = rhs3_
        elif True:
            rhs4_ = False
            rhs5_ = (len(str2)) - (1)
            found = rhs4_
            i = rhs5_
            while (not(found)) and ((i) < (len(str1))):
                d_7_j_: int
                d_7_j_ = (len(str2)) - (1)
                while (not(found)) and (((str1)[i]) == ((str2)[d_7_j_])):
                    if (d_7_j_) == (0):
                        found = True
                    elif True:
                        rhs6_ = (i) - (1)
                        rhs7_ = (d_7_j_) - (1)
                        i = rhs6_
                        d_7_j_ = rhs7_
                if not(found):
                    i = ((i) + (len(str2))) - (d_7_j_)
        return found, i

    @staticmethod
    def default_Main_():
        d_8_str1a_: _dafny.Seq
        d_9_str1b_: _dafny.Seq
        rhs8_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "string"))
        rhs9_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " in Dafny is a sequence of characters (seq<char>)"))
        d_8_str1a_ = rhs8_
        d_9_str1b_ = rhs9_
        d_10_str1_: _dafny.Seq
        d_11_str2_: _dafny.Seq
        rhs10_ = (d_8_str1a_) + (d_9_str1b_)
        rhs11_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "ring"))
        d_10_str1_ = rhs10_
        d_11_str2_ = rhs11_
        d_12_found_: bool
        d_13_i_: int
        out4_: bool
        out5_: int
        out4_, out5_ = default__.FindFirstOccurrence(d_10_str1_, d_11_str2_)
        d_12_found_ = out4_
        d_13_i_ = out5_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\nfound, i := FindFirstOccurrence(\""))).VerbatimString(False))
        _dafny.print((d_10_str1_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\", \""))).VerbatimString(False))
        _dafny.print((d_11_str2_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\") returns found == "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_12_found_))
        if d_12_found_:
            _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " and i == "))).VerbatimString(False))
            _dafny.print(_dafny.string_of(d_13_i_))
        d_10_str1_ = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "<= on sequences is the prefix relation"))
        out6_: bool
        out7_: int
        out6_, out7_ = default__.FindFirstOccurrence(d_10_str1_, d_11_str2_)
        d_12_found_ = out6_
        d_13_i_ = out7_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\nfound, i := FindFirstOccurrence(\""))).VerbatimString(False))
        _dafny.print((d_10_str1_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\", \""))).VerbatimString(False))
        _dafny.print((d_11_str2_).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\") returns found == "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_12_found_))
        if d_12_found_:
            _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " and i == "))).VerbatimString(False))
            _dafny.print(_dafny.string_of(d_13_i_))

