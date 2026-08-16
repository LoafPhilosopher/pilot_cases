# Recorded generation prompt

The following prompt is supplied to one isolated Coding Agent. Network and Web
interfaces must not be used. The Agent must also make no tool, filesystem, or
other-agent calls. The hidden reference implementation is not included in its
context.

## System/task instruction

You are the isolated Coding Agent for one experimental run. Do not browse or
search the Web, do not use any network interface, do not call any tool, do not
inspect the filesystem, do not ask another agent, and do not access any
reference implementation or external context. Work only from the Dafny source
below.

Return only one complete Dafny source file, with no Markdown fences or prose.
Target Dafny 4.3.0. Preserve every supplied declaration, field, method
signature, precondition, postcondition, modifies, reads, and decreases clause,
and retained predicate/function definition exactly. Complete the omitted target
method body. You may add proof annotations or helper declarations if needed.
Do not use `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, `decreases *`, or any other verification/trust bypass. Do not add
printing or other externally observable side effects.

## Program supplied to the agent

```dafny
function SegmentFrequency<T(==)>(values: seq<T>, start: int, stop: int, item: T): int
  requires 0 <= start <= stop <= |values|
{
  if start == stop then 0 else
    SegmentFrequency(values, start, stop - 1, item) +
      (if values[stop - 1] == item then 1 else 0)
}

method SelectCandidate<Choice(==)>(
    values: seq<Choice>, ghost promised: bool, ghost designated: Choice)
    returns (candidate: Choice)
  requires |values| != 0
  requires promised ==>
    2 * SegmentFrequency(values, 0, |values|, designated) > |values|
  ensures promised ==> candidate == designated
{
  // Target body omitted for generation.
}

lemma FrequencySplit<T>(
    values: seq<T>, start: int, middle: int, stop: int, item: T)
  requires 0 <= start <= middle <= stop <= |values|
  ensures SegmentFrequency(values, start, middle, item) +
    SegmentFrequency(values, middle, stop, item) ==
    SegmentFrequency(values, start, stop, item)
{
}

lemma DistinctFrequencyBound<T>(
    values: seq<T>, start: int, stop: int, first: T, second: T)
  requires 0 <= start <= stop <= |values|
  ensures first != second ==>
    SegmentFrequency(values, start, stop, first) +
      SegmentFrequency(values, start, stop, second) <= stop - start
{
}
```
