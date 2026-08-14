ghost predicate HasWitnessBefore(values: array<int>, end: int, value: int)
  requires 0 <= end <= values.Length
  reads values
{
  exists i, j :: 0 <= i < j < end && values[i] == values[j] == value
}

ghost predicate HasWitness(values: array<int>, value: int)
  reads values
{
  HasWitnessBefore(values, values.Length, value)
}

lemma PairIsWitness(values: array<int>, i: int, j: int, value: int)
  requires 0 <= i < j < values.Length
  requires values[i] == values[j] == value
  ensures HasWitness(values, value)
{
  assert exists p, q ::
    0 <= p < q < values.Length && values[p] == values[q] == value;
  assert HasWitnessBefore(values, values.Length, value);
}

lemma StartNoDuplicate(values: array<int>, row: int)
  requires 0 <= row < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length && p < row ==> values[p] != values[q]
  ensures forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < row + 1))
    ==> values[p] != values[q]
{
  forall p, q |
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < row + 1))
    ensures values[p] != values[q]
  {
    if p < row {
      assert values[p] != values[q];
    } else {
      assert p == row;
      assert row < q < row + 1;
      assert false;
    }
  }
}

lemma ExtendNoDuplicate(
  values: array<int>, row: int, next: int
)
  requires 0 <= row < values.Length
  requires row + 1 <= next < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next))
    ==> values[p] != values[q]
  requires values[row] != values[next]
  ensures forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next + 1))
    ==> values[p] != values[q]
{
  forall p, q |
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next + 1))
    ensures values[p] != values[q]
  {
    if p < row || (p == row && q < next) {
      assert values[p] != values[q];
    } else {
      assert p == row;
      assert next <= q < next + 1;
      assert q == next;
      assert values[p] != values[q];
    }
  }
}

lemma FinishNoDuplicate(values: array<int>, row: int)
  requires 0 <= row < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < values.Length))
    ==> values[p] != values[q]
  ensures forall p, q ::
    0 <= p < q < values.Length && p < row + 1
    ==> values[p] != values[q]
{
  forall p, q |
    0 <= p < q < values.Length && p < row + 1
    ensures values[p] != values[q]
  {
    if p < row {
      assert values[p] != values[q];
    } else {
      assert p == row;
      assert values[p] != values[q];
    }
  }
}

lemma StartOnlyValue(values: array<int>, row: int, value: int)
  requires 0 <= row < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length && p < row &&
    values[p] == values[q] ==> values[p] == value
  ensures forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < row + 1)) &&
    values[p] == values[q] ==> values[p] == value
{
  forall p, q |
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < row + 1))
    ensures values[p] == values[q] ==> values[p] == value
  {
    if values[p] == values[q] {
      if p < row {
        assert values[p] == value;
      } else {
        assert p == row;
        assert row < q < row + 1;
        assert false;
      }
    }
  }
}

lemma ExtendOnlyValue(
  values: array<int>, row: int, next: int, value: int
)
  requires 0 <= row < values.Length
  requires row + 1 <= next < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next)) &&
    values[p] == values[q] ==> values[p] == value
  requires values[row] == values[next] ==> values[row] == value
  ensures forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next + 1)) &&
    values[p] == values[q] ==> values[p] == value
{
  forall p, q |
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < next + 1))
    ensures values[p] == values[q] ==> values[p] == value
  {
    if values[p] == values[q] {
      if p < row || (p == row && q < next) {
        assert values[p] == value;
      } else {
        assert p == row;
        assert next <= q < next + 1;
        assert q == next;
        assert values[row] == values[next];
        assert values[p] == value;
      }
    }
  }
}

lemma FinishOnlyValue(values: array<int>, row: int, value: int)
  requires 0 <= row < values.Length
  requires forall p, q ::
    0 <= p < q < values.Length &&
    (p < row || (p == row && q < values.Length)) &&
    values[p] == values[q] ==> values[p] == value
  ensures forall p, q ::
    0 <= p < q < values.Length && p < row + 1 &&
    values[p] == values[q] ==> values[p] == value
{
  forall p, q |
    0 <= p < q < values.Length && p < row + 1
    ensures values[p] == values[q] ==> values[p] == value
  {
    if values[p] == values[q] {
      if p < row {
        assert values[p] == value;
      } else {
        assert p == row;
        assert values[p] == value;
      }
    }
  }
}

