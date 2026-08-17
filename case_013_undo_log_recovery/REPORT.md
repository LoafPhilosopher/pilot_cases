# Case 013: restoring memory from an undo log

**Repair outcome: Repair Round 01 verifies and the repaired body is equivalent
to the reference under the comparison used in this study.** Dafny proves equality of
the final abstract states, complete log/record contents, complete memory/value
contents, and countdown values. Both bodies also preserve their entry array
objects and caller aliases, but that last fact is established by direct source
inspection because neither public method contract includes array-identity
postconditions.

## Problem and specification

The object stores an undo log, a mutable value array, a remaining-step counter,
and a ghost state. Position zero of the log array is the number of active
entries. The following positions contain pairs `(offset, oldValue)`. The
preconditions guarantee that each offset is valid and that the earliest log
entry for an offset contains its baseline value.

The generated method has this contract:

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

`SpecifiedState` sets the active entry count to zero and restores
`currentValues` to `baselineValues`. It preserves the stored entries, value
count, intended values, counter, baseline values, and first-entry map.

Recovery must process entries in reverse order. If one offset occurs more than
once, later entries first restore intermediate values; the earliest entry then
restores the baseline value.

## Reference, first attempt, and repair

Both programs use the same executable algorithm:

```text
read the active-entry count
visit log pairs from the last active pair to the first
write each saved old value back to its recorded offset
set the active-entry count to zero
update the ghost state to the recovered state
```

The first generation omitted the frame facts that its `records` and `values`
fields still denoted the arrays present at method entry. Dafny consequently
rejected the write to `values[offset]` and the final write to `records[0]`.
Repair Round 01 saved both entry arrays in local variables and added identity
invariants to the reverse loop. It did not replace the recovery algorithm.

| Program | Dafny 4.3.0 result | Outcome |
|---|---:|---|
| First generation | 6 verified, 2 errors | Both array writes lacked frame proofs |
| Repair Round 01 | 7 verified, 0 errors | Final verifier-passing repair |

Only Repair Round 01 is compared with the reference. The failed first program
and its verifier log remain unchanged as the initial generation record.

## Equivalence comparison

The comparison pairs the reference ghost state with the generated ghost state
field by field: entry count, stored entries, value count, current values,
baseline values, intended values, remaining steps, and first-entry map.

For arbitrary legal initial states, an induction over the reference
`reverse_recovery` function shows that recovery changes only its abstract
memory sequence before setting the entry count to zero. The proof then relates
the reference recovered state to `SpecifiedState` in all eight fields. The
harness calls each actual public method, takes immutable snapshots immediately
after each call, and proves equality of:

- the complete reference log and generated record arrays,
- the complete reference memory and generated value arrays,
- the reference countdown and generated remaining-step value, and
- every field of the two ghost states under the declared name mapping.

The reference file verifies with `37 verified, 0 errors`. Verifying the
reference, Repair Round 01, and comparison harness together gives
`50 verified, 0 errors`.

## What Dafny proves and what was checked by reading the code

The full relation also requires each execution to retain its own original
public array objects, so a caller-held alias continues to observe the restored
contents. Cross-run pointer equality is not required.

This identity property cannot be derived from the two public contracts.
`modifies this` permits a field assignment, and neither method has an
`ensures records == old(records)`-style clause. The retained bodies nevertheless
preserve identity:

- the reference writes only `mem_[off]` and `log_[0]`; it never assigns a new
  array to `mem_` or `log_`, and its loop carries `mem_ == old(mem_)` and
  `log_ == old(log_)`;
- Repair Round 01 writes only `values[offset]` and `records[0]`; it never
  assigns the fields, and its verified loop invariants keep them equal to the
  entry arrays saved in `originalValues` and `originalRecords`.

Thus the two retained bodies satisfy the full relation. The content and ghost
state correspondence is machine-checked; the connection from the bodies to
entry array identity is the stated source-inspection step. Adding explicit
array-identity postconditions to both interfaces would make that final step
available to a modular Dafny proof.

## Reproduce

From the repository root, reproduce the first attempt, repair, and comparison
with:

```bash
./reproduce.sh --case 013
```
