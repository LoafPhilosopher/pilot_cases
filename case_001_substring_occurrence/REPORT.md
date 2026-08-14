# Pilot case 001: verified substring search programs with different outputs

## Question

If a Coding Agent synthesizes a Dafny implementation from a method contract and
the result passes the verifier, is it behaviorally equivalent to the benchmark's
ground-truth implementation?

## Why this case

This is DafnyBench test `004`, whose ground truth implements substring search.
It is a non-trivial programming task: the original implementation performs a
nested search over two character sequences, returns both a Boolean and an
index, and uses quantified invariants and several proof lemmas. It was not
selected for having a simple scalar output.

The original source is:

`third_party/DafnyBench/DafnyBench/dataset/ground_truth/AssertivePrograming_tmp_tmpwf43uz0e_Find_Substring.dfy`

## Agent input

The target body and all ground-truth proof code were hidden. Names and comments
that reveal the original algorithm were removed or replaced consistently:

- `FindFirstOccurrence` became `ComputeWitness`;
- `ExistsSubstring` became `ContainsAtLeastOnce`;
- `Post` became `ResultCondition`;
- parameters and return variables were renamed neutrally.

Only the following semantic requirement remained:

- `ok` is true exactly when `pattern` occurs in `source`;
- if `ok` is true, `index` denotes an occurrence.

The contract does **not** require the returned occurrence to be the first one,
and it places no constraint on `index` when `ok` is false.

The exact prompt is in `PROMPT.md`, and the program skeleton is in
`input_masked.dfy`. The Coding Agent was instructed not to use web search,
tools, the filesystem, trusted declarations, or verification bypasses. This
pilot contains one independent generation attempt.

## Verification result

The first raw generation verified without repair:

```text
Dafny program verifier finished with 3 verified, 0 errors
```

The generated file contains none of the screened bypasses (`assume`,
`{:verify false}`, `{:axiom}`, `{:extern}`, or `decreases *`). The original
ground truth also verifies under the pinned Dafny 4.3.0 installation. Verifying
the complete comparison unit, including both implementations, produced:

```text
Dafny program verifier finished with 16 verified, 0 errors
```

## Implementation comparison

The two verified programs use different implementation structures:

- The ground truth enumerates candidate ending positions and compares the two
  strings character-by-character backwards in an inner loop. Its proof uses
  three auxiliary invariant predicates and three lemmas, in addition to the
  two contract predicates.
- The generated program enumerates candidate starting positions and directly
  tests whether `pattern` is a prefix of each suffix `source[i..]`. Its proof is
  centered on one quantified loop invariant stating that no earlier position
  matched.

By inspection of these two implementations, both return the first occurrence
on a successful search,
although minimality is not required by the supplied contract. This agreement
may reflect a natural or learned canonical search strategy; one sample is not
enough to attribute it to training data or naming.

## Counterexample to full output equivalence

For `source = "a"` and `pattern = "b"`, the verified runtime harness prints:

```text
ground truth: ok=false, index=1
generated:    ok=false, index=0
```

Both outputs satisfy the contract, because `index` is constrained only when
`ok` is true. Nevertheless, the complete returned pairs are different.

Therefore the two programs are:

- **not extensionally equivalent as raw `(ok, index)`-returning methods**;
- **equivalent if a client treats `index` as unobservable/irrelevant whenever
  `ok` is false**;
- equivalent as raw return pairs under the additional input condition
  `ContainsAtLeastOnce(source, pattern) || |source| < |pattern|`.

The last condition covers successful searches and the ground truth's early
failure branch, in which both implementations return index `0`.

The Dafny checks prove that each implementation satisfies the contract, and
the executable harness demonstrates the concrete counterexample. The general
success-case and conditional-equivalence statements above are conclusions from
code inspection, not yet a machine-checked relational proof.

## Specification observations

Two independent behaviors are left open by the postcondition:

1. which occurrence is returned when there are multiple matches;
2. which index is returned when there is no match.

The first omission did not cause these particular implementations to differ,
but the second did. If exact return-tuple equivalence is intended, the contract
must choose a canonical failure index. If “first occurrence” is intended, it
must also state that there is no earlier matching position.

## Takeaway

This case demonstrates the distinction the proposed study is intended to
examine: passing the same verifier contract establishes contract conformance,
but it does not necessarily establish equality of all observable program
outputs. The appropriate equivalence judgment depends on whether the return
index is considered meaningful on failure.

## Reproduction

From this repository root:

```bash
./reproduce.sh --case 001
```

This installs or checks the pinned dependencies, verifies the reference,
generated attempt, and combined harness, and runs the concrete counterexample
without writing compiler output into the case directory. Historical command
outputs are preserved in `verification.txt`.
