class Buffer<T(0)> {
  var first: Cell<T>
  var last: Cell<T>

  ghost var model: seq<T>
  ghost var owned: set<object>
  ghost var chain: set<Cell<T>>

  ghost predicate Consistent()
    reads this, owned
  {
    this in owned && chain <= owned &&
    first in chain &&
    last in chain &&
    last.successor == null &&
    (forall node ::
      node in chain ==>
        node.owned <= owned && this !in node.owned &&
        node.Consistent() &&
        (node.successor == null ==> node == last)) &&
    (forall node ::
      node in chain ==>
        node.successor != null ==> node.successor in chain) &&
    model == first.suffix
  }

  constructor Create()
    ensures Consistent() && fresh(owned - {this})
    ensures |model| == 0
  {
    var cell: Cell<T> := new Cell<T>.Create();
    first := cell;
    last := cell;
    model := cell.suffix;
    owned := {this} + cell.owned;
    chain := {cell};
  }

  method UpdateStructure(item: T)
    requires Consistent()
    modifies owned
    ensures Consistent() && fresh(owned - old(owned))
    ensures model == old(model) + [item]
  {
    // Target body omitted for generation.
  }
}

class Cell<T(0)> {
  var value: T
  var successor: Cell?<T>

  ghost var suffix: seq<T>
  ghost var owned: set<object>

  ghost predicate Consistent()
    reads this, owned
  {
    this in owned &&
    (successor != null ==>
      successor in owned && successor.owned <= owned) &&
    (successor == null ==> suffix == []) &&
    (successor != null ==> suffix == [successor.value] + successor.suffix)
  }

  constructor Create()
    ensures Consistent() && fresh(owned - {this})
    ensures successor == null
  {
    successor := null;
    suffix := [];
    owned := {this};
  }
}
