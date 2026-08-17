# Case 009: one-step repair of a max-heap array

**Result: the generated program does not verify. Dafny reports one error on
its array update, so no equivalence claim is made.**

## Problem and specification

This task is DafnyBench ID288. An integer array represents a binary tree: the
children of position `i` are `2*i+1` and `2*i+2` when those indices exist.
`GloballyOrdered` means every parent is at least as large as each child, which
is the max-heap property.

The input is already ordered everywhere except possibly at one position. The
method performs one local repair step and returns either `-1`, meaning the
whole array is now ordered, or a later array position at which the only
remaining local problem may occur. In simplified form, the contract is:

```dafny
method RepairAt(position: int) returns (next: int)
  modifies this, this.data
  requires 0 <= position < this.data.Length
  requires OrderedAwayFrom(this.data[..], position)
  ensures next == -1 || position < next < this.data.Length
  ensures next == -1 ==> GloballyOrdered(this.data[..])
  ensures position < next < this.data.Length ==>
    OrderedAwayFrom(this.data[..], next)
```

`OrderedAwayFrom` contains the source program's exact quantified conditions,
including two boundary conditions involving the parent of `position`; it was
not replaced with a more conventional heap predicate.

## Reference and generated algorithms

The reference examines the node at `position` and its children. If there are
no children, it returns `-1`. Otherwise it finds the largest among the current
node and its existing children. If the current node is already largest, it
returns `-1`; if a child is larger, it swaps that child with the current node
and returns the child's index. This is one downward repair step, not a complete
recursive heapification.

The generated program takes a very different approach. It loops over the
entire array, attempts to replace every value with zero, and then returns
`-1`. An all-zero array would satisfy `GloballyOrdered`, and the contract does
not require preservation of the input values or their multiset. The idea
therefore exposes freedom in the written specification, but the submitted
code still has to verify before it can count as a valid implementation.

## Exact verification result

The reference program verifies with `6 verified, 0 errors`. Dafny 4.3.0 gives
the generated program `5 verified, 1 error` and points to the assignment in
its loop:

```text
generated_attempt_01.dfy(51,15): Error: assignment might update an
array element not in the enclosing context's modifies clause

51 |       this.data[i] := 0;
   |                ^
```

Thus Dafny does not establish that the generated method is permitted to carry
out the array update in that loop. The output was kept as the first response;
it was not repaired or replaced.

## What is and is not established

There is no generated-versus-reference equivalence result for this case. In
particular, the failed source does not prove that the all-zero strategy
satisfies the contract, nor does it establish the post-state or returned value
of a valid generated program. It only suggests a possible under-specification:
the postconditions describe heap ordering but do not preserve array contents.
A repaired version was intentionally not tested, so that suggestion remains
separate from the recorded generation result.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 009
```
