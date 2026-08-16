# Ten-case extension: findings

## What was run

The ten cases below were selected and frozen before generation at Git commit
`8b6218c8cc8d235adf24f3c9832a4d70de302983`. Each received exactly one
`gpt-5.6-sol` first attempt at `ultra` reasoning effort. No verifier-driven
retry, repair, replacement, or extra generation was made.

This extension operationalizes the advisor-guided 10–20-task direction, but
is reported as exploratory evidence rather than an advisor-approved benchmark
or a model-performance evaluation.

The raw denominators are:

- **10 first attempts**;
- **7 verifier-pass attempts**, all seven taken through the comparison gate;
- **3 verifier/resolution failures**, stopped at the gate; and
- **9 protocol-conforming attempts**, of which **6 passed verification**.

The remaining attempt, Case 006, verifies but is reported separately because
the generation agent made one prohibited outbound progress call before its
final code response. The attempt and message were retained rather than
replaced. The logs record no Web search, network-interface use, filesystem
call, or reference-body retrieval in any of the ten generations. This is an
actual-use statement, not a claim that those capabilities were absent.

## Results

| Case | Frozen task | First-attempt result | Finding after the verifier gate |
|---|---|---|---|
| [006](case_006_entry_selection/REPORT.md) | ID010, select a minimum map entry | `3 verified, 0 errors`; **protocol deviation** | Both calls always return a global minimum; raw keys are proved equal when the minimum is unique, while a two-key tie admits distinct valid keys. Combined proof: `15 verified, 0 errors`. Excluded from conforming counts. |
| [007](case_007_ordered_structure_extension/REPORT.md) | ID107, extend an ordered recursive structure | `11 verified, 0 errors` | Actual calls have equal abstract value sets. Raw shape agrees through a machine-proved executable projection whose transcription from the two bodies is separately source-audited; the contract alone permits other shapes. Combined proof: `38 verified, 0 errors`. |
| [008](case_008_multiplicity_expansion/REPORT.md) | ID119, expand map multiplicities into a sequence | `4 verified, 0 errors` | Returned multisets are proved equal for all inputs, but raw order is not fixed: `[1,2]` and `[2,1]` both meet the full contract for the same map. Combined proof: `37 verified, 0 errors`. |
| [009](case_009_local_array_repair/REPORT.md) | ID288, repair an array representation | `5 verified, 1 error` | **Gate not entered.** The candidate tried to zero the full array, but failed an array-element modifies obligation. |
| [010](case_010_in_place_chain_reversal/REPORT.md) | ID308, transform a linked chain | 17 resolution/type errors | **Gate not entered.** The candidate used the nonexistent sequence member `.Length`; no repair was requested. |
| [011](case_011_queue_extension/REPORT.md) | ID309, append to a heap queue | `6 verified, 0 errors` | The two retained bodies have the same normalized full queue transition, including old identities, one fresh-cell bijection, links, values, suffixes, and ownership. Combined proof: `35 verified, 0 errors`; extraction of the normalized transition is explicitly source-audited. |
| [012](case_012_majority_candidate/REPORT.md) | ID313, select a candidate | `7 verified, 0 errors` | With the promise true, both returns are proved equal to the designated majority. With it false, `[0,1,2]` is a concrete counterexample: generated returns `0`, reference returns `2`. Combined proof: `28 verified, 0 errors`; runtime harness: `5 verified, 0 errors`. |
| [013](case_013_undo_log_recovery/REPORT.md) | ID327, restore state from an undo log | `6 verified, 2 errors` | **Gate not entered.** The inferred reverse-log algorithm failed two array-frame obligations. |
| [014](case_014_distinct_window/REPORT.md) | ID417, maximum distinct-character window | `4 verified, 0 errors` | The executable maximum length is proved equal for every string. Ghost endpoints are proved equal under a unique-maximizer condition; ties are contractually free. Combined proof including both sources: `13 verified, 0 errors`. |
| [015](case_015_parent_propagation/REPORT.md) | ID482, propagate an aggregate along parents | `4 verified, 0 errors` | Loop and recursion have the same full abstract heap effect under the frozen bijection. The path/effect relation is machine checked; the bridge from each body to that exact effect is disclosed as line-by-line source inspection. Combined proof including both sources: `34 verified, 0 errors`. |

## What these cases add

The extension reinforces the pilot's central distinction: verifier success
shows satisfaction of the supplied contract, not automatic equality of every
observable result. Case 012 gives an actual output counterexample; Cases 006
and 008 expose tie/order freedom; Case 014 separates a unique executable result
from a non-unique ghost witness. Conversely, Cases 007, 011, and 015 show that
two materially different proof or control-flow organizations can still realize
the same frozen observation.

The three failures are retained as outcomes rather than repaired away. Two are
heap-frame failures after the model inferred a plausible algorithm, and one is
a Dafny syntax/type error. With only ten tasks and one sample per task, these
counts are descriptive evidence for this frozen set, not an estimate of broad
model performance.

## Evidence boundary

The individual reports distinguish three evidence forms:

- direct relational proofs over actual calls, often using contract uniqueness;
- executable counterexamples or contract-level divergence witnesses; and
- normalized transition/effect theorems whose mapping to imperative body
  statements is separately source-audited.

The last form is not described as an end-to-end automatic relational proof.
Complete internal generation logs are retained locally but are not published;
the public provenance manifests record response and log hashes, settings,
call counts, and the limits of independent audit.

A post-run audit of those retained logs found an additional masking limitation.
Platform `world_state` metadata contained historical command/file names, and
the contexts for Cases 006, 007, and 012 exposed their corresponding identifying
filename terms `LFUSimple.dfy`, `BST.dfy`, and `MajorityVote.dfy`. No reference
body was present in that metadata, and none of the three agents read a file or
used Web/network access. Their generated and equivalence results remain valid
as recorded, but these cases are filename-mask-confounded and cannot support a
clean claim that neutralized prompt names removed benchmark-recognition cues.
This is separate from the outbound-call violation in Case 006.

Case 013 uses a pregeneration-normalized specification variant and is reported
as a distinct input condition, not as a direct original-specification case. It
uses the pre-frozen denotational ghost-state normalization described in its
pre-generation record rather than exposing the source's executable transition
helper. Case 014 is intentionally a recognizable-problem contamination stress
case. These boundaries should accompany any advisor-facing interpretation of
the ten-case table.
