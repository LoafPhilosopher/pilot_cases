# Comparing generated Dafny programs with the originals on 15 tasks

**Start with the short result summary: [`CONCLUSION.md`](CONCLUSION.md).**

For how this study differs from DafnyBench's original evaluation and the later
Vericoding benchmark, see [`RELATED_WORK.md`](RELATED_WORK.md).

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
or inspect files. We preserved the code from its first answer and checked it
with Dafny 4.3.0. If that answer passed, we compared it with the original method
using either a Dafny proof or a concrete counterexample. Where Dafny could not
connect two imperative bodies automatically, we also stated which facts came
from reading those bodies. The repository publishes code artifacts rather than
complete platform responses: each `generated_attempt_01.dfy` contains the
returned code with one trailing LF added, while full platform logs and event
records remain private. See [`provenance/README.md`](provenance/README.md).

After recording the first-attempt study, we repaired only the four programs
that had failed verification: Cases 002, 009, 010, and 013. A fresh agent saw
the current program and its Dafny feedback. Each case had a maximum of three
rounds and stopped at its first verifier-passing repair. Every input, returned
code artifact, and verifier log is saved; the original failures were not
overwritten. Only the first passing repair was compared with the reference. See
[`REPAIR_PROTOCOL.md`](REPAIR_PROTOCOL.md).

The first five tasks were an exploratory pilot. The next ten tasks were chosen
before their generations were run, with one `gpt-5.6-sol` answer per task. In
total, 11 of the 15 first attempts passed Dafny. All four later repairs reached
a verifier-passing program within the fixed budget, so all 15 cases now have a
semantic comparison. This does not change the first-attempt result.

## Results

| Case | Programming task | Generated program | Comparison with the original |
|---|---|---|---|
| [001](case_001_substring_occurrence/REPORT.md) | Find a substring and return an index | Pass | Different on failure: for `("a","b")`, the original returns `(false,1)` and the generated program returns `(false,0)`. |
| [002](case_002_local_transition_trace/REPORT.md) | Build a multi-round trace using a supplied transition function | First attempt: 2 proof errors. Repair Round 01: pass. | The repaired and original methods return the same complete trace; proved in Dafny. |
| [003](case_003_repeated_value_pair/REPORT.md) | Return two distinct values that are repeated in a sequence | Pass | Both choose valid repeated values, but their pair order and even the selected pair can differ. |
| [004](case_004_four_kind_arrangement/REPORT.md) | Arrange four kinds of datatype values in a required order | Pass | The returned sequences are equal after matching the renamed constructors; proved in Dafny. |
| [005](case_005_tree_window/REPORT.md) | Read a substring from a tree-structured string | Pass | When the two input trees represent the same string, their returned strings are equal for every permitted interval; proved in Dafny. |
| [006](case_006_entry_selection/REPORT.md) | Choose an entry with minimum frequency from a map | Pass | Both return a minimum entry. A unique minimum forces the same key; with a tie, the specification permits different keys. This run also sent an unintended progress message. |
| [007](case_007_ordered_structure_extension/REPORT.md) | Insert a value into an ordered tree | Pass | The sets of stored integers are equal. A Dafny model plus inspection of both bodies shows that these two implementations also build the same shape. |
| [008](case_008_multiplicity_expansion/REPORT.md) | Expand a map of value counts into a sequence | Pass | The result contains the same multiset, but sequence order is not fixed: `[1,2]` and `[2,1]` can both be valid. |
| [009](case_009_local_array_repair/REPORT.md) | Repair the local order of an array representation | First attempt and Repair Round 01: fail. Repair Round 02: pass. | Different: on `[7]`, the original keeps `[7]` and the repair changes it to `[0]`. |
| [010](case_010_in_place_chain_reversal/REPORT.md) | Reverse a linked chain in place | First attempt: 17 resolution/type errors. Repair Round 01: pass. | Different on a two-node chain: the original reverses links; the repair leaves links in place and exchanges node values. |
| [011](case_011_queue_extension/REPORT.md) | Append one value to a linked queue | Pass | After matching the two separately allocated new cells, the queue contents, links, and recorded ownership agree; the result combines a Dafny proof with inspection of the two bodies. |
| [012](case_012_majority_candidate/REPORT.md) | Select a majority candidate | Pass | Equal when a promised majority exists. Without that promise, `[0,1,2]` gives `2` from the original and `0` from the generated program. |
| [013](case_013_undo_log_recovery/REPORT.md) | Restore an array state from an undo log | First attempt: 2 frame errors. Repair Round 01: pass. | The recovered abstract state and complete array contents are equal; proved in Dafny. |
| [014](case_014_distinct_window/REPORT.md) | Find the maximum length of a substring with distinct characters | Pass | The returned maximum length is always equal. Dafny also proves equal ghost endpoints when the maximizing window is unique; the contracts do not settle tied windows. |
| [015](case_015_parent_propagation/REPORT.md) | Propagate a value change through a parent chain | Pass | Corresponding nodes receive the same aggregate values while links and payloads stay unchanged; the result combines a Dafny proof with inspection of both bodies. |

Using the 11 passing first attempts and the first passing repair for each of
the other four cases, 7 are equivalent under the comparison used here, 5 have
a concrete behavioral counterexample, and 3 are equal only under an additional
condition. The repaired Cases 002 and 013 are equivalent to their references;
Cases 009 and 010 reveal two further specification gaps. The short explanation
of every non-equivalent or conditional case is in
[`CONCLUSION.md`](CONCLUSION.md).

## Important limitations

This small study uses one model and one first answer per task, followed by a
separate verifier-feedback repair only for the four failures. The counts do not
estimate general model performance or repair reliability. The first five cases
were exploratory:
an earlier task, ID771, was replaced after generation because its executable
specification made the implementation too direct. That discarded run remains
in [`archive/`](archive/) and is not counted among the 15 cases.

The model was told not to use tools or the Web. Fourteen first-attempt
generations made no such call before returning code. Case 006 instead sent one
progress message to another agent; it is reported but should not be treated as
a clean isolated run. Tools were available in the environment, so this records
what was used, not a claim that tool access was technically disabled. The saved
repair records also state that those agents made no calls; the repository does
not contain platform event logs that would let an outside reader verify that
statement independently.

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

The script obtains Dafny 4.3.0 and the exact DafnyBench revision, reproduces all
15 first-attempt results, verifies the saved repair rounds, and reruns the
comparisons. See [`REPRODUCING.md`](REPRODUCING.md) for dependencies and
per-case commands.

Detailed task-selection records, prompts, raw generated programs, verifier
logs, and checksums remain in the repository. [`SHORTLIST.md`](SHORTLIST.md)
is the frozen historical researcher-selected artifact; its historical use of
“approved” does not indicate that Jocelyn approved the exact task IDs. Current
claims are governed by [`STUDY_SCOPE.md`](STUDY_SCOPE.md), and the ten-case
outcomes are in [`EXTENSION_RESULTS.md`](EXTENSION_RESULTS.md).
