# Case 003: choosing two repeated values

Both programs pass Dafny, but they can return different valid pairs because the contract does not say which repeated values to choose or in which order.

## Problem

The input is an integer array of length at least four. At least two distinct
values must each occur at least twice, and every array value must lie between
zero (inclusive) and `values.Length - 2` (exclusive). The method must return
two different values that each occur at least twice in the array:

```dafny
method ChooseWitnesses(values: array<int>) returns (x: int, y: int)
  requires 4 <= values.Length
  requires exists x, y ::
    x != y && HasWitness(values, x) && HasWitness(values, y)
  requires forall i :: 0 <= i < values.Length ==>
    0 <= values[i] < values.Length - 2
  ensures x != y && HasWitness(values, x) && HasWitness(values, y)
```

Here `HasWitness(values, v)` means that there are indices `i < j` with
`values[i] == values[j] == v`. The postcondition deliberately permits any two
distinct repeated values. It contains no rule for choosing between three or
more possibilities and no rule for ordering the returned pair.

## What the reference and generated programs do

The reference program makes one left-to-right pass. It uses an auxiliary array
to remember the first position at which each value appeared. The first value
whose second occurrence is encountered becomes the first result. Scanning then
continues until the second occurrence of a different value is encountered.
Thus its choices are ordered by where values occur for the second time.

The generated program performs nested scans over index pairs. It finds the
first equal pair in `i`-then-`j` order and returns that value as `x`. It then
restarts the same search and finds the first equal pair whose value differs
from `x`, returning it as `y`. Its choices are therefore ordered by the first
occurrence of each repeated value. The generated proof contains lemmas that
record which index pairs have already been ruled out.

## Result and evidence

Dafny 4.3.0 reports:

```text
Reference program:   4 verified, 0 errors
Generated program:  18 verified, 0 errors
Comparison file:    23 verified, 0 errors
```

The comparison file verifies that the example arrays satisfy the method
preconditions and that both returned pairs satisfy their postconditions. It
also runs the two actual programs. The first example is:

```text
input:        [0, 1, 1, 0]
reference:    (1, 0)
generated:    (0, 1)
```

The same two values are returned in the opposite order. A second example shows
that the difference is not limited to order:

```text
input:        [0, 1, 2, 2, 1, 0]
reference:    (2, 1)
generated:    (0, 1)
```

All three values in the second input occur twice, so both selected pairs are
allowed. This is a concrete counterexample to equality even if the pair is
viewed as an unordered two-element set.

## What is proved and what is not

Dafny proves that each method always returns two legal witnesses under the
given preconditions. The displayed executions show that these two concrete
methods are not equal as functions returning an ordered pair. Their exact
selection strategies are conclusions from reading the two bodies; the
comparison file does not derive the exact returned pair from the public
contract, because the contract does not contain enough information to do so.

For these two implementations, the raw pairs agree exactly when the first two
repeated values in first-occurrence order are also the first two in
second-occurrence order, in the same order. A simpler sufficient condition is
that exactly two distinct values repeat and those two have the same relative
first- and second-occurrence order. If exactly two values repeat but the pair
is treated as unordered, both methods return the same set even when their
orders differ. These conditions follow from inspection of the current bodies;
they are not consequences of the shared contract for arbitrary
implementations.

## Reproduce

Run `./reproduce.sh --case 003` from the repository root.
