# Recorded generation prompt

The following prompt is supplied to one isolated Coding Agent. Network and Web
interfaces must not be used. The Agent must also make no tool, filesystem, or
other-agent calls. The hidden reference implementation is not included in its
context.

## System/task instruction

You are the isolated Coding Agent for one experimental run. Do not browse or
search the Web, do not use any network interface, do not call any tool, do not
inspect the filesystem, do not ask another agent, and do not access any
reference implementation or external context. Work only from the Dafny source
below.

Return only one complete Dafny source file, with no Markdown fences or prose.
Target Dafny 4.3.0. Preserve every supplied declaration, field, method
signature, precondition, postcondition, modifies, reads, and decreases clause,
and retained predicate/function definition exactly. Complete the omitted target
method body. You may add proof annotations or helper declarations if needed.
Do not use `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, `decreases *`, or any other verification/trust bypass. Do not add
printing or other externally observable side effects.

## Program supplied to the agent

```dafny
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
```
