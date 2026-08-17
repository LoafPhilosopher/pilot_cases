# Case 013: restoring memory from an undo log

The generated program reconstructs the intended reverse recovery loop, but it
does not pass Dafny: two array writes lack the required frame proof, so no
equivalence comparison with the reference program was performed.

## Problem given to the model

This is DafnyBench ID327. The object has an integer array `records`, an integer
array `values`, a remaining-step counter, and a ghost state. `records[0]`
stores the number of active log entries. The following positions contain
pairs of the form `(offset, oldValue)`. The predicates guarantee that each
offset is in range and that the first logged value for an offset is its
baseline value.

The model received this method interface:

```dafny
method RestoreState()
  modifies records
  modifies values
  modifies this
  requires ContainerInvariant()
  requires ActiveState(model)
  requires BaselineRelation(model)
  requires Represents(model)
  ensures model == SpecifiedState(old(model))
  ensures Represents(model)
```

`SpecifiedState` fixes every field of the final ghost state: the entry count
becomes zero, `currentValues` becomes `baselineValues`, and the stored log,
value count, intended values, counter, baseline, and first-entry map remain
unchanged. `Represents` connects this state to the concrete arrays. The model
was not given the reference traversal code.

Reverse order matters when one memory offset appears in several log entries.
Later entries restore intermediate values first, while the earliest entry for
that offset contains its baseline value. Replaying from the last active entry
to the first therefore leaves every logged offset at the baseline. Offsets
that never appeared in the log are already required to equal the baseline.

## What the two programs do

The reference recovery method uses this executable structure:

```text
read the number of active records
visit records from the last active pair to the first
for each pair (offset, oldValue), write values[offset] := oldValue
set records[0] := 0
update the ghost state to the recovered state
```

Its loop invariants also state that the `records` and `values` fields still
refer to the same array objects as at method entry.

The generated program follows the same reverse order. It proves detailed
facts about which offsets have already reached their baseline values, then
writes `values[offset] := restored`. After the loop it writes
`records[0] := 0` and assigns the specified ghost state. It does not, however,
carry the array-identity facts needed for those writes.

## Verification result

The complete DafnyBench reference file verifies with Dafny 4.3.0:

```text
Reference program: 37 verified, 0 errors
```

The first generated response was kept unchanged and produces:

```text
generated_attempt_01.dfy(226,12): Error:
assignment might update an array element not in the enclosing context's modifies clause

generated_attempt_01.dfy(307,11): Error:
assignment might update an array element not in the enclosing context's modifies clause

Dafny program verifier finished with 6 verified, 2 errors
```

The rejected statements are `values[offset] := restored` inside the loop and
`records[0] := 0` after it. Because `modifies this` allows object fields to be
changed, Dafny needs proof that the field expressions `values` and `records`
still denote the entry-state arrays authorized by the method's frame. The
reference carries this information explicitly. The generated invariants
describe array contents but do not preserve the necessary object identities.

## What is and is not established

The response inferred a plausible recovery algorithm and many of its content
invariants. That is not a successful Dafny solution: the two rejected writes
mean the verifier has not established that the method respects its allowed
heap updates. A verification failure is also not evidence that the executable
outputs differ from the reference. It also cannot be treated as evidence of
equality merely because its executable steps resemble the reference loop. The
program was not repaired or rerun, and we did not compare its final arrays or
ghost state with the reference.

## Reproduction

```bash
./reproduce.sh --case 013
```
