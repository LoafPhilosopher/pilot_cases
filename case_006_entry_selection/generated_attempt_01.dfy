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
    var remaining := table.Keys;
    selected :| selected in table;
    while |remaining| > 0
      invariant selected in table
      invariant remaining <= table.Keys
      invariant forall key :: key in table.Keys && key !in remaining ==>
        table[selected].1 <= table[key].1
      decreases |remaining|
    {
      var key :| key in remaining;
      if table[key].1 < table[selected].1 {
        forall k | k in table.Keys && k !in remaining
          ensures table[key].1 <= table[k].1
        {
          assert table[selected].1 <= table[k].1;
        }
        selected := key;
      } else {
        assert table[selected].1 <= table[key].1;
      }

      assert table[selected].1 <= table[key].1;
      assert forall k :: k in table.Keys && k !in remaining ==>
        table[selected].1 <= table[k].1;

      forall k | k in table.Keys && k !in (remaining - {key})
        ensures table[selected].1 <= table[k].1
      {
        if k != key {
          assert k !in remaining;
          assert table[selected].1 <= table[k].1;
        }
      }

      remaining := remaining - {key};
    }

    assert remaining == {};
    forall item | item in table.Items
      ensures table[selected].1 <= table[item.0].1
    {
      assert item.0 in table.Keys;
      assert item.0 !in remaining;
    }
  }
}