method ChooseWitnesses(values: array<int>) returns (x: int, y: int)
  requires 4 <= values.Length
  requires exists x, y ::
    x != y && HasWitness(values, x) && HasWitness(values, y)
  requires forall i ::
    0 <= i < values.Length ==> 0 <= values[i] < values.Length - 2
  ensures x != y && HasWitness(values, x) && HasWitness(values, y)
{
  ghost var witnessX, witnessY :|
    witnessX != witnessY &&
    HasWitness(values, witnessX) &&
    HasWitness(values, witnessY);

  assert HasWitnessBefore(values, values.Length, witnessX);
  assert exists p, q ::
    0 <= p < q < values.Length &&
    values[p] == values[q] == witnessX;
  ghost var wxi, wxj :|
    0 <= wxi < wxj < values.Length &&
    values[wxi] == values[wxj] == witnessX;

  assert HasWitnessBefore(values, values.Length, witnessY);
  assert exists p, q ::
    0 <= p < q < values.Length &&
    values[p] == values[q] == witnessY;
  ghost var wyi, wyj :|
    0 <= wyi < wyj < values.Length &&
    values[wyi] == values[wyj] == witnessY;

  x := 0;
  var foundX := false;
  var i := 0;

  while i < values.Length && !foundX
    invariant 0 <= i <= values.Length
    invariant foundX ==> HasWitness(values, x)
    invariant !foundX ==> (forall p, q ::
      0 <= p < q < values.Length && p < i
      ==> values[p] != values[q])
    decreases values.Length - i
  {
    var j := i + 1;
    StartNoDuplicate(values, i);

    while j < values.Length && !foundX
      invariant 0 <= i < values.Length
      invariant i + 1 <= j <= values.Length
      invariant foundX ==> HasWitness(values, x)
      invariant !foundX ==> (forall p, q ::
        0 <= p < q < values.Length &&
        (p < i || (p == i && q < j))
        ==> values[p] != values[q])
      decreases values.Length - j
    {
      if values[i] == values[j] {
        x := values[i];
        foundX := true;
        PairIsWitness(values, i, j, x);
      } else {
        ExtendNoDuplicate(values, i, j);
      }
      j := j + 1;
    }

    if !foundX {
      assert j == values.Length;
      FinishNoDuplicate(values, i);
    }
    i := i + 1;
  }

  if !foundX {
    assert i == values.Length;
    assert values[wxi] == values[wxj];
    assert values[wxi] != values[wxj];
    assert false;
  }

  assert foundX;
  assert HasWitness(values, x);

  y := 0;
  var foundY := false;
  i := 0;

  while i < values.Length && !foundY
    invariant 0 <= i <= values.Length
    invariant HasWitness(values, x)
    invariant foundY ==> (x != y && HasWitness(values, y))
    invariant !foundY ==> (forall p, q ::
      0 <= p < q < values.Length && p < i &&
      values[p] == values[q] ==> values[p] == x)
    decreases values.Length - i
  {
    var j := i + 1;
    StartOnlyValue(values, i, x);

    while j < values.Length && !foundY
      invariant 0 <= i < values.Length
      invariant i + 1 <= j <= values.Length
      invariant HasWitness(values, x)
      invariant foundY ==> (x != y && HasWitness(values, y))
      invariant !foundY ==> (forall p, q ::
        0 <= p < q < values.Length &&
        (p < i || (p == i && q < j)) &&
        values[p] == values[q] ==> values[p] == x)
      decreases values.Length - j
    {
      if values[i] == values[j] && values[i] != x {
        y := values[i];
        foundY := true;
        PairIsWitness(values, i, j, y);
      } else {
        assert values[i] == values[j] ==> values[i] == x;
        ExtendOnlyValue(values, i, j, x);
      }
      j := j + 1;
    }

    if !foundY {
      assert j == values.Length;
      FinishOnlyValue(values, i, x);
    }
    i := i + 1;
  }

  if !foundY {
    assert i == values.Length;

    assert values[wxi] == values[wxj];
    assert values[wxi] == x;
    assert values[wxi] == witnessX;
    assert witnessX == x;

    assert values[wyi] == values[wyj];
    assert values[wyi] == x;
    assert values[wyi] == witnessY;
    assert witnessY == x;

    assert witnessX == witnessY;
    assert false;
  }

  assert foundY;
  assert x != y && HasWitness(values, x) && HasWitness(values, y);
}
