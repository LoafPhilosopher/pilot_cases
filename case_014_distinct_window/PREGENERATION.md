# Pregeneration record: case 014

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
- DafnyBench ID: `417`
- Hidden source: `DafnyBench/dataset/ground_truth/dafleet_tmp_tmpa2e4kb9v_0001-0050_0003-longest-substring-without-repeating-characters.dfy`
- Original target: the first, unprimed `lengthOfLongestSubstring` method with
  return signature `(n: int, ghost best_iv: interval)`
- Frozen alias: `SelectDistinctWindow`

The complete pinned source was checked before context extraction with Dafny
4.3.0: `4 verified, 0 errors`. The hidden target body was not copied into
`input_masked.dfy` or `PROMPT.md`.

Local diagnostics on the frozen masked input: `dafny resolve` succeeds. A full
verification reports `2 verified, 5 errors`; all five arise at the intentionally
empty target body (unproved postconditions and uninitialized output), not in
the retained type, function, or predicate definitions.

## Frozen context boundary

Kept under consistent aliases:

- the interval subset type and its witness;
- the interval-length function and pairwise-distinctness predicate, with their
  original definitions;
- the exact first target signature and both postconditions.

Removed before generation:

- the problem URL, prose, examples, sliding-window explanation, complexity
  discussion, and algorithm comments;
- the complete first target body and its invariants;
- the second, primed implementation and all of its code and discussion;
- the original path and every recognizable declaration name except unavoidable
  primitive notions in the formal specification.

No contract clause was weakened. Even after aliasing, the contract describes a
classic maximum distinct-character substring task. This is intentionally the
shortlist's recognizable-problem contamination stress case. Masking reduces
surface fingerprints but cannot establish absence from training data.

## Observation relation frozen before output

The primary executable observation is the integer `size`. Reference and
generated calls on the same input string must return the same integer. The
contract makes that maximum length unique even when several maximizing spans
exist.

The ghost `chosen` span is recorded as a secondary proof-level observation.
Exact endpoint equality will be checked and reported, but a different valid
maximizing span will not count as a difference in executable behavior. Any
claim about full declared-tuple equivalence must distinguish this ghost-witness
freedom from equality of `size`. Only a verifier-pass sample proceeds to
comparison.

## Sampling rule

Run exactly one generation and preserve its first raw response whether it
passes or fails. Do not repair, retry, replace, or add context after seeing the
response. No generation has yet been run.
