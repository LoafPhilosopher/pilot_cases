include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy"
include "generated_attempt_01.dfy"

// The two recursively defined counting functions differ only by names.
lemma FrequenciesAgree<T>(
    values: seq<T>, start: int, stop: int, item: T)
  requires 0 <= start <= stop <= |values|
  ensures Count(values, start, stop, item) ==
          SegmentFrequency(values, start, stop, item)
  decreases stop - start
{
  if start != stop {
    FrequenciesAgree(values, start, stop - 1, item);
  }
}

// On the promised branch both public contracts force the raw result to be the
// designated strict-majority value.  This is an unbounded relational proof.
method PromisedBranchAgree<Choice(==)>(
    values: seq<Choice>, designated: Choice)
    returns (reference: Choice, generated: Choice)
  requires |values| != 0
  requires 2 * SegmentFrequency(
    values, 0, |values|, designated) > |values|
  ensures reference == generated == designated
{
  FrequenciesAgree(values, 0, |values|, designated);
  reference := SearchForWinner(values, true, designated);
  generated := SelectCandidate(values, true, designated);
}

// Executable concrete witness for the under-specified promised=false branch.
// Verification establishes that both calls meet their contracts.  Running the
// exact included bodies establishes the displayed raw outputs; this method
// intentionally has no postcondition that would overstate that runtime fact as
// a modular Dafny proof.
method Main()
{
  var values: seq<int> := [0, 1, 2];
  var generated := SelectCandidate(values, false, 0);
  var reference := SearchForWinner(values, false, 0);
  print "input:     ", values, "\n";
  print "generated: ", generated, "\n";
  print "reference: ", reference, "\n";
}
