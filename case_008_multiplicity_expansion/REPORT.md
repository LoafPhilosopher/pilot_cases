# Extension case 008: expanding a multiplicity representation

## Sources and frozen observation

- Generated attempt: `generated_attempt_01.dfy`
- DafnyBench ID119 reference:
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_map-multiset-implementation.dfy`
- Relational proof: `comparison_harness.dfy`

Raw sequence equality is recorded, while multiset equality is the primary
semantic relation because neither the contract nor the reference fixes a key
enumeration order.

## Result

**Proved equivalent under the primary multiset relation.  Raw sequence
equality is false in general under the nondeterministic semantics.**

`ImplementationsAgreeAsMultisets` calls the actual reference and generated
methods on the same positive-count map.  For every integer, it proves equal
result multiplicity: keys in the map have the prescribed count, while keys
outside the map are absent by the two abstraction-function interfaces.  Dafny
then proves equality of the complete result multisets for arbitrary input
maps.  This is an unbounded relational proof, not bounded testing.

`RawOrderWitness` uses the concrete input

```text
map[1 := 1, 2 := 1]
```

and proves that `[1, 2]` and `[2, 1]` are unequal sequences with equal
multisets.  More strongly, it proves both sequences satisfy every frozen
return postcondition for both the reference and generated abstraction
interfaces.  Both retained bodies choose the next key with `:|` from a set,
so different enumeration orders are admissible executions.  This is a
concrete semantic counterexample to universal raw-sequence equality, not a
claim about one compiled runtime trace.

## Trust boundary

The source's bodyless `A`/`LemmaReverseA` and the alpha-renamed generated
`AbstractView`/`RepresentationAgreement` are trusted specification interfaces
already present in the frozen input.  The report does not count them as proof
hints invented by the generated method.  The relational harness uses their
declared contracts exactly as each target does.

## Verification

With pinned Dafny 4.3.0:

```text
Reference:         27 verified, 0 errors
Generated attempt:  4 verified, 0 errors
Combined harness:  37 verified, 0 errors
```

Reference warnings concern deprecated semicolons and are not errors.  The
harness also emits one indentation warning for a `forall` body; it verifies
successfully.  An anti-bypass scan of the generated file found no `assume`,
`{:verify false}`, `{:axiom}`, `{:extern}`, or `decreases *`.

## Classification

```text
PRIMARY MULTISET: PROVED-EQUIVALENT
RAW SEQUENCE:     CONCRETE PERMUTATION COUNTEREXAMPLE
PROTOCOL:         CONFORMING
```

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 008
```
