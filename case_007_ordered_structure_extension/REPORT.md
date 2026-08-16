# Extension case 007: extending an ordered structure

## Sources and frozen observation

- Generated attempt: `generated_attempt_01.dfy`
- DafnyBench ID107 reference:
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/Dafny-Practice_tmp_tmphnmt4ovh_BST.dfy`
- Relational proof: `comparison_harness.dfy`

`Tree/Empty/Node`, `BST`, and `NumbersInTree` are related by the frozen
alpha-renaming to `Structure/Blank/Piece`, `Structured`, and `ValuesOf`.
Raw datatype shape is the first observation; the ordered value-set abstraction
is reported separately.

## Result

**Proved equivalent at both the raw-tree and abstract-set levels.**

For the abstract relation, `ActualImplementationsAgreeAbstractly` calls both
retained methods on corresponding inputs.  `AbstractionEncoding` proves that
the datatype conversion preserves inorder layout, orderedness, and the value
set.  Dafny then proves the two actual results are structured and have the same
value set for arbitrary permitted inputs.

For raw shape, the proof records the executable equations of each target after
erasing only proof-only assertions, ghost variables, and lemma calls.  Both
equations recurse left exactly when `item < root` and otherwise recurse right,
then rebuild the same node.  `ExecutableProjectionAgreement` proves by
structural induction that encoding the reference result equals the generated
result for every tree and item.  Two executable-body clone methods are also
verified against those equations, so every retained branch, recursive call,
and constructor assignment is checked.  This is an unbounded source-level
relational proof, not a finite test.

The transparent proof boundary is that Dafny does not automatically extract a
method body into a pure function: the two projections were transcribed from
the included bodies and audited against them.  The machine proof checks the
transcribed executable semantics and their relation; the correspondence of
each projection to the included source is a small source-inspection step.

## Why the contract alone is insufficient

`ContractShapeWitness` proves that these two unequal shapes are both strictly
ordered and contain exactly `{1, 2}`:

```text
Piece(1, Blank, Piece(2, Blank, Blank))
Piece(2, Piece(1, Blank, Blank), Blank)
```

Thus raw equality comes from the two implementations sharing the same
recursive insertion path, not from uniqueness of the postcondition.  The
abstract relation would hold for either shape.

## Verification

With pinned Dafny 4.3.0:

```text
Reference:         14 verified, 0 errors
Generated attempt: 11 verified, 0 errors
Combined harness:  38 verified, 0 errors
```

The reference warning is a deprecated semicolon, not an error.  An anti-bypass
scan of the generated file found no `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, or `decreases *`.

## Classification

```text
RAW DATATYPE SHAPE: PROVED-EQUIVALENT VIA EXECUTABLE-SOURCE PROJECTION
ABSTRACT VALUE SET: PROVED-EQUIVALENT FOR THE ACTUAL METHOD CALLS
PROTOCOL:           CONFORMING
```

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 007
```
