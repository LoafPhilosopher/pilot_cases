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
    // Target body omitted for generation.
  }
}
