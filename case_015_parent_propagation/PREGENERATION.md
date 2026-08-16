# Pregeneration record: case 015

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
- DafnyBench ID: `482`
- Hidden source: `DafnyBench/dataset/ground_truth/dafny-language-server_tmp_tmpkir0kenl_Test_vacid0_Composite.dfy`
- Original target: `Composite.Adjust`
- Frozen alias: `AggregateNode.PropagateUpdate`

The complete pinned source was checked before context extraction with Dafny
4.3.0: `13 verified, 0 errors`. The hidden target body was not copied into
`input_masked.dfy` or `PROMPT.md`.

Local diagnostics on the frozen masked input: `dafny resolve` succeeds. A full
verification reports `3 verified, 1 error`; the sole error is the expected
unproved target postcondition at the intentionally empty `PropagateUpdate`
body.

## Frozen context boundary

Kept under consistent aliases:

- the class and all five fields used by the target contract;
- the validity/aggregate predicate and parent-chain termination function, with
  their full original definitions;
- every original requires clause, the field-restricted modifies clause, and
  the postcondition.

Removed before generation:

- initialization, update, attach, detach, client, and test methods;
- source-run directives, explanatory comments, examples, original path, and
  all original declaration names;
- the hidden `Adjust` body and its loop invariants.

No contract clause was weakened. The `active` and `universe` sets remain
distinct, and the field-restricted frame expressed by the target's `modifies`
clause is kept exactly under the alias mapping.

## Observation relation frozen before output

This is a state-mutating, void method. Relate initial reference and generated
heaps by a bijection over `universe` that preserves the receiver, child and
predecessor edges, payloads, aggregates, and membership in `active`. After both
calls, require under that same bijection:

1. equal aggregate values for every node in `universe`;
2. unchanged and corresponding topology and payload fields; and
3. satisfaction of the respective full validity predicate for every node.

Raw object identity across the two separately typed heaps is not an
observation. Any difference outside this relation will be reported separately.
Only a verifier-pass sample proceeds to comparison.

## Sampling rule

Run exactly one generation and preserve its first raw response whether it
passes or fails. Do not repair, retry, replace, or add context after seeing the
response. No generation has yet been run.
