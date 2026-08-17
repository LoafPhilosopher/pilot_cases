# Case 015: propagating a change through parent links

The reference loop and generated recursion add the same integer change once to
each corresponding node from the receiver to the root, while preserving the
tree structure and payloads. The final connection between this abstract proof
and the two method bodies was checked manually, statement by statement.

## Problem given to the model

This is DafnyBench ID482. Each node has two children, a parent called
`predecessor` in the masked version, an integer payload, and an integer
aggregate. A consistent node satisfies

```text
aggregate = payload + left-child aggregate + right-child aggregate,
```

with a missing child contributing zero. `ChainFinite(active)` says that the
receiver and its successive parents form a finite chain inside `active`.

The target method can modify only aggregate fields in `active`. All other
nodes are initially consistent, and the receiver's aggregate is short by
exactly `change` relative to its payload and children. Its main contract is:

```dafny
method PropagateUpdate(change: int,
    ghost active: set<AggregateNode>,
    ghost universe: set<AggregateNode>)
  requires active <= universe && ChainFinite(active)
  requires aggregate + change ==
    payload +
      (if childA == null then 0 else childA.aggregate) +
      (if childB == null then 0 else childB.aggregate)
  modifies active`aggregate
  ensures forall node :: node in universe ==> node.Consistent(universe)
```

The complete input also states the parent-child links and consistency of every
other node. The reference body was hidden.

## What the two programs do

The reference `Adjust` method is iterative:

```text
p := receiver
while p is not null
    p.sum := p.sum + change
    p := p.parent
```

Its proof removes each visited node from a finite ghost set. The generated
`PropagateUpdate` method is recursive:

```text
save receiver.predecessor
receiver.aggregate := receiver.aggregate + change
prove the receiver and unrelated nodes remain consistent
if the saved predecessor exists
    recursively update it with active minus the receiver
```

Neither body changes a parent link, child link, or payload.

## Comparison and Dafny results

The reference and generated heaps use different class types, so the comparison
pairs their nodes one to one. Initially paired nodes must have matching
parents, children, payloads, aggregates, and membership in the active sets.

Calling the actual methods is proved to preserve paired topology and payloads
and to leave every node valid. A separate induction shows that the two
receiver-to-root paths contain paired nodes in the same order. The final
effect theorem states that every paired aggregate remains equal when the same
`change` is added exactly on those paths and all other aggregates are left
alone. These arguments apply to arbitrary finite parent chains rather than a
fixed test tree.

Dafny 4.3.0 reports:

```text
Reference program:    13 verified, 0 errors
Generated program:     4 verified, 0 errors
Combined comparison:  34 verified, 0 errors
```

## What is and is not established

The original postconditions say that all nodes are valid after the call, but
they do not state exactly which modifiable aggregate fields changed. For this
reason, Dafny cannot use the public contracts of the actual calls to prove
post-call aggregate equality directly.

We connected the abstract path-effect theorem to the retained bodies by
checking their executable statements. The reference has one aggregate write
inside a loop that follows `parent`. The generated method has one aggregate
write before a recursive call on `predecessor`. Their decreasing sets prevent
a node from being updated twice, and neither method writes an aggregate off
the path. Combining this source check with the Dafny path theorem gives equal
aggregates for all paired nodes, along with equal topology and payloads.

The Dafny theorem covers the effect along paired parent paths. Matching that
effect to each imperative body is the manual step. Nodes in the separately
allocated heaps correspond through the stated one-to-one pairing; their raw
object addresses are outside this comparison.

## Reproduction

```bash
./reproduce.sh --case 015
```
