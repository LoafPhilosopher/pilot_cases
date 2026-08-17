# Relation to DafnyBench and Vericoding

This note answers four questions about how this 15-case study relates to
DafnyBench and the later Vericoding benchmark without presenting a new
benchmark or comparing model performance.

## What DafnyBench originally evaluates

DafnyBench was designed primarily as a proof-hint completion task, pairing each
original `ground_truth` program with a `hints_removed` version. The executable
program remains in place while `assert` statements and loop `invariant`
annotations are removed. A model is asked to restore enough of those
annotations for Dafny to verify the file. The paper describes 782
standalone programs selected after deduplication and Dafny verification
([DafnyBench, Sections 3.1–3.2](https://arxiv.org/pdf/2406.08467#page=3)).

The public evaluator treats a task as successful when Dafny reports no errors,
the original `requires` and `ensures` clauses are preserved, and two specified
verification bypasses are absent. These checks can be seen directly in the
[pinned evaluation code](https://github.com/sun-wendy/DafnyBench/blob/0cd28feed9cd0179b07fdb9d002f8c39063658e4/eval/utils.py#L125-L155).
The reported experiments measure how often models meet this gate, including
retries that receive verifier feedback, and relate success to program length
and the amount of missing proof annotation
([DafnyBench, Section 4](https://arxiv.org/pdf/2406.08467#page=5)). DafnyBench
therefore evaluates assistance with formal verification of an existing
implementation. It does not ordinarily ask a model to synthesize a hidden
method body from its contract.

## Does it establish that the specification is correct?

No automatic verifier can establish that a contract captures an unstated
human intention. Dafny verification establishes that the program satisfies the
formal contract supplied to it. DafnyBench additionally checked that collected
source programs already verified and contained postconditions and proof hints.
Those filters establish useful internal consistency, but they do not show that
each postcondition is complete or faithful to the original programmer's
intent.

The DafnyBench paper states this limit explicitly: it does not evaluate the
translation of natural-language intent into formal specifications
([Section 5.2](https://arxiv.org/pdf/2406.08467#page=7)). Appendix C discusses
positive and negative tests as a possible way to assess generated
specifications, while also noting that the tests must themselves correctly
represent the intended behavior
([Appendix C](https://arxiv.org/pdf/2406.08467#page=15)). Thus, specification
quality is recognized as an open problem rather than established for every
DafnyBench task.

The later *A benchmark for vericoding: formally verified program synthesis* is
closer to code-from-specification generation: it removes the main
implementation and proofs, then asks a model to generate both. It also examines
specification quality more directly. The authors use an LLM-based comparison
and a random manual inspection of successful outputs, finding examples of weak
or mistranslated specifications
([Vericoding, Sections 3.2–4](https://arxiv.org/pdf/2509.22908#page=5)). The
[released inspection summary](https://github.com/Beneficial-AI-Foundation/vericoding-benchmark/blob/387cd69996792d452ead7b0460f36ee4c5cdd148/inspection/ANALYSIS.md#L3-L51)
records categories including weak specifications, implementation details
leaked into specifications, and mistranslations. This is sampled evidence
about specification quality, not a formal proof that every specification
expresses the intended task.

## Does verifier success establish equality with a reference?

DafnyBench does not use candidate-versus-reference behavioral equivalence as a
separate success condition. In its intended hint-completion task, the original
executable body is already present, so reconstructing a different algorithm is
not the main question. Its evaluator invokes Dafny and applies the contract and
bypass checks described above. It does not run a relational comparison between
an independently synthesized body and the original body.

The Vericoding benchmark does synthesize implementations, but its benchmark
counts a result as successful after its generated blocks pass validation
checks and the language verifier
([Vericoding, Section 4](https://arxiv.org/pdf/2509.22908#page=6)). Its
specification inspection is a sample-level audit, not a reference-equivalence
check for every verifier-passing program. Consequently, a verifier pass in
either setting should be read as “satisfies the supplied formal obligations,”
not automatically as “has every behavior of a particular reference
implementation.”

## What this case study adds

This repository withholds each selected method body and gives the model a
method header, its formal contract, and the local definitions needed for
verification. After a candidate passes Dafny, the study separately compares it
with the hidden reference under a stated observation relation. The evidence is
reported as a general relation, a concrete counterexample, or equality only
under an additional condition.

Across the 15 cases, including the first passing repair for each of the four
initial failures, 7 candidates are equivalent under the comparison used here,
5 have concrete behavioral counterexamples, and 3 are equivalent only under an
additional condition. Cases 007, 011, and 015 combine a machine-checked
abstract relation with a disclosed source-audited bridge. They are not single
end-to-end automatic relational proofs.

These results add per-case evidence about a question that verifier success by
itself does not answer: whether the supplied specification forces a generated
program to reproduce the chosen reference's observable behavior. A reported
specification gap is therefore relative to that reference and observation. It
does not prove that the reference is the only acceptable implementation, that
the formal contract is wrong in an absolute sense, or that a differing program
violates the written contract. The study complements DafnyBench's
hint-completion evaluation and Vericoding's sampled specification audit. Its
small, selected set is not a leaderboard or a model-performance estimate.

## Primary sources

- [DafnyBench: A Benchmark for Formal Software Verification](https://arxiv.org/abs/2406.08467)
- [DafnyBench repository at the revision used in this study](https://github.com/sun-wendy/DafnyBench/tree/0cd28feed9cd0179b07fdb9d002f8c39063658e4)
- [A benchmark for vericoding: formally verified program synthesis](https://arxiv.org/abs/2509.22908)
- [Vericoding benchmark inspection records](https://github.com/Beneficial-AI-Foundation/vericoding-benchmark/tree/387cd69996792d452ead7b0460f36ee4c5cdd148/inspection)
