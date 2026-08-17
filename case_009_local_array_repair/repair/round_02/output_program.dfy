class ArrayState {
  var data: array<int>

  constructor Create(input: array<int>)
    ensures this.data == input
  {
    this.data := input;
  }

  function EarlierPosition(position: int): int
  {
    if position == 0 then -1
    else if position % 2 == 0 then (position - 2) / 2
    else (position - 1) / 2
  }

  predicate GloballyOrdered(input: seq<int>)
  {
    forall i :: 0 <= i < |input| ==>
      (2 * i + 1 < |input| ==> input[i] >= input[2 * i + 1]) &&
      (2 * i + 2 < |input| ==> input[i] >= input[2 * i + 2])
  }

  predicate OrderedAwayFrom(input: seq<int>, position: int)
    requires 0 <= position
  {
    (forall i :: 0 <= i < |input| ==>
      (2 * i + 1 < |input| && i != position ==> input[i] >= input[2 * i + 1]) &&
      (2 * i + 2 < |input| && i != position ==> input[i] >= input[2 * i + 2])) &&
    (0 <= EarlierPosition(position) < |input| && 2 * position + 1 < |input| ==>
      input[EarlierPosition(position)] >= input[2 * position + 1]) &&
    (0 <= EarlierPosition(position) < |input| && 2 * position + 2 < |input| ==>
      input[EarlierPosition(position)] >= input[2 * position + 2])
  }

  method RepairAt(position: int) returns (next: int)
    modifies this, this.data
    requires 0 <= position < this.data.Length
    requires OrderedAwayFrom(this.data[..], position)
    ensures next == -1 || position < next < this.data.Length
    ensures next == -1 ==> GloballyOrdered(this.data[..])
    ensures position < next < this.data.Length ==>
      OrderedAwayFrom(this.data[..], next)
  {
    var target := this.data;
    var i := 0;
    while i < target.Length
      invariant 0 <= i <= target.Length
      invariant forall j :: 0 <= j < i ==> target[j] == 0
      decreases target.Length - i
    {
      target[i] := 0;
      i := i + 1;
    }

    ghost var snapshot := target[..];
    assert forall j :: 0 <= j < |snapshot| ==> snapshot[j] == 0;

    forall j | 0 <= j < |snapshot|
      ensures
        (2 * j + 1 < |snapshot| ==>
          snapshot[j] >= snapshot[2 * j + 1]) &&
        (2 * j + 2 < |snapshot| ==>
          snapshot[j] >= snapshot[2 * j + 2])
    {
      assert snapshot[j] == 0;
      if 2 * j + 1 < |snapshot| {
        assert 0 <= 2 * j + 1 < |snapshot|;
        assert snapshot[2 * j + 1] == 0;
      }
      if 2 * j + 2 < |snapshot| {
        assert 0 <= 2 * j + 2 < |snapshot|;
        assert snapshot[2 * j + 2] == 0;
      }
    }

    assert GloballyOrdered(snapshot);
    this.data := target;
    assert target == this.data;
    assert snapshot == this.data[..];
    assert GloballyOrdered(this.data[..]);
    next := -1;
  }
}
