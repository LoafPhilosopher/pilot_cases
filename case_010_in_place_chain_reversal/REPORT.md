# Case 010: the repair verifies but is not equivalent

**Direct answer.** The first generated program failed with 17 resolution/type
errors. Repair Round 01 changed Dafny's sequence-length syntax and then verified
with `8 verified, 0 errors`. Only this verifier-passing repair was compared with
the reference. A two-node execution is a concrete counterexample under the
comparison fixed before generation: the reference reverses successor links,
whereas the repair leaves the links unchanged and reverses the values stored in
the nodes. The contract is missing requirements for the identity of the
returned node, the concrete reversal of the successor chain, and what aliases
to the original nodes observe, including preservation of each node's value.

## Problem and current specification

This is DafnyBench ID308. A `Link<T>` contains a value and an optional
successor. Its ghost sequence `View` lists the values reached by following
successors, and `Owned` is a set used by the representation predicate
`Consistent`.

The method must return a consistent chain whose abstract values are reversed:

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

These postconditions describe the values observable from the returned head.
They do not say which old node must be returned or which old node must follow
which. They also do not say that a value must remain attached to the same node.

### Synthesis task and supplied context

`Rewire` has no explicit value argument. Its runtime input is the receiver's
concrete `value` and `successor` chain. The ghost fields `View` and `Owned`
provide verification context rather than additional runtime inputs. The method
returns `result` and may mutate nodes in `Owned`. The agent was given the class
and field declarations, `Consistent`, the constructor, and the `Rewire`
signature and contract, with the target body omitted. The recorded prompt
contains no reference body, test case, example output, required returned-node
identity, or required successor arrangement ([`PROMPT.md`](PROMPT.md)).

The synthesis task was to return a chain with the required reversed abstract
`View`, not to recover the reference program's concrete pointer-reversal
algorithm. Repair Round 01 additionally received the failed program and its
Dafny feedback, but not the reference implementation.

## First attempt and repair

The first response proposed this strategy:

1. recursively compute the reverse of `View`;
2. walk the existing successor chain and overwrite its node values with that
   sequence; and
3. return the original head without changing successor links.

That first file was not a valid Dafny program because it used `.Length` on
sequences. Dafny 4.3.0 requires `|sequence|`; it reported 17 resolution/type
errors. The original file and its log remain unchanged.

Repair Round 01 received that program and the verifier feedback. It replaced
the invalid `.Length` expressions with Dafny sequence-length expressions. It
did not change the value-overwriting algorithm. The saved repair verifies with
`8 verified, 0 errors`, so repair stopped after this round.

The reference uses a different algorithm. It detaches the old head, walks the
old chain, and redirects every successor pointer to the already reversed
prefix. It does not move values between nodes and returns the former tail.
The pinned reference independently verifies with `10 verified, 0 errors`.

## Concrete two-node counterexample

The comparison harness constructs corresponding two-node inputs:

```text
old head(value = 1) -> old tail(value = 2) -> null
```

It directly includes the pinned DafnyBench `ListContents.dfy` file and the saved
Round 01 file. The harness calls the original `Node<int>.ReverseInPlace` and the
repair's `Link<int>.Rewire`. Both returned ghost sequences are `[2, 1]`; Dafny
proves those assertions from the two method contracts. Their concrete states
nevertheless differ:

| Observation after the call | Reference | Round 01 repair |
|---|---|---|
| Returned old node | old tail | old head |
| Returned value chain | `2 -> 1` | `2 -> 1` |
| Old head's value | `1` | `2` |
| Old tail's value | `2` | `1` |
| Old head's successor | `null` | old tail |
| Old tail's successor | old head | `null` |

The original DafnyBench file, the saved repair, and the harness verify together
with `19 verified, 0 errors`. Running the harness with Dafny's
Python target prints `true` for the returned-node and successor observations
shown in the table, as well as the two different pairs of values stored in the
old nodes. Both saved implementations are executed directly; no translated
reference class is used. The reference is included from the pinned DafnyBench
checkout, and the repair is included from
`repair/round_01/output_program.dfy`.

One concrete input is sufficient to reject equivalence under the fixed
comparison, which includes the returned abstract sequence, the concrete chain
relative to the original nodes, and observations through aliases to those
nodes. The counterexample does not conflict with verification: both concrete
outcomes satisfy the current abstract postconditions.

## What the specification would need to rule this out

Requiring only a reversed `View` is insufficient. To force the reference's
behavior, the specification needs a ghost description of the original node
sequence and postconditions that:

- return the old final node;
- make the returned concrete node sequence the reverse of the old node
  sequence; and
- preserve the value held by every original node, so clients retaining aliases
  do not observe values being exchanged.

The existing `result.Owned <= old(Owned)` condition does not express any of
these points: the repair uses only old nodes and therefore satisfies it.

## Reproduce

From the repository root, reproduce the first attempt, repair, and comparison
with:

```bash
./reproduce.sh --case 010
```

The saved round feedback and verification log are in `repair/round_01/`.
The comparison output is saved in `repair/comparison_verification.txt`.
