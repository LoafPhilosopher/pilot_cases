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

method ChooseWitnesses(values: array<int>) returns (x: int, y: int)
  requires 4 <= values.Length
  requires exists x, y ::
    x != y && HasWitness(values, x) && HasWitness(values, y)
  requires forall i ::
    0 <= i < values.Length ==> 0 <= values[i] < values.Length - 2
  ensures x != y && HasWitness(values, x) && HasWitness(values, y)
{
  // Target body omitted for generation.
}
