# Five-case exploratory study: generated Dafny programs and hidden references

## Scope

This is a small exploratory case study, not a new benchmark or a modification
of DafnyBench's official evaluation. It asks what can be concluded about
behavioral equivalence when a Coding Agent sees a method interface and formal
specification, but not the benchmark's reference body, and generates a program
that is then checked by Dafny.

Five programming-nontrivial DafnyBench tasks were selected by hand. The set
includes witness-returning contracts, nested sequence construction, datatype
arrangement, and interval extraction over a heap-allocated tree; it was not
selected for simple outputs or pre-labelled strong/weak specifications.

## Lightweight protocol

For each task:

1. Preserve the pinned DafnyBench implementation as the hidden reference.
2. Remove the reference body, examples, source-identifying comments, and
   algorithm-revealing names. Keep the method header, contract, and the minimum
   definitions needed to understand and verify it.
3. Give that source to one isolated `gpt-5.6-sol` Coding Agent, explicitly
   prohibit Web/network, tool, filesystem, other-agent, and reference use, and
   audit the generation log for calls. The hidden reference is not placed in
   the generation context.
4. Preserve the first raw generation without repair and verify it with Dafny
   4.3.0.
5. Only for verifier-pass attempts, compare the generated and reference
   programs using a concrete counterexample or a machine-checked relational
   theorem, and state the observation relation precisely.

Environment:

- DafnyBench commit: `0cd28feed9cd0179b07fdb9d002f8c39063658e4`
- Dafny: `4.3.0`
- Generation attempts: one per task
- Experimental count across the five active cases: **5 generation attempts;
  equivalence analysis was performed for the 4 verifier-pass attempts.** The
  remaining attempt is kept as a verifier-fail generation result, not as an
  equivalence case. These five hand-selected observations are not treated as a
  statistical pass-rate estimate.
- Generation-log audit: zero Web/network, tool, filesystem, or outbound-agent
  calls before the saved response for every active case
- Forbidden-feature scan: no `assume`, `{:verify false}`, `{:axiom}`,
  `{:extern}`, `decreases *`, or generated `print` in any attempt

The status descriptions below summarize evidence in this pilot; they are not a
new official benchmark label scheme.

## Results

| Case | DafnyBench task | First generation | Equivalence result |
|---|---|---|---|
| [001](case_001_substring_occurrence/REPORT.md) | ID004, substring occurrence witness | `3 verified, 0 errors` | **Concrete counterexample to raw tuple equality.** On `("a","b")`, reference returns `(false,1)` and generated returns `(false,0)`. They agree if the failure index is unobservable; by code inspection they also agree on success. |
| [002](case_002_local_transition_trace/REPORT.md) | ID117, higher-order local transition trace | `3 verified, 2 errors` | **Verifier-fail; comparison gate not entered.** The untouched attempt has two index-safety proof failures in a sequence-constructor helper. |
| [003](case_003_repeated_value_pair/REPORT.md) | ID311, select two repeated values | `18 verified, 0 errors` | **Concrete counterexamples.** `[0,1,1,0]` reverses pair order; `[0,1,2,2,1,0]` makes the implementations choose different two-value subsets. Both outputs satisfy the contract. Raw pairs agree exactly when the first two values selected by first-occurrence and second-occurrence order coincide in the same order; with exactly two duplicate values, their unordered witness sets agree. |
| [004](case_004_four_kind_arrangement/REPORT.md) | ID690, arrange four datatype constructors | `18 verified, 0 errors` | **Machine-proved equivalent modulo the intentional constructor renaming.** `ValidArrangement` plus multiset preservation uniquely determines the result; combined harness: `49 verified, 0 errors`. |
| [005](case_005_tree_window/REPORT.md) | ID491, interval extraction from a tree-structured string | `3 verified, 0 errors` | **Machine-proved output-equivalent under equal abstract string models.** The returned strings are equal for every shared permitted interval; combined harness: `26 verified, 0 errors`. |

## Main observations

1. **Verifier success establishes contract conformance, not automatically full
   reference equality.** Cases 001 and 003 pass the same semantic requirements
   as their references yet return observably different raw values.
2. **The relevant question is which observations the contract determines.**
   In case 001 the failure index is open. In case 003 witness choice and order
   are open. In case 005 the exact returned string is fixed by the abstract
   input model and interval.
3. **Very different algorithms can still be proved equivalent.** Case 004's
   reference uses a four-region partition, while the generation uses functional
   insertion sort. Case 005 independently reconstructs the reference's
   tree-decomposition semantics, including one-sided and cross-split intervals.
4. **A failed proof attempt is informative and must remain visible.** Case 002
   generated the intended recurrence but did not discharge two array-index
   obligations; it was not repaired or removed from the denominator.

## Evidence boundaries

- Cases 004 and 005 contain general, unbounded Dafny relational proofs.
- Cases 001 and 003 contain verified precondition/contract harnesses plus
  executable concrete counterexamples. Their exact printed return values are
  runtime observations; broader implementation-strategy statements are marked
  as code-inspection conclusions in their reports.
- Name masking reduces obvious benchmark fingerprints but does not prove that
  the model never encountered related material during training.
- This study uses one model, one sample per task, and five hand-selected tasks.
  It is evidence for interesting mechanisms, not a statistical estimate of
  model or benchmark-wide behavior.
- The earlier ID771 segmented-sum candidate is retained under
  `case_005_segmented_weighted_sum/` as a superseded audit record. It is not
  counted as an active sixth case because its executable specification function
  made the target implementation too direct.

## Files in each case

- `input_masked.dfy`: exact source skeleton exposed for generation
- `PROMPT.md`: exact generation instruction and source
- `generated_attempt_01.dfy`: untouched first generated program
- `verification.txt`: model/environment metadata and concise verifier records
- `REPORT.md`: case-specific generation outcome and, after the verifier gate,
  equivalence analysis
- `comparison_harness.dfy`: relational proof or executable counterexample,
  when the generated attempt passed verification
