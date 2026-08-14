# Five-case preliminary feasibility pilot: generated Dafny programs and hidden references

## Status

This repository contains a technically checked **five-case preliminary
feasibility pilot**. It is not the requested 10–20-task study, a new benchmark,
or a modification of DafnyBench's official evaluation, and it should not be
presented as completion of Jocelyn's current request.

The next advisor-facing artifact is [`SHORTLIST.md`](SHORTLIST.md): 15
DafnyBench candidates with short, source-based reasons for their programming
difficulty. Five are the already-run pilot cases and ten are proposed
extensions. No generation has been run on those ten candidates; they should be
reviewed and frozen before any further experiment.

The active five-case set was not preregistered. An initial ID771 run was
replaced after its executable specification made synthesis too direct. That
run remains visible in [`archive/id771_segmented_weighted_sum/`](archive/id771_segmented_weighted_sum/),
but it is not counted as an active sixth case. This post-generation replacement
means the pilot must not be used for aggregate performance claims.

## What the pilot examined

Each case asks what can be concluded about behavioral equivalence when a
Coding Agent sees a method interface, contract, and necessary context, but not
the benchmark's reference body. The five active tasks cover nested search,
higher-order trace construction, witness selection, datatype arrangement, and
interval extraction over a heap-allocated tree. They were chosen for
programming non-triviality and mechanism diversity, not for simple outputs or
pre-labelled “strong/weak” specifications.

## Procedure actually used

For each active task:

1. The implementation at pinned DafnyBench commit
   `0cd28feed9cd0179b07fdb9d002f8c39063658e4` was retained as a hidden
   reference.
2. The reference body, examples, source-identifying comments, sibling
   solutions, and algorithm-revealing names were removed. The model received
   the neutrally renamed target header, its original contract, and the minimum
   definitions needed to understand and verify it.
3. One isolated `gpt-5.6-sol` generation was instructed not to browse or search
   the Web, call tools, inspect the filesystem, contact other agents, or access
   the hidden reference.
4. The first response was preserved without repair and checked with Dafny
   4.3.0.
5. Only a verifier-pass candidate entered equivalence analysis. The comparison
   used a concrete counterexample or a machine-checked relational theorem and
   stated the relevant observation relation.

Across the active set there were **5 generation attempts; equivalence analysis
was performed for the 4 verifier-pass attempts.** The remaining attempt is
retained as a verifier-fail result, not treated as an equivalence case.

The prompt-level prohibition was audited against the locally retained
structured logs: there were zero tool, Web, filesystem, or outbound-agent
calls before the first saved response in each active case. Tools existed in the
execution environment, so this is evidence of zero actual use, not
capability-level removal. See [`provenance/manifest.json`](provenance/manifest.json)
for model settings, generation-artifact hashes, raw-response hashes, and
limitations.

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

## Reproduce

On a glibc-based Linux x86-64 system compatible with the official Ubuntu 20.04
package, the following command downloads and verifies Dafny 4.3.0, checks out
the exact DafnyBench commit, and reproduces all five active cases:

```bash
./reproduce.sh
```

Case 002 is expected to report `3 verified, 2 errors`; the script checks that
this recorded failure is reproduced rather than treating it as a script
failure. Detailed requirements, per-case commands, offline overrides, and the
archived ID771 option are in [`REPRODUCING.md`](REPRODUCING.md). Each run's
logs are written under an ignored timestamped directory in `.repro/runs/`.

## Evidence boundaries

- Cases 004 and 005 contain general, unbounded Dafny relational proofs.
- Cases 001 and 003 contain verified precondition/contract harnesses and
  executable counterexamples. Broader implementation-strategy statements are
  explicitly identified as conclusions from code inspection.
- Name masking reduces obvious benchmark fingerprints but cannot prove that
  related material was absent from model training.
- The five tasks, one model, one sample per task, and the post-generation ID771
  replacement make this a mechanism-discovery pilot, not a pass-rate estimate.
- Complete Codex JSONL logs are retained locally but not published because they
  contain platform instructions, encrypted reasoning, local paths, and later
  analysis turns. Public hashes anchor those logs for possible controlled
  audit, but a hash alone cannot independently prove the zero-call claim.
- The inter-agent task payload is encrypted in those logs. `PROMPT.md` is the
  recorded prompt artifact, but this public repository alone cannot
  independently prove byte-for-byte equality with that encrypted envelope.

## Repository layout

- `SHORTLIST.md`: advisor-facing 15-task candidate list; ten candidates remain
  unrun
- `case_001_*` through `case_005_*`: five active pilot cases
- `archive/`: disclosed, excluded pilot material
- `input_masked.dfy`: exact source skeleton exposed for generation
- `PROMPT.md`: recorded generation instruction and source
- `generated_attempt_01.dfy`: saved first generated program
- `verification.txt`: historical environment and verifier record
- `REPORT.md`: generation outcome and, after the verifier gate, comparison
- `comparison_harness.dfy`: relational proof or executable counterexample
- `provenance/manifest.json` and `provenance/SHA256SUMS`: generation metadata
  and integrity anchors
