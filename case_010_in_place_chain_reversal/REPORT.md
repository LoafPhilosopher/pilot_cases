# Case 010: reversing a linked chain

**Result: the generated program does not resolve or type-check. Dafny reports
17 errors, so the program was not verified and no equivalence conclusion is
drawn.**

## Problem and specification

This task is DafnyBench ID308. Each `Link<T>` node contains a value and an
optional successor. Ghost fields record the sequence of values reachable from
the node (`View`) and the set of owned nodes (`Owned`). The `Consistent`
predicate connects those ghost fields to an acyclic successor chain.

The target must return a consistent chain whose abstract value sequence is the
reverse of the original sequence:

```dafny
method Rewire() returns (result: Link<T>)
  requires Consistent()
  modifies Owned
  ensures result.Consistent()
  ensures result.Owned <= old(Owned)
  ensures |result.View| == |old(View)|
  ensures forall i :: 0 <= i < |result.View| ==>
    result.View[i] == old(View)[|old(View)| - 1 - i]
```

The contract fixes the returned abstract sequence and forbids the result from
owning new nodes. It does not explicitly say that every old node remains in
the result, that each successor pointer is reversed, or what a client holding
an alias to an old node will observe.

## Reference and generated algorithms

The reference performs an in-place pointer reversal without allocating nodes.
It first detaches the original head, then walks through the old successor
chain. At each step it redirects the current node's successor to the already
reversed prefix and updates the ghost sequence and ownership set. It returns
the former tail as the new head.

The generated response proposes a different concrete behavior. A recursive
helper first computes the reversed value sequence. A second helper then walks
the original successor chain and overwrites each node's stored value with the
corresponding reversed value. It leaves the successor links in their original
direction and returns the original head. If this approach could be verified,
the returned abstract values might match while aliases and pointer structure
differ from the reference.

## Exact verification result

The reference program verifies with `10 verified, 0 errors`. The generated
file fails during resolution and type checking, before Dafny can verify its
proof obligations. It repeatedly applies `.Length` to values of type
`seq<T>`, for example:

```dafny
assert 0 <= next.View.Length - 1 - i < next.View.Length;
```

In Dafny 4.3.0, sequence length is written `|next.View|`; sequences do not
have an array-style `.Length` member. These uses produce 17 resolution/type
errors. The response was retained without a repair attempt.

## What is and is not established

No property of the generated method has been verified, and it was not compared
with the reference through a relational proof or executable counterexample.
The source text does not justify calling the two implementations equivalent or
different. It only identifies a question that a successful candidate would
have made important: whether equality of `result.View` is sufficient, or
whether successor links, old-node reachability, node values, and observations
through aliases must also be compared.

Because this first response fails before verification, the value-overwriting
strategy remains a hypothesis about what the contract may permit, not an
experimental equivalence result.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 010
```
