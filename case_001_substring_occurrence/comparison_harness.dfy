include "../../DafnyBench/DafnyBench/dataset/ground_truth/AssertivePrograming_tmp_tmpwf43uz0e_Find_Substring.dfy"
include "generated_attempt_01.dfy"

method {:main} Counterexample() {
  var source := "a";
  var pattern := "b";

  var originalOk, originalIndex := FindFirstOccurrence(source, pattern);
  var generatedOk, generatedIndex := ComputeWitness(source, pattern);

  print "input: source=\"", source, "\", pattern=\"", pattern, "\"\n";
  print "ground truth: ok=", originalOk, ", index=", originalIndex, "\n";
  print "generated:    ok=", generatedOk, ", index=", generatedIndex, "\n";
}
