# Case 015: propagating an aggregate change through a parent chain

## Outcome

The untouched first generation passes Dafny.  Under the frozen heap-bijection
observation, the reference loop and generated recursion have the same concrete
effect: they add `change` once to each corresponding node on the receiver's
finite predecessor chain and leave all other aggregate fields unchanged.
Topology and payload fields are unchanged, and both methods establish their
full validity predicates.

Classification: **proved-equivalent under the frozen abstract heap relation,
with an explicit inspected-body bridge**.  The relation and effect theorems are
machine checked and unbounded.  Dafny's modular call rule cannot derive the
per-node effect from the original public contracts, so the final connection
from each retained body to the common effect is a line-by-line source check,
not an end-to-end theorem about the two original method calls.  This boundary
is important and is detailed below.

The hidden source is DafnyBench ID482:

`third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafny-language-server_tmp_tmpkir0kenl_Test_vacid0_Composite.dfy`

## Verification gate

Using pinned Dafny 4.3.0, all three files pass without repair:

```text
Hidden reference:                        13 verified, 0 errors
Generated attempt:                        4 verified, 0 errors
Combined unit, including both sources:   34 verified, 0 errors
```

The harness declarations alone account for `17 verified, 0 errors`; the
combined count uses `--verify-included-files` so that both included source
files are verified in the same command.

The saved generation was compared only after its verifier-pass result.  The
comparison did not edit `generated_attempt_01.dfy`, `input_masked.dfy`,
`PROMPT.md`, or `PREGENERATION.md`.

## Frozen relation represented in the harness

`comparison_harness.dfy` represents the cross-typed bijection as a finite map
from hidden-reference `Composite` nodes to generated `AggregateNode` nodes.
It requires that the map:

- has exactly the two `universe` sets as domain and range and is injective;
- maps the two receivers and membership in the two `active` sets;
- preserves parent/predecessor and both child edges, including nullness;
- preserves payload (`val`/`payload`) and initial aggregate (`sum`/`aggregate`)
  values.

This is the full frozen observation relation.  It does not compare raw object
identity, because the two heaps use different classes and allocations.

## What is directly machine checked about the actual calls

`ContractsPreserveStructureAndValidity` calls the two retained methods on
arbitrary related heaps satisfying all original preconditions.  Dafny proves,
over the full frozen input domain, that:

- the bijection still preserves topology and payload after both calls;
- every reference node satisfies `Valid`; and
- every generated node satisfies `Consistent`.

The field-restricted modifies clauses are crucial: only `sum` or `aggregate`
inside the respective active sets may change, so topology and payload cannot
drift.

The method deliberately does not claim post-call aggregate equality.  Both
original contracts say only that all nodes are valid after the call.  They do
not specify which modifiable active aggregates changed.  In particular, an
`active` set may contain nodes unrelated to the receiver chain; modularly, a
contract-compatible implementation could change such nodes if it could retain
validity.  It would therefore be unsound to infer the exact effect from these
postconditions alone.

## Unbounded path and effect proof

The harness separately machine checks three relational facts:

1. `UpPathsCorrespond` inducts over the finite active set and proves that the
   reference parent path and generated predecessor path have equal length and
   corresponding nodes at every index.
2. `MappedPathsHaveSameMembership` proves that, under injectivity, a reference
   node is on its path exactly when its generated image is on the other path.
3. `CorrespondingPathEffectsPreserveValues` proves for arbitrary finite
   universes and arbitrary path lengths that adding the same `change` exactly
   on those paths preserves equality of every paired aggregate value.

This theorem covers all nodes, including unrelated active nodes, and is not a
toy scalar lemma or bounded test.

## Inspected-body bridge and its limit

The hidden body has one executable aggregate assignment inside its loop:
`p.sum := p.sum + delta`.  It starts at the receiver, moves to `p.parent`, and
stops at null.  Its decreasing set removes the current node, so the finite path
contains no repeated update.

The generated body likewise has one executable aggregate assignment per call:
`aggregate := aggregate + change`.  It then recurses only on the saved
`predecessor`, passing `active - {this}`, and stops when that pointer is null.
All other statements in that body are proof-only assertions or local reads.
Consequently each retained body satisfies the exact path-effect premise used
by the relational theorem, and neither writes an unrelated aggregate.

That last paragraph is a transparent source-code inspection, not something
exposed by the methods' public `ensures` clauses.  If either body were replaced
while keeping the same weak postcondition, the machine-checked effect harness
alone would not certify aggregate equality.  A future stricter artifact
could duplicate/instrument the bodies with strengthened effect postconditions
or prove the effect in a refinement layer.  The present report therefore does
not describe the combined harness as a single end-to-end machine proof.

Combining the inspected effect with the machine-checked path theorem gives the
frozen result: all paired aggregates remain equal, topology and payload remain
corresponding, and both full validity predicates hold.  Raw allocation identity
remains intentionally outside the observation relation.

## Implementation comparison

The reference uses an iterative cursor and a shrinking ghost termination set.
The generation transforms the same state transition into structural recursion
over `active - {this}` and supplies detailed assertions to re-establish
validity around each recursive call.  The executable write/traversal semantics
match even though the proof organization and control flow differ.

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 015
```

The exact commands and outputs used for this report are retained in
`verification.txt`.
