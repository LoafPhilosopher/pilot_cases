# Case 012: selecting a majority candidate

The two programs always return the same value when the input promises a strict
majority, but they are not equal on all permitted inputs: on `[0, 1, 2]` with
the promise set to false, the generated program returns `0` and the reference
program returns `2`.

## Problem given to the model

This is DafnyBench ID313. `SegmentFrequency(values, 0, |values|, x)` counts how
often `x` occurs in the complete nonempty sequence. The central interface was:

```dafny
method SelectCandidate<Choice(==)>(
    values: seq<Choice>, ghost promised: bool,
    ghost designated: Choice) returns (candidate: Choice)
  requires |values| != 0
  requires promised ==>
    2 * SegmentFrequency(values, 0, |values|, designated) > |values|
  ensures promised ==> candidate == designated
```

The parameters `promised` and `designated` are ghost values, so they are used
for verification but are erased from executable code. If `promised` is true,
`designated` occurs in more than half of the sequence and the method must
return it. If `promised` is false, the postcondition places no restriction on
the returned candidate.

This distinction is part of the callable interface rather than an invalid
edge case. A caller may legally pass `promised=false` for any nonempty
sequence, including one that has no majority. The comparison must therefore
cover both settings when asking whether the complete methods always return the
same value. A strict majority, when it exists, is unique because two different
values cannot each occur more than half of the time.

The model did not receive the reference body. However, historical metadata in
the platform context exposed the filename `MajorityVote.dfy`. It exposed no
source code, and the model made no Web, filesystem, or tool calls. The result
below remains a valid comparison of the two programs, but this case cannot show
that changing method names removed every clue about the original task.

## What the two programs do

The reference program uses a cancellation-style majority search:

```text
start with the first value as the current candidate
scan a segment in which that candidate has a strict lead
when the lead disappears, discard the segment
if values remain, restart with the next value
return the candidate of the final segment
```

The generated program takes a different approach:

```text
initialize candidate to values[0]
visit every element values[i]
count its frequency in the complete sequence
replace candidate only if values[i] is a strict majority
return candidate
```

## Result

For `promised=true`, the comparison first proves that the reference `Count`
function and `SegmentFrequency` compute the same number. The precondition then
says that `designated` is a strict majority, and both postconditions force the
two calls to return exactly `designated`. This argument applies to every
nonempty sequence and every element type supported by the methods.

For `promised=false`, consider `[0,1,2]`. No value is a strict majority, so the
generated program retains its initial candidate `0`. The reference starts
with `0`. After seeing `1`, the current candidate loses its strict lead, and
the remaining segment restarts at the last element, `2`. Execution prints:

```text
input:     [0, 1, 2]
generated: 0
reference: 2
```

Dafny 4.3.0 reports:

```text
Reference program:    16 verified, 0 errors
Generated program:     7 verified, 0 errors
Combined comparison:  28 verified, 0 errors
Counterexample run:     5 verified, 0 errors
```

## What is and is not established

Dafny proves equality for every input satisfying the true-promise condition.
The printed false-promise results come from executing the two retained bodies.
They cannot be derived from the false branch of the postcondition because that
branch says nothing about `candidate`. The `5 verified` count checks that the
comparison program and calls are legal. The numbers `0` and `2` are obtained
by running the compiled bodies. The single input above is sufficient to
disprove equality on all permitted calls. It does not claim that the programs
differ on every sequence without a majority.

## Reproduction

```bash
./reproduce.sh --case 012
```
