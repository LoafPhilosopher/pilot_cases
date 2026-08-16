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
