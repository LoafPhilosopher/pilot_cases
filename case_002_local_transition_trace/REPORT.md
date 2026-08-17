# Case 002: building a Boolean transition trace

The first generated program did not pass Dafny, so no comparison with the reference program was made.

## Problem

The input consists of a Boolean sequence `seed`, a function `transition` that
maps three Boolean values to one Boolean value, and a non-negative number of
rounds. The output is the complete history of repeatedly applying the function
to the row. The first output row must be `seed`; each later cell is computed
from the cell at the same position and its two neighbours in the preceding
row. A missing neighbour beyond either end of the row is treated as `false`.

The generated program was required to implement this interface:

```dafny
method BuildTrace(
    seed: seq<bool>,
    transition: (bool, bool, bool) -> bool,
    rounds: nat)
  returns (trace: seq<seq<bool>>)
  requires |seed| >= 2
  ensures |trace| == rounds + 1
  ensures trace[0] == seed
  ensures forall i | 0 <= i < |trace| :: |trace[i]| == |seed|
  ensures forall i | 0 <= i < |trace| - 1 ::
    forall j | 1 <= j <= |trace[i]| - 2 ::
      trace[i + 1][j] ==
        transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
```

Two further postconditions specify the boundary cells: the next row starts
with `transition(false, old[0], old[1])` and ends with
`transition(old[last - 1], old[last], false)`. The contract therefore
determines the complete returned trace for a fixed seed, transition function,
and number of rounds.

## What the reference and generated programs do

The reference program builds the trace iteratively:

```text
result := [seed]
current := seed
repeat rounds times:
    start the next row with transition(false, current[0], current[1])
    append each interior cell computed from its three neighbours
    append transition(current[last-1], current[last], false)
    append the completed row to result
return result
```

The generated program chose a recursive organization. For zero rounds it
returns `[seed]`. Otherwise it recursively builds the trace for one fewer
round, takes the final row of that prefix, constructs its successor with a
helper called `BuildNext`, and appends the successor. `BuildNext` uses a Dafny
sequence-constructor expression with separate cases for the first cell, last
cell, and interior cells.

The two descriptions express the same intended recurrence, but intention is
not enough for a verified Dafny solution: every sequence access must also be
proved safe.

## Result and evidence

With Dafny 4.3.0, the reference program produced:

```text
Dafny program verifier finished with 3 verified, 0 errors
```

The untouched generated program produced:

```text
Dafny program verifier finished with 3 verified, 2 errors
```

Both errors occur in the fallback branch of the sequence-constructor lambda in
`BuildNext`. Dafny cannot establish that the accesses corresponding to
`row[j - 1]` and `row[j]` are in range at that point. These are proof errors in
the submitted program, not counterexamples showing that the returned trace is
mathematically wrong.

## What is proved and what is not

Dafny proves that the reference implementation meets the contract. It does
not prove that the generated implementation meets it, because of the two
index-safety failures. The generated program was not repaired and a second
answer was not requested.

The study compares behavior with the reference only when the generated answer
passes verification. Consequently this case has no equivalence result. The
similarity of the two algorithms is visible from the source, but it cannot be
used as a substitute for the failed verification or as evidence that the two
complete programs behave identically.

## Reproduce

Run `./reproduce.sh --case 002` from the repository root.
