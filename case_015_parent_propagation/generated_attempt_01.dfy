class AggregateNode {
  var childA: AggregateNode?
  var childB: AggregateNode?
  var predecessor: AggregateNode?
  var payload: int
  var aggregate: int

  function Consistent(universe: set<AggregateNode>): bool
    reads this, predecessor, childA, childB
  {
    this in universe &&
    (predecessor != null ==>
      predecessor in universe &&
      (predecessor.childA == this || predecessor.childB == this)) &&
    (childA != null ==>
      childA in universe && childA.predecessor == this && childA != childB) &&
    (childB != null ==>
      childB in universe && childB.predecessor == this && childA != childB) &&
    aggregate == payload +
      (if childA == null then 0 else childA.aggregate) +
      (if childB == null then 0 else childB.aggregate)
  }

  function ChainFinite(active: set<AggregateNode>): bool
    reads active
  {
    this in active &&
    (predecessor != null ==> predecessor.ChainFinite(active - {this}))
  }

  method PropagateUpdate(change: int, ghost active: set<AggregateNode>, ghost universe: set<AggregateNode>)
    requires active <= universe && ChainFinite(active)
    requires forall node :: node in universe && node != this ==> node.Consistent(universe)
    requires predecessor != null ==>
      predecessor in universe &&
      (predecessor.childA == this || predecessor.childB == this)
    requires childA != null ==>
      childA in universe && childA.predecessor == this && childA != childB
    requires childB != null ==>
      childB in universe && childB.predecessor == this && childA != childB
    requires aggregate + change == payload +
      (if childA == null then 0 else childA.aggregate) +
      (if childB == null then 0 else childB.aggregate)
    modifies active`aggregate
    ensures forall node :: node in universe ==> node.Consistent(universe)
  {
    var p := predecessor;
    var previousAggregate := aggregate;

    assert this in active;
    assert this in universe;

    if p != null {
      assert p.ChainFinite(active - {this});
      assert p in active - {this};
      assert p != this;
    }
    assert p != this;

    if childA == this {
      assert childA != null;
      assert childA.predecessor == this;
      assert p == this;
      assert false;
    }
    if childB == this {
      assert childB != null;
      assert childB.predecessor == this;
      assert p == this;
      assert false;
    }
    assert childA != this;
    assert childB != this;

    label BeforeUpdate:
    aggregate := aggregate + change;

    assert aggregate == previousAggregate + change;
    if childA != null {
      assert childA.aggregate == old@BeforeUpdate(childA.aggregate);
    }
    if childB != null {
      assert childB.aggregate == old@BeforeUpdate(childB.aggregate);
    }
    assert aggregate == payload +
      (if childA == null then 0 else childA.aggregate) +
      (if childB == null then 0 else childB.aggregate);
    assert Consistent(universe);

    forall node | node in universe && node != this && node != p
      ensures node.Consistent(universe)
    {
      assert old@BeforeUpdate(node.Consistent(universe));

      if node.childA == this {
        assert old@BeforeUpdate(node.childA == this);
        assert old@BeforeUpdate(node.childA.predecessor == node);
        assert old@BeforeUpdate(this.predecessor == node);
        assert p == node;
        assert false;
      }
      if node.childB == this {
        assert old@BeforeUpdate(node.childB == this);
        assert old@BeforeUpdate(node.childB.predecessor == node);
        assert old@BeforeUpdate(this.predecessor == node);
        assert p == node;
        assert false;
      }

      assert node.childA != this;
      assert node.childB != this;
      assert node.aggregate == old@BeforeUpdate(node.aggregate);
      if node.childA != null {
        assert node.childA.aggregate == old@BeforeUpdate(node.childA.aggregate);
      }
      if node.childB != null {
        assert node.childB.aggregate == old@BeforeUpdate(node.childB.aggregate);
      }
      assert node.Consistent(universe);
    }

    if p != null {
      assert p != this;
      assert p in universe;
      assert p.ChainFinite(active - {this});
      assert active - {this} <= universe;
      assert active - {this} < active;
      assert old@BeforeUpdate(p.Consistent(universe));
      assert p.childA == this || p.childB == this;

      assert old@BeforeUpdate(
        p.aggregate == p.payload +
          (if p.childA == null then 0 else p.childA.aggregate) +
          (if p.childB == null then 0 else p.childB.aggregate));

      if p.childA == this {
        assert old@BeforeUpdate(p.childA != p.childB);
        assert p.childB != this;
      } else {
        assert p.childB == this;
        assert old@BeforeUpdate(p.childA != p.childB);
        assert p.childA != this;
      }

      assert p.aggregate + change == p.payload +
        (if p.childA == null then 0 else p.childA.aggregate) +
        (if p.childB == null then 0 else p.childB.aggregate);

      assert p.predecessor != null ==>
        p.predecessor in universe &&
        (p.predecessor.childA == p || p.predecessor.childB == p);
      assert p.childA != null ==>
        p.childA in universe &&
        p.childA.predecessor == p &&
        p.childA != p.childB;
      assert p.childB != null ==>
        p.childB in universe &&
        p.childB.predecessor == p &&
        p.childA != p.childB;

      forall node | node in universe && node != p
        ensures node.Consistent(universe)
      {
        if node == this {
          assert node.Consistent(universe);
        } else {
          assert node != this;
          assert node.Consistent(universe);
        }
      }

      p.PropagateUpdate(change, active - {this}, universe);
    } else {
      forall node | node in universe
        ensures node.Consistent(universe)
      {
        if node == this {
          assert node.Consistent(universe);
        } else {
          assert node != p;
          assert node.Consistent(universe);
        }
      }
    }
  }
}
