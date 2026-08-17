# Study scope and interpretation

This repository studies whether Dafny programs generated from masked, frozen
specifications that pass verification also agree with hidden reference
implementations under explicitly stated observation relations.

The study follows advisor guidance to:

- use DafnyBench as a source of tasks, rather than create or modify a benchmark;
- examine 10–20 non-trivial programming tasks;
- select tasks for programming difficulty and diversity; and
- interpret results cautiously in light of identifier masking and possible
  training-data exposure.

The five-case set is an exploratory pilot. Cases 006–015 are a separately
prospectively frozen exploratory extension selected by the researcher before
generation. This repository does not claim advisor approval of each exact task
ID or make a broad model-performance claim.

`SHORTLIST.md` and `EXTENSION_PROTOCOL.md` are preserved historical
pre-generation artifacts. Current scope and interpretation are stated in this
file.

## Research question

This preliminary study asks two questions about non-trivial DafnyBench tasks:

1. Can a Coding Agent generate a method body and proof annotations from a
   method header, its specification, and necessary local context while the
   reference body is withheld?
2. When a first generated program—or, in the follow-up repair study, the first
   verifier-passing repair—passes Dafny, is it behaviorally equivalent to the
   hidden reference, and under what observation or additional condition?

The 15 tasks were selected for programming and verification difficulty, not
classified in advance as having “strong” or “weak” specifications. Name masking
was intended only to reduce obvious benchmark fingerprints; it cannot establish
that a model had never encountered related material during training.

## Study structure

This is a **15-task preliminary experiment drawn from DafnyBench**: five earlier
feasibility cases and a prospectively frozen ten-case extension. It is not a new
benchmark, a derived DafnyBench track, or a modification of DafnyBench's official
evaluation. The pilot and extension remain separate because the five-case pilot
was not preregistered and included one disclosed post-generation replacement.

Each task has one preserved first response. There were no verifier-driven
repairs, retries, or replacements during the original ten-case extension. A
later follow-up repaired only the four failed first attempts (002, 009, 010,
and 013) under a fixed three-round budget. Repair stopped at the first passing
program; every failed round was retained, and only that first passing repair
entered reference comparison.

## Exact outcome counts

| Set | First attempts | Verifier-pass | Comparison entries | Strict zero-call attempts |
|---|---:|---:|---:|---:|
| Five-case pilot | 5 | 4 | 4 | 5 |
| Ten-case extension | 10 | 7 | 7 | 9 |
| Combined descriptive total | 15 | 11 | 11 | 14 |

These are still the first-attempt counts. In the later follow-up, all four
failed cases produced a verifier-passing repair: three in Round 01 and Case 009
in Round 02. The final case-level comparison therefore covers all 15 tasks: 7
equivalent under the stated comparison, 5 with concrete behavioral
counterexamples, and 3 equivalent only under an additional condition.

Case 006 passed verification and was compared, but it made one prohibited
outbound progress call before returning code. It is retained as a
protocol-deviating attempt and excluded from the extension's strict zero-call
denominator. All ten extension logs record zero Web, network, filesystem,
function-tool, and custom-tool calls; the environment exposed tool interfaces,
so this is a zero-actual-use result rather than capability-level isolation.

## How to read the equivalence findings

The reports distinguish four evidence situations rather than answering only
“yes” or “no”:

- a general relational or uniqueness proof for the stated observation;
- a concrete counterexample or a proved contract-level divergence witness;
- a mixed result in which an unbounded relation is machine checked but its
  connection to imperative source bodies is separately inspected; or
- no equivalence classification if a repair budget is exhausted without a
  verifier-passing candidate. No case had this outcome in the recorded repair
  study.

Cases 007, 011, and 015 use the third form. Their reports do not constitute a
single end-to-end automatic proof of every claimed concrete effect. No bounded
test is presented as a proof.

## Masking and contamination limitations

The recorded prompts omit the reference bodies, original paths, examples,
source comments, and original target names. However, a post-run audit found that
platform-provided `world_state` metadata contained historical command/file
names. In particular, the generation contexts for Cases 006, 007, and 012
exposed their corresponding identifying filename terms `LFUSimple.dfy`,
`BST.dfy`, and `MajorityVote.dfy` before the final responses.

Those metadata did **not** contain the reference method bodies, and the agents
made no filesystem or Web calls to retrieve them. Nevertheless, the three cases
are filename-mask-confounded and must not be used as clean evidence that neutral
prompt names removed benchmark-recognition cues. This limitation is separate
from Case 006's outbound-call deviation. The other seven extension cases had no
exact target filename identified in this audit, but masking still cannot rule
out training-data exposure.

Two additional task-specific boundaries should remain visible: Case 013 uses a
pre-frozen, denotationally specified ghost-state normalization instead of the
source's executable transition helper, and Case 014 deliberately retains a
recognizable maximum-distinct-window specification as a contamination stress
case.

## Appropriate claim

The supported conclusion is limited to the retained first attempts and the
separately recorded repairs of the four failures. Verifier success alone did
not guarantee equality of every observable output, while several
implementations were equivalent under a stated relation or additional
uniqueness condition. The sample is too small and uses one model, one first
attempt per task, and repair only after failure; it does not estimate broad
model performance or establish contamination-free code generation.

For the compact final table, see [`CONCLUSION.md`](CONCLUSION.md). The frozen
selection record and original procedure remain in [`SHORTLIST.md`](SHORTLIST.md)
and [`EXTENSION_PROTOCOL.md`](EXTENSION_PROTOCOL.md); the follow-up repair rule
is in [`REPAIR_PROTOCOL.md`](REPAIR_PROTOCOL.md).
