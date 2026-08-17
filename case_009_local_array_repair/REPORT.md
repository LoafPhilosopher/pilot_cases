# Case 009: local repair of a max-heap array

**Repair outcome: Round 02 verifies, but the repaired program is not
behaviorally equivalent to the reference.** On the legal one-element input
`[7]`, the reference leaves the array as `[7]`, whereas the repaired program
changes it to `[0]`; both return `-1`. The specification permits this difference
because it does not preserve the input values or their multiset and does not
require updates to be limited to one local swap.

## Problem and specification

An integer array represents a binary tree. The children of position `i` are
`2*i+1` and `2*i+2` when those positions exist. `GloballyOrdered` states the
max-heap property: every parent is at least as large as each child.

The input is ordered everywhere except possibly at `position`. The method must
perform a repair and return either `-1`, meaning the whole array is ordered, or
a later position at which the only remaining violation may occur:

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

These postconditions constrain the final heap property and `next`, but say
nothing about which input values must remain in the array.

## Reference, first attempt, and repair rounds

The reference performs one local step. It compares `position` with its existing
children. If the current value is already largest, or if there are no children,
it returns `-1` without changing the array. Otherwise it swaps the current
value with the larger child and returns that child's position.

The first generated program tried to write zero into every array element and
then return `-1`. Its intended all-zero post-state is a max heap, but Dafny
rejected the array update under the loop's frame information. This first
program remains unchanged in `generated_attempt_01.dfy`.

The repair process retained that algorithm and changed its proof and framing:

| Program | Dafny 4.3.0 result | Outcome |
|---|---:|---|
| First generation | 5 verified, 1 error | Array update not justified by the enclosing frame |
| Repair Round 01 | 5 verified, 1 error | Could not prove `target == this.data` |
| Repair Round 02 | 6 verified, 0 errors | Final verifier-passing repair |

Only Round 02 is compared with the reference. The two programs that do not
verify are retained as repair history, not treated as implementations for the
equivalence result.

## Concrete counterexample

Take a one-element array whose only value is `7`, with `position = 0`. Both
`OrderedAwayFrom` preconditions hold because the element has no children. The
actual methods produce:

| Observation | Reference | Repair Round 02 |
|---|---:|---:|
| Final array contents | `[7]` | `[0]` |
| Returned `next` | `-1` | `-1` |
| Field still aliases its original input array | `true` | `true` |

The comparison chosen before repair requires both executions to retain their
original input-array aliases, produce equal complete array contents, and return
equal `next` values. This example does not meet that comparison. Alias
identity and `next` agree here, but the contents do not. The weaker relation
that compares only `(data[..], next)` also fails for the same reason.

The combined harness verifies with `13 verified, 0 errors`, including both
programs and the legal calls. Running it prints the values in the table above.
The exact output is in `repair/comparison_verification.txt`. Because the public
contracts do not determine the post-state contents, the concrete contents are
established by executing the included method bodies, not by a modular
relational proof from their postconditions.

## Missing specification

The contract would need additional postconditions to rule out the all-zero
repair. At minimum, it should require the output to preserve the multiset of
input values. To specify the reference behavior more closely, it should also
state that the array is unchanged when `next == -1`, and otherwise only
`position` and `next` change and their old values are swapped. An array-identity
postcondition would additionally make preservation of the caller's original
array alias explicit. None of these properties follows from the current
contract.

## Reproduce

From the repository root, reproduce the first attempt, both repair rounds, and
the comparison with:

```bash
./reproduce.sh --case 009
```
