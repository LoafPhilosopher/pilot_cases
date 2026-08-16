# Pregeneration record: case 013

## Frozen status

- Prepared: 2026-08-16
- Status: prospective and unrun; no model response exists
- Planned generations: exactly one independent first sample
- Web/network policy: the prompt prohibits Web, network, tools, filesystem
  access, other agents, and the hidden reference. The platform still exposes
  these capabilities, so the retained log will be audited for zero actual
  calls before the first response
- Verifier: Dafny 4.3.0
- DafnyBench commit: `0cd28feed9cd0179b07fdb9d002f8c39063658e4`
- DafnyBench ID: `327`
- Hidden source: `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_lightening_verifier.dfy`
- Original target: `UndoLog.recover`
- Frozen alias: `MutableContainer.RestoreState`

The complete pinned source was checked before context extraction with Dafny
4.3.0: `37 verified, 0 errors`. The hidden target body was not copied into
`input_masked.dfy` or `PROMPT.md`.

Local diagnostics on the frozen masked input: `dafny resolve` succeeds. A full
verification reports `6 verified, 1 error`; the sole error is the expected
unproved target postcondition at the intentionally empty `RestoreState` body.

## Frozen context boundary

Kept under consistent aliases:

- the full abstract-state datatype;
- the state-shape, transaction-shape, baseline, and concrete-representation
  predicates used by the target contract or its proof obligations;
- a bodyless ghost state-transition declaration referenced by the target
  postcondition, with field-level postconditions that uniquely characterize
  the hidden source transition's final state on legal inputs;
- the three concrete fields, the ghost model field, and the target's exact
  requires, ensures, and modifies clauses.

Removed before generation:

- `CrashableMem`, operation datatypes, initialization/countdown/write/commit
  functions, and all other definitions not transitively needed by the target;
- constructors and every sibling method (`init`, countdown/write helpers,
  begin/commit, and transactional write);
- the recursive prefix-transition helper and the executable body of the final
  state transition;
- the crash-safety theorem, source comments, original path, and all original
  declaration names;
- the hidden `recover` body and its loop invariants.

No target-method contract clause was weakened or strengthened. Before any
model output, one pregeneration specification normalization was applied outside
that contract: the pinned source's executable recursive transition and
executable wrapper were replaced by the non-executable, bodyless ghost
declaration `SpecifiedState`. Its eight field postconditions specify exactly
the source wrapper's result on legal inputs: the entry count becomes zero,
current values become baseline values, and every other `StateRecord` field is
unchanged. The equivalence basis is the pinned wrapper's verified final-state
semantics together with Dafny datatype-update semantics: its returned record
changes precisely those two fields and preserves the other six. Because every
datatype field is fixed, this normalized relation is functional, but it reveals
no traversal order, index calculation, loop invariant, or recovery algorithm.
This change avoids both an executable specification oracle and the hidden
reverse-recovery blueprint while retaining the exact denotation required by
the original target postcondition.

## Observation relation frozen before output

This is a state-mutating, void method. Given reference and generated initial
objects related by equal abstract states, equal value-level concrete state,
and corresponding caller-held aliases to their pre-state arrays, the primary
full-behavior comparison will require after both calls:

1. equal ghost/abstract state records under the declared alias mapping;
2. equal full integer contents of the record arrays;
3. equal full integer contents of the value arrays;
4. equal remaining-step scalars;
5. within each execution, `records == old(records)` and
   `values == old(values)`, so the two public fields preserve the identities
   of their original array objects; and
6. consequently, each caller-held pre-state alias observes the same final
   array object and contents rather than an abandoned object after field
   reassignment.

Cross-run pointer equality is neither meaningful nor required; item 5 compares
each result with its own pre-state. Although the supplied method contract
permits field reassignment through `modifies this`, the hidden reference keeps
both array identities, and those identities are externally observable through
the public fields and pre-existing aliases. A secondary, explicitly weaker
abstract relation may report only items 1--4. Passing that weaker relation is
not full behavioral equivalence and will not be labelled
`proved-equivalent`. Only a verifier-pass sample proceeds to either comparison.

## Sampling rule

Run exactly one generation and preserve its first raw response whether it
passes or fails. Do not repair, retry, replace, or add context after seeing the
response. No generation has yet been run.
