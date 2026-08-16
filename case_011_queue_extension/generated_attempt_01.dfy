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
    var oldFirst := first;
    var oldLast := last;
    ghost var oldChain := chain;
    ghost var oldOwned := owned;
    ghost var oldModel := model;
    ghost var oldSuffixes :=
      map node: Cell<T> | node in oldChain :: node.suffix;
    ghost var oldNodeOwneds :=
      map node: Cell<T> | node in oldChain :: node.owned;
    ghost var oldSuccessors :=
      map node: Cell<T> | node in oldChain :: node.successor;
    ghost var oldValues :=
      map node: Cell<T> | node in oldChain :: node.value;

    assert oldFirst == old(first);
    assert oldLast == old(last);
    assert oldChain == old(chain);
    assert oldOwned == old(owned);
    assert oldModel == old(model);

    assert this in owned;
    assert chain <= owned;
    assert first in chain;
    assert last in chain;
    assert last.successor == null;
    assert model == first.suffix;
    assert forall node ::
      node in chain ==>
        node.owned <= owned && this !in node.owned &&
        node.Consistent() &&
        (node.successor == null ==> node == last);
    assert forall node ::
      node in chain ==>
        (node.successor != null ==> node.successor in chain);

    assert this in oldOwned;
    assert oldChain <= oldOwned;
    assert oldFirst in oldChain;
    assert oldLast in oldChain;
    assert oldLast.successor == null;
    assert oldSuffixes[oldFirst] == oldFirst.suffix;
    assert oldModel == oldSuffixes[oldFirst];

    forall node | node in oldChain
      ensures oldNodeOwneds[node] <= oldOwned
      ensures this !in oldNodeOwneds[node]
      ensures node in oldNodeOwneds[node]
      ensures oldSuccessors[node] == null ==>
        node == oldLast && oldSuffixes[node] == []
      ensures oldSuccessors[node] != null ==>
        oldSuccessors[node] in oldChain &&
        oldSuccessors[node] in oldNodeOwneds[node] &&
        oldNodeOwneds[oldSuccessors[node]] <= oldNodeOwneds[node] &&
        oldSuffixes[node] ==
          [oldValues[oldSuccessors[node]]] +
          oldSuffixes[oldSuccessors[node]]
    {
      assert node in chain;
      assert oldNodeOwneds[node] == node.owned;
      assert oldSuccessors[node] == node.successor;
      assert oldSuffixes[node] == node.suffix;
      assert oldValues[node] == node.value;

      assert node.owned <= owned;
      assert this !in node.owned;
      assert node.Consistent();
      assert node in node.owned;

      if oldSuccessors[node] == null {
        assert node.successor == null;
        assert node == last;
        assert node == oldLast;
        assert node.suffix == [];
      } else {
        assert node.successor != null;
        assert node.successor in chain;
        assert node.successor in oldChain;
        assert node.successor in node.owned;
        assert node.successor.owned <= node.owned;
        assert node.suffix ==
          [node.successor.value] + node.successor.suffix;
        assert oldNodeOwneds[node.successor] ==
          node.successor.owned;
        assert oldSuffixes[node.successor] ==
          node.successor.suffix;
        assert oldValues[node.successor] ==
          node.successor.value;
      }
    }

    assert oldSuccessors[oldLast] == null;
    assert oldSuffixes[oldLast] == [];

    var cell: Cell<T> := new Cell<T>.Create();
    cell.value := item;
    ghost var cellOwned := cell.owned;

    assert cell.successor == null;
    assert cell.suffix == [];
    assert cell.value == item;
    assert cell.Consistent();
    assert cell in cellOwned;
    assert fresh(cell);
    assert fresh(cellOwned - {cell});

    forall o | o in cellOwned
      ensures fresh(o)
    {
      if o == cell {
        assert fresh(cell);
      } else {
        assert o in cellOwned - {cell};
      }
    }

    assert fresh(cellOwned);
    assert this !in cellOwned;
    assert cell !in oldChain;

    oldLast.successor := cell;

    ghost var todo := oldChain;
    while todo != {}
      invariant todo <= oldChain
      invariant oldChain == old(chain)
      invariant oldOwned == old(owned)
      invariant oldModel == old(model)
      invariant first == oldFirst
      invariant last == oldLast
      invariant chain == oldChain
      invariant owned == oldOwned
      invariant model == oldModel
      invariant cell !in oldChain
      invariant cell.owned == cellOwned
      invariant cell in cellOwned
      invariant cell.successor == null
      invariant cell.suffix == []
      invariant cell.value == item
      invariant oldLast.successor == cell
      invariant forall node ::
        node in oldChain ==>
          node.value == oldValues[node]
      invariant forall node ::
        node in oldChain ==>
          (node == oldLast ==> node.successor == cell) &&
          (node != oldLast ==>
            node.successor == oldSuccessors[node])
      invariant forall node ::
        node in oldChain - todo ==>
          node.suffix == oldSuffixes[node] + [item] &&
          node.owned == oldNodeOwneds[node] + cellOwned
      invariant forall node ::
        node in todo ==>
          node.suffix == oldSuffixes[node] &&
          node.owned == oldNodeOwneds[node]
      decreases |todo|
    {
      ghost var node :| node in todo;
      node.suffix := oldSuffixes[node] + [item];
      node.owned := oldNodeOwneds[node] + cellOwned;
      todo := todo - {node};
    }

    assert todo == {};
    assert oldChain - todo == oldChain;
    assert forall node ::
      node in oldChain ==>
        node.suffix == oldSuffixes[node] + [item] &&
        node.owned == oldNodeOwneds[node] + cellOwned;
    assert forall node ::
      node in oldChain ==>
        node.value == oldValues[node];
    assert forall node ::
      node in oldChain ==>
        (node == oldLast ==> node.successor == cell) &&
        (node != oldLast ==>
          node.successor == oldSuccessors[node]);

    owned := oldOwned + cellOwned;
    chain := oldChain + {cell};
    last := cell;
    model := first.suffix;

    assert first == oldFirst;
    assert first.suffix == oldSuffixes[oldFirst] + [item];
    calc {
      model;
      == first.suffix;
      == oldSuffixes[oldFirst] + [item];
      == oldModel + [item];
      == old(model) + [item];
    }

    forall node | node in oldChain
      ensures node.Consistent()
      ensures node.owned <= owned
      ensures this !in node.owned
      ensures node.successor != null
      ensures node.successor in chain
    {
      assert node.suffix == oldSuffixes[node] + [item];
      assert node.owned == oldNodeOwneds[node] + cellOwned;
      assert oldNodeOwneds[node] <= oldOwned;
      assert node in oldNodeOwneds[node];
      assert node in node.owned;
      assert node.owned <= owned;
      assert this !in oldNodeOwneds[node];
      assert this !in cellOwned;
      assert this !in node.owned;

      if node == oldLast {
        assert oldSuccessors[node] == null;
        assert oldSuffixes[node] == [];
        assert node.successor == cell;
        assert node.successor != null;
        assert cell in cellOwned;
        assert cell in node.owned;
        assert cell.owned == cellOwned;
        assert cell.owned <= node.owned;
        assert node.successor in node.owned;
        assert node.successor.owned <= node.owned;
        calc {
          node.suffix;
          == oldSuffixes[node] + [item];
          == [] + [item];
          == [cell.value] + cell.suffix;
          == [node.successor.value] + node.successor.suffix;
        }
        assert node.successor in chain;
      } else {
        assert oldSuccessors[node] != null;
        assert node.successor == oldSuccessors[node];
        assert node.successor != null;
        assert oldSuccessors[node] in oldChain;
        assert node.successor in oldChain;
        assert oldSuccessors[node] in oldNodeOwneds[node];
        assert node.successor in oldNodeOwneds[node];
        assert node.successor in node.owned;
        assert oldNodeOwneds[oldSuccessors[node]] <=
          oldNodeOwneds[node];
        assert node.successor.owned ==
          oldNodeOwneds[oldSuccessors[node]] + cellOwned;
        assert node.successor.owned <= node.owned;
        assert node.successor.suffix ==
          oldSuffixes[oldSuccessors[node]] + [item];
        assert node.successor.value ==
          oldValues[oldSuccessors[node]];
        assert oldSuffixes[node] ==
          [oldValues[oldSuccessors[node]]] +
          oldSuffixes[oldSuccessors[node]];
        calc {
          node.suffix;
          == oldSuffixes[node] + [item];
          == ([oldValues[oldSuccessors[node]]] +
              oldSuffixes[oldSuccessors[node]]) + [item];
          == [oldValues[oldSuccessors[node]]] +
              (oldSuffixes[oldSuccessors[node]] + [item]);
          == [node.successor.value] + node.successor.suffix;
        }
        assert node.successor in chain;
      }

      assert node.Consistent();
    }

    assert cell.owned == cellOwned;
    assert cell in cell.owned;
    assert cell.successor == null;
    assert cell.suffix == [];
    assert cell.Consistent();
    assert cell.owned <= owned;
    assert this !in cell.owned;

    forall node | node in chain
      ensures node.owned <= owned &&
        this !in node.owned &&
        node.Consistent() &&
        (node.successor == null ==> node == last)
      ensures node.successor != null ==> node.successor in chain
    {
      if node == cell {
        assert node.owned <= owned;
        assert this !in node.owned;
        assert node.Consistent();
        assert node.successor == null;
        assert node == last;
      } else {
        assert node in oldChain;
        assert node.owned <= owned;
        assert this !in node.owned;
        assert node.Consistent();
        assert node.successor != null;
        assert node.successor in chain;
      }
    }

    assert this in owned;
    assert chain <= owned;
    assert first in chain;
    assert last in chain;
    assert last.successor == null;
    assert model == first.suffix;
    assert Consistent();

    assert oldOwned == old(owned);
    assert owned - old(owned) <= cellOwned;
    assert fresh(cellOwned);
    assert fresh(owned - old(owned));
    assert model == old(model) + [item];
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
