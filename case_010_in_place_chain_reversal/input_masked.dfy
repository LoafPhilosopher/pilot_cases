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

  method Rewire() returns (result: Link<T>)
    requires Consistent()
    modifies Owned
    ensures result.Consistent() && result.Owned <= old(Owned)
    ensures |result.View| == |old(View)|
    ensures forall i ::
      0 <= i < |result.View| ==>
        result.View[i] == old(View)[|old(View)| - 1 - i]
  {
    // Target body omitted for generation.
  }
}
