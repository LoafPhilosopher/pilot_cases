# Exact generation prompt

The following prompt was given to one isolated Coding Agent. It was instructed
not to use Web, tools, the filesystem, or a hidden reference; the generation
log records zero such calls before the code response, and the reference was not
included in its context. This case is now retained only as a superseded audit
record.

> You are the isolated Coding Agent for one experimental run. You must not call
> any tool, browse the web, inspect the filesystem, ask another agent, or access
> any reference implementation. Work only from the source below. Complete the
> omitted target method body in Dafny 4.3.0.
> Return one complete Dafny source file that verifies. Preserve all supplied
> declarations, signatures, preconditions, and postconditions exactly. You may
> add proof annotations or helper declarations, but do not use `assume`,
> `{:verify false}`, `{:axiom}`, `{:extern}`, `decreases *`, or any other
> verification bypass. Do not add printing or other externally observable side
> effects. Output Dafny code only, without Markdown fences.

```dafny
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
```
