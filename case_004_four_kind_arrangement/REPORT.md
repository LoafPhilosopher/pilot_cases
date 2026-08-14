# Pilot case 004: the arrangement contract uniquely determines the result

## Question

Does satisfying `ValidArrangement(result)` while preserving the input multiset
leave room for two verified implementations to return different sequences?

## Sources compared

- Generated attempt: `generated_attempt_01.dfy`
- DafnyBench ground truth ID690:
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/formal_verication_dafny_tmp_tmpwgl2qz28_Challenges_ex7.dfy`
- Machine-checked relational proof: `comparison_harness.dfy`

The ground truth calls its constructors `A`, `C`, `G`, and `T` and its ordering
predicate `below`. The masked/generated program consistently renames these to
`K0`, `K1`, `K2`, and `K3` and calls the predicate `AllowedPair`.

## Result

**The returned sequence is uniquely determined by `ValidArrangement` and the
preserved multiset.** This is a general, unbounded Dafny proof, not a finite test.

Consequently:

- any two calls to `Transform` on the same permitted input return equal
  sequences;
- any two calls to ground-truth `Sorter` return equal sequences; and
- after the constructor bijection `A/C/G/T -> K0/K1/K2/K3`, the concrete
  ground-truth and generated calls return equal sequences.

The combined verification result is:

```text
Dafny program verifier finished with 49 verified, 0 errors
```

## Why the specification is deterministic

`AllowedPair` is precisely the nondecreasing order induced by:

```text
Rank(K0) = 0 < Rank(K1) = 1 < Rank(K2) = 2 < Rank(K3) = 3
```

Thus `ValidArrangement` says every earlier element is less than or equal to
every later element. For two valid sequences with equal multisets, the proof in
`UniqueValidArrangement` proceeds inductively:

1. Equal multisets imply equal lengths.
2. Each first element occurs in the other sequence.
3. Validity makes each sequence's first element no greater than every element
   occurring in that sequence. Applying this in both directions gives equal
   ranks for the two heads.
4. `Rank` is injective on the four constructors, so the heads are equal.
5. Cancelling that common singleton from the equal multisets gives equal tail
   multisets. Validity is inherited by tails, so induction proves equal tails.

This proves equality for arbitrary sequence lengths and arbitrary
multiplicities of all four constructors. The theorem itself also covers the
empty sequence, although both implementation contracts require nonempty input.

## Relational harness

The harness includes both complete source files and contains three executable
relational proof methods:

- `GeneratedCallsAgree` calls `Transform` twice and proves its two results
  equal using only the public postconditions and the uniqueness theorem.
- `GroundTruthCallsAgree` does the analogous proof for `Sorter`.
- `ImplementationsAgree` calls both concrete implementations on corresponding
  inputs and proves
  `Encode(original) == generated`.

`Encode` is the elementwise constructor bijection. Supporting lemmas prove that
it preserves length, individual elements, multiplicities, and the arrangement
predicate, and that it is injective. Therefore the cross-implementation result
is semantic equality modulo the intentional datatype renaming, not merely
agreement on selected examples.

## Implementation comparison

The implementations reach the canonical arrangement differently:

- ID690 implements a four-region Dutch-national-flag partition with mutable
  boundary indices and sequence swaps.
- The generated attempt implements functional insertion sort, together with
  recursive lemmas for sortedness, length, and multiset preservation.

Their algorithmic structures differ substantially, but the contract permits
only one returned sequence for a given input multiset. In this case, contract
conformance is enough to establish output equivalence.

## Verification and trust checks

Using the repository's pinned Dafny 4.3.0 installation:

```text
Ground truth:         6 verified, 0 errors
Generated attempt:  18 verified, 0 errors
Combined harness:   49 verified, 0 errors
```

The two warnings in ground-truth and combined verification concern deprecated,
unnecessary semicolons after specification clauses; they are not verification
errors. An anti-bypass scan of the generated attempt found no `assume`,
`{:verify false}`, `{:axiom}`, `{:extern}`, or `decreases *`.

## Reproduction

From this repository root:

```bash
./reproduce.sh --case 004
```

Historical command outputs are preserved in `verification.txt`.
