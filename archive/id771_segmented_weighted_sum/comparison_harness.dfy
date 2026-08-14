include "../../third_party/DafnyBench/DafnyBench/dataset/ground_truth/veri-sparse_tmp_tmp15fywna6_dafny_spmv.dfy"
include "generated_attempt_01.dfy"

// The masked/generated function and ID771's function compute the same
// mathematical segment sum.  This lemma bridges their intentional renaming.
lemma SegmentSpecificationsAgree(values: array<int>, indices: array<nat>,
                                  weights: array<int>, start: int, stop: int)
  requires values.Length >= start >= 0
  requires stop <= values.Length
  requires values.Length == indices.Length
  requires forall i ::
    0 <= i < indices.Length ==> indices[i] < weights.Length
  ensures SegmentValue(values, indices, weights, start, stop) ==
          sum(values, indices, weights, start, stop)
  decreases stop - start
{
  if stop <= start {
  } else {
    assert start < stop <= values.Length;
    SegmentSpecificationsAgree(values, indices, weights, start + 1, stop);
  }
}

// Relational theorem for the two concrete methods.  Calls are checked
// modularly against their public contracts; no implementation loop invariant
// is used here.
method ImplementationsHaveSameContent(values: array<int>, indices: array<nat>,
                                      boundaries: array<nat>, weights: array<int>)
  returns (generated: array<int>, reference: array<int>)
  requires indices.Length >= 1
  requires indices.Length == values.Length
  requires forall i, j ::
    0 <= i < j < boundaries.Length ==> boundaries[i] <= boundaries[j]
  requires forall i ::
    0 <= i < indices.Length ==> indices[i] < weights.Length
  requires forall i ::
    0 <= i < boundaries.Length ==> boundaries[i] <= values.Length
  requires boundaries.Length >= 1
  ensures generated.Length == reference.Length
  ensures forall i ::
    0 <= i < generated.Length ==> generated[i] == reference[i]
  ensures generated[..] == reference[..]
{
  generated := BuildResult(values, indices, boundaries, weights);
  reference := SpMV(values, indices, boundaries, weights);

  assert generated.Length == reference.Length;
  forall i | 0 <= i < generated.Length
    ensures generated[i] == reference[i]
  {
    assert 0 <= i < reference.Length;
    SegmentSpecificationsAgree(values, indices, weights,
                               boundaries[i], boundaries[i + 1]);
  }

  assert |generated[..]| == |reference[..]|;
  forall i | 0 <= i < |generated[..]|
    ensures generated[..][i] == reference[..][i]
  {
    assert generated[..][i] == generated[i];
    assert reference[..][i] == reference[i];
  }
  assert generated[..] == reference[..];
}

// A constructive witness that the shared result contract alone permits
// aliasing.  It has all of BuildResult/SpMV's shared obligations, but returns
// values itself whenever values already has the required shape and content.
// This is not either implementation under comparison.
method ContractCompatibleAliasingBuild(values: array<int>, indices: array<nat>,
                                       boundaries: array<nat>, weights: array<int>)
  returns (result: array<int>)
  requires indices.Length >= 1
  requires indices.Length == values.Length
  requires forall i, j ::
    0 <= i < j < boundaries.Length ==> boundaries[i] <= boundaries[j]
  requires forall i ::
    0 <= i < indices.Length ==> indices[i] < weights.Length
  requires forall i ::
    0 <= i < boundaries.Length ==> boundaries[i] <= values.Length
  requires boundaries.Length >= 1
  ensures result.Length + 1 == boundaries.Length
  ensures forall i ::
    0 <= i < result.Length ==>
      result[i] == SegmentValue(values, indices, weights,
                                boundaries[i], boundaries[i + 1])
  ensures forall i ::
    0 <= i < result.Length ==>
      result[i] == sum(values, indices, weights,
                       boundaries[i], boundaries[i + 1])
  ensures values.Length + 1 == boundaries.Length &&
          (forall i ::
             0 <= i < values.Length ==>
               values[i] == SegmentValue(values, indices, weights,
                                         boundaries[i], boundaries[i + 1]))
          ==> result == values
{
  if values.Length + 1 == boundaries.Length &&
     (forall i ::
        0 <= i < values.Length ==>
          values[i] == SegmentValue(values, indices, weights,
                                    boundaries[i], boundaries[i + 1])) {
    result := values;
  } else {
    result := BuildResult(values, indices, boundaries, weights);
  }

  forall i | 0 <= i < result.Length
    ensures result[i] == sum(values, indices, weights,
                             boundaries[i], boundaries[i + 1])
  {
    assert i + 1 < boundaries.Length;
    SegmentSpecificationsAgree(values, indices, weights,
                               boundaries[i], boundaries[i + 1]);
  }
}

// A concrete verified execution of the contract-compatible witness reaches
// its aliasing branch.  It establishes satisfiability of result == input under
// the shared shape/content postconditions; it says nothing about the bodies of
// BuildResult or SpMV.
method ContractAliasWitness()
  returns (input: array<int>, result: array<int>)
  ensures result == input
{
  input := new int[1];
  var indices := new nat[1];
  var boundaries := new nat[2];
  var weights := new int[1];

  input[0] := 0;
  indices[0] := 0;
  boundaries[0] := 0;
  boundaries[1] := 1;
  weights[0] := 7;

  assert forall i, j ::
    0 <= i < j < boundaries.Length ==> boundaries[i] <= boundaries[j];
  assert forall i ::
    0 <= i < indices.Length ==> indices[i] < weights.Length;
  assert forall i ::
    0 <= i < boundaries.Length ==> boundaries[i] <= input.Length;
  assert SegmentValue(input, indices, weights, 0, 1) == 0;
  assert forall i ::
    0 <= i < input.Length ==>
      input[i] == SegmentValue(input, indices, weights,
                               boundaries[i], boundaries[i + 1]);

  result := ContractCompatibleAliasingBuild(input, indices, boundaries, weights);
  assert input.Length + 1 == boundaries.Length;
  assert forall i ::
    0 <= i < input.Length ==>
      input[i] == SegmentValue(input, indices, weights,
                               boundaries[i], boundaries[i + 1]);
  assert result == input;
}
