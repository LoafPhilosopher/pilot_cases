type Span = span: (int, int) | span.0 <= span.1 witness (0, 0)

ghost function SpanSize(span: Span): int
{
  span.1 - span.0
}

ghost predicate IsAdmissible(text: string, span: Span)
{
  0 <= span.0 <= span.1 <= |text| &&
  (forall i, j | span.0 <= i < j < span.1 :: text[i] != text[j])
}

function RangeDistinct(text: string, lo: int, hi: int): bool
  requires 0 <= lo <= hi <= |text|
{
  forall i: int, j: int |
    lo <= i < hi && lo <= j < hi && i < j
  :: text[i] != text[j]
}

method SelectDistinctWindow(text: string) returns (size: int, ghost chosen: Span)
  ensures IsAdmissible(text, chosen) && SpanSize(chosen) == size
  ensures forall candidate | IsAdmissible(text, candidate) :: SpanSize(candidate) <= size
{
  var bestStart: int := 0;
  size := 0;
  var left: int := 0;

  assert RangeDistinct(text, 0, 0);

  while left <= |text|
    invariant 0 <= left <= |text| + 1
    invariant 0 <= bestStart <= bestStart + size <= |text|
    invariant RangeDistinct(text, bestStart, bestStart + size)
    invariant forall lo: int, hi: int |
      0 <= lo < left &&
      lo <= hi <= |text| &&
      RangeDistinct(text, lo, hi)
    :: hi - lo <= size
    decreases |text| + 1 - left
  {
    var right: int := left;

    while right <= |text|
      invariant left <= right <= |text| + 1
      invariant 0 <= bestStart <= bestStart + size <= |text|
      invariant RangeDistinct(text, bestStart, bestStart + size)
      invariant forall lo: int, hi: int |
        0 <= lo < left &&
        lo <= hi <= |text| &&
        RangeDistinct(text, lo, hi)
      :: hi - lo <= size
      invariant forall hi: int |
        left <= hi < right &&
        RangeDistinct(text, left, hi)
      :: hi - left <= size
      decreases |text| + 1 - right
    {
      ghost var priorSize := size;

      assert forall lo: int, hi: int |
        0 <= lo < left &&
        lo <= hi <= |text| &&
        RangeDistinct(text, lo, hi)
      :: hi - lo <= priorSize;

      assert forall hi: int |
        left <= hi < right &&
        RangeDistinct(text, left, hi)
      :: hi - left <= priorSize;

      if RangeDistinct(text, left, right) && right - left > size {
        bestStart := left;
        size := right - left;
      }

      assert priorSize <= size;
      assert !RangeDistinct(text, left, right) || right - left <= size;

      forall lo: int, hi: int |
        0 <= lo < left &&
        lo <= hi <= |text| &&
        RangeDistinct(text, lo, hi)
        ensures hi - lo <= size
      {
        assert hi - lo <= priorSize;
      }

      var nextRight: int := right + 1;

      forall hi: int |
        left <= hi < nextRight &&
        RangeDistinct(text, left, hi)
        ensures hi - left <= size
      {
        if hi < right {
          assert hi - left <= priorSize;
        } else {
          assert hi == right;
        }
      }

      right := nextRight;
    }

    assert right == |text| + 1;

    forall hi: int |
      left <= hi <= |text| &&
      RangeDistinct(text, left, hi)
      ensures hi - left <= size
    {
      assert hi < right;
    }

    var nextLeft: int := left + 1;

    forall lo: int, hi: int |
      0 <= lo < nextLeft &&
      lo <= hi <= |text| &&
      RangeDistinct(text, lo, hi)
      ensures hi - lo <= size
    {
      if lo < left {
        assert hi - lo <= size;
      } else {
        assert lo == left;
        assert hi - left <= size;
      }
    }

    left := nextLeft;
  }

  assert left == |text| + 1;

  chosen := (bestStart, bestStart + size);

  assert 0 <= chosen.0 <= chosen.1 <= |text|;
  assert RangeDistinct(text, chosen.0, chosen.1);
  assert IsAdmissible(text, chosen);
  assert SpanSize(chosen) == size;

  forall candidate: Span | IsAdmissible(text, candidate)
    ensures SpanSize(candidate) <= size
  {
    assert 0 <= candidate.0 <= candidate.1 <= |text|;
    assert candidate.0 < left;
    assert RangeDistinct(text, candidate.0, candidate.1);
    assert candidate.1 - candidate.0 <= size;
  }
}
