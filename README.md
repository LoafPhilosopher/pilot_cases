# Comparing generated Dafny programs with the originals on 15 tasks

This repository contains a preliminary study of 15 non-trivial programs from
DafnyBench. It asks two questions: can a coding model implement a method from
its Dafny specification, and, when the generated program verifies, does it do
the same thing as the original program?

This is a collection of case studies, not a new benchmark or a model
leaderboard. Each linked report below explains its problem and result without
requiring the reader to open the Dafny source files.

## How the study was run

For each task, the original method body was withheld. The model saw a neutrally
renamed method header, its preconditions and postconditions, and the definitions
needed to verify a new body. It was instructed not to browse the Web, use tools,
or inspect files. We saved its first answer without repairing it and checked it
with Dafny 4.3.0. If that answer passed, we then compared it with the original
method using a Dafny proof, a concrete counterexample, and, where Dafny could
not connect two imperative bodies automatically, a stated inspection of those
bodies.

The first five tasks were an exploratory pilot. The next ten tasks were chosen
before their generations were run, with one `gpt-5.6-sol` answer per task. In
total, 11 of the 15 generated programs passed Dafny; the other four are kept as
failures and were not compared semantically.

## Results

| Case | Programming task | Generated program | Comparison with the original |
|---|---|---|---|
| [001](case_001_substring_occurrence/REPORT.md) | Find a substring and return an index | Pass | Different on failure: for `("a","b")`, the original returns `(false,1)` and the generated program returns `(false,0)`. |
| [002](case_002_local_transition_trace/REPORT.md) | Build a multi-round trace using a supplied transition function | Fail: 2 proof errors | Not compared. |
| [003](case_003_repeated_value_pair/REPORT.md) | Return two distinct values that are repeated in a sequence | Pass | Both choose valid repeated values, but their pair order and even the selected pair can differ. |
| [004](case_004_four_kind_arrangement/REPORT.md) | Arrange four kinds of datatype values in a required order | Pass | The returned sequences are equal after matching the renamed constructors; proved in Dafny. |
| [005](case_005_tree_window/REPORT.md) | Read a substring from a tree-structured string | Pass | When the two input trees represent the same string, their returned strings are equal for every permitted interval; proved in Dafny. |
| [006](case_006_entry_selection/REPORT.md) | Choose an entry with minimum frequency from a map | Pass | Both return a minimum entry. A unique minimum forces the same key; with a tie, the specification permits different keys. This run also sent an unintended progress message. |
| [007](case_007_ordered_structure_extension/REPORT.md) | Insert a value into an ordered tree | Pass | The sets of stored integers are equal. A Dafny model plus inspection of both bodies shows that these two implementations also build the same shape. |
| [008](case_008_multiplicity_expansion/REPORT.md) | Expand a map of value counts into a sequence | Pass | The result contains the same multiset, but sequence order is not fixed: `[1,2]` and `[2,1]` can both be valid. |
| [009](case_009_local_array_repair/REPORT.md) | Repair the local order of an array representation | Fail: 1 frame error | Not compared. |
| [010](case_010_in_place_chain_reversal/REPORT.md) | Reverse a linked chain in place | Fail: 17 resolution/type errors | Not compared. |
| [011](case_011_queue_extension/REPORT.md) | Append one value to a linked queue | Pass | After matching the two separately allocated new cells, the queue contents, links, and recorded ownership agree; the result combines a Dafny proof with inspection of the two bodies. |
| [012](case_012_majority_candidate/REPORT.md) | Select a majority candidate | Pass | Equal when a promised majority exists. Without that promise, `[0,1,2]` gives `2` from the original and `0` from the generated program. |
| [013](case_013_undo_log_recovery/REPORT.md) | Restore an array state from an undo log | Fail: 2 frame errors | Not compared. |
| [014](case_014_distinct_window/REPORT.md) | Find the maximum length of a substring with distinct characters | Pass | The returned maximum length is always equal. Dafny also proves equal ghost endpoints when the maximizing window is unique; the contracts do not settle tied windows. |
| [015](case_015_parent_propagation/REPORT.md) | Propagate a value change through a parent chain | Pass | Corresponding nodes receive the same aggregate values while links and payloads stay unchanged; the result combines a Dafny proof with inspection of both bodies. |

The main result is straightforward: passing the same Dafny specification does
not by itself guarantee identical return values. Cases 001, 003, and 012 give
inputs on which the two saved programs return different values. In Case 008,
the specification and nondeterministic key selection permit different output
orders; Cases 006 and 014 likewise expose choices when several answers tie.
Conversely, Cases 004 and 005 prove equality under the input correspondence
stated in their reports. Cases 007, 011, and 015 show matching outputs or
state, with the manual inspection steps stated in each report.

## Important limitations

This small study uses one model and one answer per task, so the counts above do
not estimate general model performance. The first five cases were exploratory:
an earlier task, ID771, was replaced after generation because its executable
specification made the implementation too direct. That discarded run remains
in [`archive/`](archive/) and is not counted among the 15 cases.

The model was told not to use tools or the Web. Fourteen generations made no
such call before returning code. Case 006 instead sent one progress message to
another agent; it is reported but should not be treated as a clean isolated
run. Tools were available in the environment, so this records what was used,
not a claim that tool access was technically disabled.

Neutral names also cannot prove that a task was absent from model training. A
later inspection found that platform metadata showed the source filenames
`LFUSimple.dfy`, `BST.dfy`, and `MajorityVote.dfy` during Cases 006, 007, and
012. It did not expose the method bodies, and the model did not read those
files, but these three cases do not test whether renaming alone prevented task
recognition.

## Reproduce the results

On a glibc-based Linux x86-64 system, run:

```bash
./reproduce.sh
```

The script obtains Dafny 4.3.0 and the exact DafnyBench revision, verifies the
15 saved answers, reruns the comparisons, and checks that the four failed
answers still fail in the recorded way. See [`REPRODUCING.md`](REPRODUCING.md)
for dependencies and per-case commands.

Detailed task-selection records, prompts, raw generated programs, verifier
logs, and checksums remain in the repository. The concise scope statement is
in [`STUDY_SCOPE.md`](STUDY_SCOPE.md); the ten-case selection and its complete
result table are in [`SHORTLIST.md`](SHORTLIST.md) and
[`EXTENSION_RESULTS.md`](EXTENSION_RESULTS.md).
