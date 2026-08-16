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
  candidate := values[0];
  var i := 0;

  assert 0 < |values|;
  if promised {
    assert SegmentFrequency(values, 0, |values|, designated) > 0;
  }

  while i < |values|
    invariant 0 <= i <= |values|
    invariant promised ==> candidate == designated ||
      SegmentFrequency(values, i, |values|, designated) > 0
    decreases |values| - i
  {
    var majority :=
      2 * SegmentFrequency(values, 0, |values|, values[i]) > |values|;
    ghost var wasDesignated := candidate == designated;

    if promised {
      if wasDesignated {
        if majority {
          DistinctFrequencyBound(
            values, 0, |values|, designated, values[i]);
          if values[i] != designated {
            assert SegmentFrequency(values, 0, |values|, designated) +
              SegmentFrequency(values, 0, |values|, values[i]) <=
              |values|;
            assert SegmentFrequency(values, 0, |values|, designated) +
              SegmentFrequency(values, 0, |values|, values[i]) >
              |values|;
            assert false;
          }
          assert values[i] == designated;
        }
      } else {
        assert SegmentFrequency(
          values, i, |values|, designated) > 0;
        if values[i] == designated {
          assert majority;
        } else {
          FrequencySplit(
            values, i, i + 1, |values|, designated);
          assert SegmentFrequency(
            values, i, i, designated) == 0;
          assert SegmentFrequency(
            values, i, i + 1, designated) ==
            SegmentFrequency(values, i, i, designated) +
              (if values[i] == designated then 1 else 0);
          assert SegmentFrequency(
            values, i, i + 1, designated) == 0;
          assert SegmentFrequency(
            values, i + 1, |values|, designated) > 0;
        }
      }
    }

    if majority {
      candidate := values[i];
    }

    if promised {
      if wasDesignated {
        if majority {
          assert values[i] == designated;
        }
        assert candidate == designated;
      } else if values[i] == designated {
        assert majority;
        assert candidate == designated;
      } else {
        assert SegmentFrequency(
          values, i + 1, |values|, designated) > 0;
      }
      assert candidate == designated ||
        SegmentFrequency(
          values, i + 1, |values|, designated) > 0;
    }

    i := i + 1;
  }

  assert i == |values|;
  assert SegmentFrequency(
    values, |values|, |values|, designated) == 0;
  if promised {
    assert candidate == designated;
  }
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
