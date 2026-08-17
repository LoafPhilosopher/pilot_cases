# Case 002: building a Boolean transition trace

**Repair round 01 passes Dafny and is proved equivalent to the reference for the complete returned trace.** No output field is missing from the specification: for fixed inputs, the contract determines the initial row and every cell of every later row. The initial-generation failure was a proof failure for two sequence accesses, not a behavioral counterexample.

## Problem

The inputs are a Boolean sequence `seed`, a function `transition` from three
Booleans to one Boolean, and a non-negative number of rounds. The method must
return the full history produced by repeatedly applying `transition`. A
non-existent neighbor beyond either end of a row is represented by `false`.

The relevant contract is:

```dafny
method BuildTrace(
    seed: seq<bool>,
    transition: (bool, bool, bool) -> bool,
    rounds: nat)
  returns (trace: seq<seq<bool>>)
  requires |seed| >= 2
  ensures |trace| == 1 + rounds
  ensures trace[0] == seed
  ensures forall i | 0 <= i < |trace| :: |trace[i]| == |seed|
  ensures forall i | 0 <= i < |trace| - 1 ::
    forall j | 1 <= j <= |trace[i]| - 2 ::
      trace[i + 1][j] ==
        transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
```

Two additional postconditions fix the boundary cells. The first cell of the
next row is `transition(false, old[0], old[1])`; the final cell is
`transition(old[last-1], old[last], false)`. Thus the contract specifies the
complete output, including its order. There is no tie or unconstrained return
value in this case.

## First attempt and repair

The reference builds the result iteratively. It starts with `[seed]`, computes
one successor row at a time from left to right, and appends each row to the
result.

The first generated program uses recursion instead. It obtains the trace for
`rounds - 1`, calls a helper named `BuildNext` on the last row, and appends the
new row. Its high-level recurrence matches the reference. However, two array
accesses in the fallback branch of the sequence-constructor expression were
not known to be in range. Dafny 4.3.0 reported:

```text
Dafny program verifier finished with 3 verified, 2 errors
```

The original program and this verifier output remain unchanged in
`generated_attempt_01.dfy` and `verification.txt`.

Repair round 01 received that program and the verifier feedback. It added an
explicit guard for the interior case:

```dafny
else if 0 < j && j < |row| - 1 then
  transition(row[j - 1], row[j], row[j + 1])
else
  false
```

The sequence constructor only asks for indices in its declared range, so the
new final branch is unreachable. The guard supplies the bounds facts needed
for the three indexed accesses. No method signature, precondition, or
postcondition changed. The saved round-01 output verifies with:

```text
Dafny program verifier finished with 4 verified, 0 errors
```

Because round 01 is the first verifier-passing repair, it is the only repaired
program compared with the reference.

## Equivalence comparison

`repair/comparison_harness.dfy` calls the pinned ID117 reference and the
round-01 repair with the same symbolic `seed`, `transition`, and `rounds`. It
then proves that their complete returned sequences are equal.

Verified separately with Dafny 4.3.0, the reference reports `3 verified,
0 errors`; as noted above, the repaired program reports `4 verified, 0
errors`.

The proof uses only the two public method contracts. Both returned traces have
the same number of rows, start with the same `seed`, and give every row the
same length. An induction over the row number establishes equality of the
previous rows. For the next row, the boundary postconditions determine its
first and last cells, while the quantified interior postcondition determines
all other cells. Applying the same `transition` function to equal preceding
rows yields equal successor rows. Equal lengths and equal cells then give
equality of the full traces.

With Dafny 4.3.0, verification of the reference, repair, and comparison
harness in one invocation produced:

```text
Dafny program verifier finished with 12 verified, 0 errors
```

The proof covers every input satisfying `|seed| >= 2`, every Boolean
transition function, and every natural-number round count; it is not a finite
test. The number 12 counts verified
Dafny declarations in the included programs and harness; it is not the number
of test inputs.

## Reproduce

From the repository root, run:

```bash
./reproduce.sh --case 002
```

The individual repair record is under `repair/round_01/`; the separate
comparison result is in `repair/comparison_verification.txt`.
