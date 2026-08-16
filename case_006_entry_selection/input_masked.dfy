class RecordSpace {
  var capacity: int
  var table: map<int, (int, int)>

  predicate Coherent()
    reads this
  {
    capacity > 0 &&
    0 <= |table| <= capacity &&
    (|table| > 0 ==> (forall key :: key in table ==> table[key].1 >= 1)) &&
    (|table| > 0 ==> (forall key :: key in table ==> table[key].0 >= 0))
  }

  method ChooseEntry() returns (selected: int)
    requires Coherent()
    requires |table| > 0
    ensures Coherent()
    ensures selected in table
    ensures forall item :: item in table.Items ==> table[selected].1 <= table[item.0].1
  {
    // Target body omitted for generation.
  }
}
