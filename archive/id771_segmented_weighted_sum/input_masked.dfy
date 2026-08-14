function SegmentValue(values: array<int>, indices: array<nat>, weights: array<int>,
                      start: int, stop: int): int
  reads values, indices, weights
  requires values.Length >= start >= 0
  requires stop <= values.Length
  requires values.Length == indices.Length
  requires forall i :: 0 <= i < indices.Length ==> indices[i] < weights.Length
  decreases stop - start
{
  if stop <= start then
    0
  else
    SegmentValue(values, indices, weights, start + 1, stop) +
      values[start] * weights[indices[start]]
}

method BuildResult(values: array<int>, indices: array<nat>,
                   boundaries: array<nat>, weights: array<int>)
  returns (result: array<int>)
  requires indices.Length >= 1
  requires indices.Length == values.Length
  requires forall i, j ::
    0 <= i < j < boundaries.Length ==> boundaries[i] <= boundaries[j]
  requires forall i :: 0 <= i < indices.Length ==> indices[i] < weights.Length
  requires forall i ::
    0 <= i < boundaries.Length ==> boundaries[i] <= values.Length
  requires boundaries.Length >= 1
  ensures result.Length + 1 == boundaries.Length
  ensures forall i ::
    0 <= i < result.Length ==>
      result[i] == SegmentValue(values, indices, weights,
                                boundaries[i], boundaries[i + 1])
{
  // Target body omitted for generation.
}
