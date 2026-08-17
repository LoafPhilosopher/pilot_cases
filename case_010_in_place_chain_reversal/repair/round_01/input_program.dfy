class Link<T> {
  ghost var View: seq<T>
  ghost var Owned: set<Link<T>>

  var value: T
  var successor: Link?<T>

  ghost predicate Consistent()
    reads this, Owned
  {
    this in Owned &&
    (successor == null ==> View == [value]) &&
    (successor != null ==>
      successor in Owned && successor.Owned <= Owned &&
      this !in successor.Owned &&
      View == [value] + successor.View &&
      successor.Consistent())
  }

  constructor Create(initial: T)
    ensures Consistent() && fresh(Owned)
    ensures View == [initial]
  {
    value, successor := initial, null;
    View, Owned := [initial], {this};
  }

  method ReverseValues() returns (values: seq<T>)
    requires Consistent()
    ensures |values| == |View|
    ensures forall i ::
      0 <= i < |values| ==>
        values[i] == View[|View| - 1 - i]
    decreases |View|
  {
    if successor == null {
      assert View == [value];
      values := [value];
    } else {
      var next := successor;
      assert next.Consistent();
      assert View == [value] + next.View;
      assert |next.View| < |View|;

      var rest := next.ReverseValues();
      values := rest + [value];

      forall i | 0 <= i < |values|
        ensures values[i] == View[|View| - 1 - i]
      {
        if i < |rest| {
          assert |rest| == |next.View|;
          assert 0 <= next.View.Length - 1 - i < next.View.Length;
          assert rest[i] == next.View[next.View.Length - 1 - i];
          assert values[i] == rest[i];
          assert View.Length == 1 + next.View.Length;
          assert View.Length - 1 - i ==
            1 + (next.View.Length - 1 - i);
          assert View[View.Length - 1 - i] ==
            next.View[next.View.Length - 1 - i];
        } else {
          assert values.Length == rest.Length + 1;
          assert i == rest.Length;
          assert rest.Length == next.View.Length;
          assert View.Length == 1 + next.View.Length;
          assert View.Length - 1 - i == 0;
          assert values[i] == value;
          assert View[0] == value;
        }
      }
    }
  }

  method SetValues(values: seq<T>)
    requires Consistent()
    requires |values| == |View|
    modifies Owned
    ensures Consistent()
    ensures View == values
    ensures Owned == old(Owned)
    decreases |View|
  {
    ghost var savedOwned := Owned;
    assert this in Owned;

    if successor == null {
      assert View == [value];
      assert |values| == 1;
      assert 0 < |values|;
      assert values == [values[0]];

      value := values[0];
      View := values;

      assert View == [value];
    } else {
      var next := successor;
      ghost var savedNextOwned := next.Owned;

      assert next in Owned;
      assert savedNextOwned <= Owned;
      assert this !in savedNextOwned;
      assert next.Consistent();
      assert View == [value] + next.View;
      assert |next.View| < |View|;
      assert |values| == 1 + |next.View|;
      assert 0 < |values|;
      assert |values[1..]| == |next.View|;

      next.SetValues(values[1..]);

      assert next.Owned == savedNextOwned;
      assert Owned == savedOwned;
      assert successor == next;
      assert next.View == values[1..];
      assert next in Owned;
      assert next.Owned <= Owned;
      assert this !in next.Owned;
      assert next.Consistent();
      assert values == [values[0]] + values[1..];

      value := values[0];
      View := values;

      assert View == [value] + next.View;
    }

    assert Owned == savedOwned;
  }

  method Rewire() returns (result: Link<T>)
    requires Consistent()
    modifies Owned
    ensures result.Consistent() && result.Owned <= old(Owned)
    ensures |result.View| == |old(View)|
    ensures forall i ::
      0 <= i < |result.View| ==>
        result.View[i] == old(View)[|old(View)| - 1 - i]
  {
    ghost var originalView := View;
    ghost var originalOwned := Owned;

    var reversed := ReverseValues();
    assert |reversed| == |originalView|;
    assert forall i ::
      0 <= i < |reversed| ==>
        reversed[i] ==
          originalView[|originalView| - 1 - i];

    SetValues(reversed);
    result := this;

    assert result.Owned == originalOwned;
    assert result.View == reversed;
    assert |result.View| == |originalView|;
    assert forall i ::
      0 <= i < |result.View| ==>
        result.View[i] ==
          originalView[|originalView| - 1 - i];
  }
}
