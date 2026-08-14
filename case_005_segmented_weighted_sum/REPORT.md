# Superseded candidate: segmented weighted sums

> **Not one of the active five cases and not included in their experimental
> count.** This candidate is retained only as an audit record. It was replaced
> by `../case_005_tree_window/` because the executable specification function
> made its generated target implementation too direct for the intended
> programming-nontriviality criterion.

## Outcome

The generated attempt and DafnyBench ground truth ID771 are extensionally
equivalent on every input satisfying their shared preconditions. Their returned
arrays have the same length and the same integer at every index. The combined
harness proves the stronger sequence statement:

```dafny
generated[..] == reference[..]
```

This is an unbounded Dafny proof, not testing on a finite collection of
examples.

ID771 maps to:

`DafnyBench/DafnyBench/dataset/ground_truth/veri-sparse_tmp_tmp15fywna6_dafny_spmv.dfy`

The masked/generated names correspond to the reference names as follows:

| Generated | ID771 reference |
|---|---|
| `SegmentValue` | `sum` |
| `BuildResult` | `SpMV` |
| `values`, `indices`, `boundaries`, `weights` | `X_val`, `X_crd`, `X_pos`, `v` |

The apparently extra lower bound `0 <= X_crd[i]` in the reference function is
automatic in the generated program because `indices`/`X_crd` has element type
`nat`.

## Machine-checked relational proof

`comparison_harness.dfy` includes both complete source files. It proves:

1. `SegmentSpecificationsAgree`: `SegmentValue` and `sum` are equal for every
   permitted array state and every permitted `start`/`stop`. The proof follows
   their identical recursive equations.
2. `ImplementationsHaveSameContent`: calls `BuildResult` and `SpMV` on the same
   arrays and proves equal lengths, equality at every valid result index, and
   equality of the complete array slices.
3. `ContractCompatibleAliasingBuild` and `ContractAliasWitness`: constructively
   demonstrate that the shared shape/content contract can be satisfied by a
   method that returns the `values` input on a suitable state.

The second proof uses the two methods modularly through their public
postconditions. Once the function-renaming lemma is available, both
postconditions prescribe the same value at every result index. No loop
invariant from either implementation is used by the relational caller.

Using the repository's pinned Dafny 4.3.0 installation, verification reports:

```text
Ground truth:        4 verified, 0 errors
Generated attempt:   3 verified, 0 errors
Combined harness:   14 verified, 0 errors
```

## Content equality is not array identity

Dafny arrays are reference objects. Thus these two statements have different
meanings:

- `generated[..] == reference[..]` says the arrays have equal element
  sequences; this is proved.
- `generated == reference` says both variables designate the same array
  object; this is neither claimed nor needed for content equivalence.

The shared contracts specify length and indexed content, but contain no
`fresh(result)` postcondition and no reference disequalities such as
`result != values`. Consequently, a modular caller cannot derive a blanket
freshness or non-aliasing guarantee from those contracts alone. Nor do the
contracts require aliasing. Depending on a particular input's shape and
content, their stated properties may incidentally rule out a particular alias,
but they do not do so uniformly.

The harness makes this specification gap concrete without confusing it with
the programs under comparison. `ContractCompatibleAliasingBuild` satisfies the
same shared result obligations over the full input domain. When `values`
already has the required result length and contents, it returns `values`
itself. `ContractAliasWitness` verifies a permitted concrete state for which
`result == input`. This is a witness about what the contract allows; it is
explicitly **not** a claim that either `BuildResult` or `SpMV` takes that branch.

Source inspection establishes the actual allocation behavior: the generated
body executes

```dafny
result := new int[boundaries.Length - 1];
```

and ID771 executes

```dafny
y := new int[N](i => 0);
```

Therefore each concrete implementation allocates its own result rather than
returning an input array. In a sequential comparison call, the two concrete
results are separate newly allocated array objects even though their slices are
equal. That allocation/identity observation comes from the bodies and Dafny's
`new` semantics; it is not exported by the supplied postconditions and is not
the relational theorem proved from those postconditions.

## Implementation comparison

The algorithms have different structures:

- The generated implementation allocates the result, visits each segment once
  in an outer loop, evaluates its complete weighted sum through the recursive
  pure function `SegmentValue`, and writes that value in one assignment.
- ID771 allocates a zero-filled result and uses nested imperative loops. For
  each segment, it advances coordinate index `k` and accumulates each weighted
  term directly into `y[n]`.

Because boundaries are nondecreasing, segment interiors do not overlap. Both
implementations therefore process the same total segment span, although the
generated version uses recursion for an individual segment while ID771 is
iterative. These operational observations come from source inspection; the
equivalence proof relies on their verified contracts.

## Trust and reproduction

The generated attempt was left unchanged. An anti-bypass scan found no
`assume`, `{:verify false}`, `{:axiom}`, `{:extern}`, or `decreases *`.

From the project root:

```bash
./verifierbench/dafny verify \
  verifierbench/DafnyBench/DafnyBench/dataset/ground_truth/veri-sparse_tmp_tmp15fywna6_dafny_spmv.dfy

./verifierbench/dafny verify \
  verifierbench/pilot_cases/case_005_segmented_weighted_sum/generated_attempt_01.dfy

./verifierbench/dafny verify --verify-included-files \
  verifierbench/pilot_cases/case_005_segmented_weighted_sum/comparison_harness.dfy
```

The two warnings emitted for the ground truth (and repeated when it is
included by the harness) concern deprecated unnecessary semicolons on
`requires` clauses. They are not verification errors. Concise command results
are recorded in `verification.txt`.
