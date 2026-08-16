# Dafny equivalence study: five-case pilot and ten-case extension

## Status

This repository contains a technically checked **five-case preliminary
feasibility pilot** and a completed, prospectively frozen **ten-case
extension**. It is not a new benchmark or a modification of DafnyBench's
official evaluation.

On 2026-08-16, the researcher reported advisor approval of the 15-task plan.
The ten extension inputs, prompts, one-sample rule, and observation relations
were frozen at commit
`8b6218c8cc8d235adf24f3c9832a4d70de302983` before any extension output was
requested. The immutable pre-generation snapshot is listed in
[`SHORTLIST.md`](SHORTLIST.md), with the prospective procedure in
[`EXTENSION_PROTOCOL.md`](EXTENSION_PROTOCOL.md). All ten frozen first
attempts have now been run without retries, repairs, or replacements; their
outcomes are reported in [`EXTENSION_RESULTS.md`](EXTENSION_RESULTS.md).

The active five-case set was not preregistered. An initial ID771 run was
replaced after its executable specification made synthesis too direct. That
run remains visible in [`archive/id771_segmented_weighted_sum/`](archive/id771_segmented_weighted_sum/),
but it is not counted as an active sixth case. This post-generation replacement
means the pilot must not be used for aggregate performance claims.

## What the study examined

Each case asks what can be concluded about behavioral equivalence when a
Coding Agent sees a method interface, contract, and necessary context, but not
the benchmark's reference body. The five pilot tasks cover nested search,
higher-order trace construction, witness selection, datatype arrangement, and
interval extraction over a heap-allocated tree. They were chosen for
programming non-triviality and mechanism diversity, not for simple outputs or
pre-labelled “strong/weak” specifications.

The prospective extension adds finite-map minimization, ordered recursive
structures, multiset expansion, array repair, destructive linked structures,
queue mutation, majority selection, undo-log recovery, distinct-window
optimization, and recursive heap propagation. Its task set and comparison
relations were fixed before outputs were observed.

## Procedure actually used

For each task:

1. The implementation at pinned DafnyBench commit
   `0cd28feed9cd0179b07fdb9d002f8c39063658e4` was retained as a hidden
   reference.
2. The reference body, examples, source-identifying comments, sibling
   solutions, and algorithm-revealing names were removed. The model received
   the neutrally renamed target header, its original contract, and the minimum
   definitions needed to understand and verify it.
3. One fresh-context `gpt-5.6-sol` generation was instructed not to browse or search
   the Web, call tools, inspect the filesystem, contact other agents, or access
   the hidden reference.
4. The first response was preserved without repair and checked with Dafny
   4.3.0.
5. Only a verifier-pass candidate entered equivalence analysis. The comparison
   sought a concrete counterexample or machine-checked relational theorem,
   stated the relevant observation relation, and disclosed any remaining
   code-inspection or undetermined boundary.

Across the pilot there were **5 generation attempts; equivalence analysis
was performed for the 4 verifier-pass attempts.** The remaining attempt is
retained as a verifier-fail result, not treated as an equivalence case.

The extension independently froze **10 first attempts**. Seven passed the
verifier and therefore entered comparison; three failed and stopped at the
gate. One of the seven pass attempts (Case 006) made a prohibited outbound
progress call before its final code response. It remains visible as a
protocol-deviating result and was not replaced. The extension therefore also
has a separate protocol-conforming denominator: **9 conforming attempts, of
which 6 passed verification**.

The prompt-level prohibition was audited against the locally retained
structured logs. The five pilot cases and nine of ten extension cases had zero
tool, Web, filesystem, or outbound-agent calls before the saved response;
Case 006 had the disclosed outbound progress call. Tools existed in the
execution environment, so these are actual-use observations, not
capability-level removal. See
[`provenance/manifest.json`](provenance/manifest.json) and
[`provenance/extension_manifest.json`](provenance/extension_manifest.json)
for model settings, generation-artifact hashes, raw-response hashes, exact
denominators, and limitations.

## Preliminary pilot results

| Case | DafnyBench task | First generation | Post-gate comparison |
|---|---|---|---|
| [001](case_001_substring_occurrence/REPORT.md) | ID004, substring occurrence witness | `3 verified, 0 errors` | **Concrete counterexample to raw tuple equality.** On `("a","b")`, reference returns `(false,1)` and generated returns `(false,0)`. They agree if the failure index is unobservable; by code inspection they also agree on success. |
| [002](case_002_local_transition_trace/REPORT.md) | ID117, higher-order local transition trace | `3 verified, 2 errors` | **Verifier-fail; comparison gate not entered.** The untouched attempt has two index-safety proof failures. |
| [003](case_003_repeated_value_pair/REPORT.md) | ID311, select two repeated values | `18 verified, 0 errors` | **Concrete counterexamples.** One input reverses pair order and another changes the selected two-value subset. Raw pairs agree exactly when the two implementations' selection orders choose the same first two values in the same order; with exactly two duplicate values, their unordered witness sets agree. |
| [004](case_004_four_kind_arrangement/REPORT.md) | ID690, arrange four datatype constructors | `18 verified, 0 errors` | **Machine-proved equivalent modulo constructor renaming.** The contract and multiset preservation uniquely determine the result; combined harness: `49 verified, 0 errors`. |
| [005](case_005_tree_window/REPORT.md) | ID491, interval extraction from a tree-structured string | `3 verified, 0 errors` | **Machine-proved output-equivalent under equal abstract string models.** The returned strings agree for every shared permitted interval; combined harness: `26 verified, 0 errors`. |

