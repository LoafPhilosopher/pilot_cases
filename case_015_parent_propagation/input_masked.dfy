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
    // Implement this body.
  }
}