The main observation is that verifier success establishes contract conformance,
not automatically equality of every raw return value. Cases 001 and 003 expose
open witness choices; cases 004 and 005 show that different implementations
can be related for all inputs when the specified observation is uniquely
determined.

## Prospective extension results

The frozen extension produced **10 first attempts: 7 verifier-pass and 3
verifier/resolution failures**. One pass attempt, Case 006, violated the
zero-outbound-call rule and is retained separately; among the **9 conforming
attempts, 6 passed verification**.

| Case | First attempt | Post-gate result |
|---|---|---|
| [006](case_006_entry_selection/REPORT.md) | `3 verified, 0 errors`; protocol-deviating | Minimum-entry relation proved; raw key equality requires a unique minimum. |
| [007](case_007_ordered_structure_extension/REPORT.md) | `11 verified, 0 errors` | Abstract sets agree on actual calls; raw shape agrees through a proved executable projection with a disclosed source-audit bridge. |
| [008](case_008_multiplicity_expansion/REPORT.md) | `4 verified, 0 errors` | Multisets agree; raw sequence order has a permutation counterexample. |
| [009](case_009_local_array_repair/REPORT.md) | `5 verified, 1 error` | Gate not entered. |
| [010](case_010_in_place_chain_reversal/REPORT.md) | 17 resolution/type errors | Gate not entered. |
| [011](case_011_queue_extension/REPORT.md) | `6 verified, 0 errors` | Full normalized queue transition agrees, with a disclosed source-audit bridge. |
| [012](case_012_majority_candidate/REPORT.md) | `7 verified, 0 errors` | Proved equal with a true promise; concrete raw-output counterexample when false. |
| [013](case_013_undo_log_recovery/REPORT.md) | `6 verified, 2 errors` | Gate not entered. |
| [014](case_014_distinct_window/REPORT.md) | `4 verified, 0 errors` | Maximum length proved equal; ghost endpoints require a unique maximizer. |
| [015](case_015_parent_propagation/REPORT.md) | `4 verified, 0 errors` | Full abstract heap effect agrees, with a disclosed inspected-body bridge. |

The findings-first account and exact evidence boundaries are in
[`EXTENSION_RESULTS.md`](EXTENSION_RESULTS.md).

## Reproduce

On a glibc-based Linux x86-64 system compatible with the official Ubuntu 20.04
package, the following command downloads and verifies Dafny 4.3.0, checks out
the exact DafnyBench commit, and reproduces all 15 cases:

```bash
./reproduce.sh
```

Cases 002, 009, 010, and 013 are recorded verifier/resolution failures; the
script checks that each failure is reproduced instead of repairing or silently
dropping it. Detailed requirements, per-case commands, offline overrides, and
the archived ID771 option are in [`REPRODUCING.md`](REPRODUCING.md). Each
run's logs are written under an ignored timestamped directory in
`.repro/runs/`.

## Evidence boundaries

- Cases 004 and 005 contain general, unbounded Dafny relational proofs.
- Cases 001 and 003 contain verified precondition/contract harnesses and
  executable counterexamples. Broader implementation-strategy statements are
  explicitly identified as conclusions from code inspection.
- Name masking reduces obvious benchmark fingerprints but cannot prove that
  related material was absent from model training.
- The five tasks, one model, one sample per task, and the post-generation ID771
  replacement make this a mechanism-discovery pilot, not a pass-rate estimate.
- The extension was prospectively frozen, but ten tasks and one sample per task
  are still too small to support broad model-performance claims. Its raw counts
  are reported with the protocol-deviating Case 006 separated.
- Complete Codex JSONL logs are retained locally but not published because they
  contain platform instructions, encrypted reasoning, local paths, and later
  analysis turns. Public hashes anchor those logs for possible controlled
  audit, but a hash alone cannot independently prove the zero-call claim.
- The inter-agent task payload is encrypted in those logs. `PROMPT.md` is the
  recorded prompt artifact, but this public repository alone cannot
  independently prove byte-for-byte equality with that encrypted envelope.

## Repository layout

- `SHORTLIST.md`: immutable advisor-facing shortlist and pre-generation status
  snapshot; later outcomes are in `EXTENSION_RESULTS.md`
- `case_001_*` through `case_005_*`: five active pilot cases
- `case_006_*` through `case_015_*`: ten prospectively frozen extension cases
- `archive/`: disclosed, excluded pilot material
- `input_masked.dfy`: exact source skeleton exposed for generation
- `PROMPT.md`: recorded generation instruction and source
- `generated_attempt_01.dfy`: saved first generated program
- `verification.txt`: historical environment and verifier record
- `REPORT.md`: generation outcome and, after the verifier gate, comparison
- `comparison_harness.dfy`: relational proof or executable counterexample
- `provenance/`: separate pilot and extension manifests, immutable freeze
  checksums, and public result-artifact integrity anchors
