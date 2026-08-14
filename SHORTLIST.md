# Candidate shortlist for the next Dafny study

## Purpose and timing

This is a 15-task candidate list drawn from DafnyBench commit
`0cd28feed9cd0179b07fdb9d002f8c39063658e4`. It is the next item to send for
advisor review; it is not a new benchmark or a modification of DafnyBench.
It was prepared on 2026-08-14, after the five-case feasibility pilot.

The five entries marked **existing pilot** had already been run when this
shortlist was written. This document therefore does not claim to have
preregistered those runs. The other ten entries are **proposed and unrun**:
no generation experiment has been performed on them, and none should be run
until the final subset and run conditions have been reviewed and frozen.

Paths below are relative to the upstream DafnyBench repository. The standalone
reproduction checkout places that repository at `third_party/DafnyBench/`.
For each proposed task, every visible class, datatype, field, predicate,
function, lemma, and method name will receive a frozen neutral alias where
needed; “keep” below means retain the definition or contract under those
aliases, not retain an identifying declaration name.

Candidates were selected from source-visible properties available before a
model response: programming difficulty, non-trivial control flow or recursion,
mutation and framing obligations, proof complexity, data-structure diversity,
and the feasibility of presenting a self-contained body hole. They were not
selected or divided using “strong/weak specification” labels.
As a source-level eligibility check, all ten proposed ground-truth files were
verified locally with Dafny 4.3.0 and reported zero errors; no model generation
was run for that check.

## Candidates

### 1. ID004 — substring-occurrence witness

- **Status:** existing pilot
- **Ground truth:** `DafnyBench/dataset/ground_truth/AssertivePrograming_tmp_tmpwf43uz0e_Find_Substring.dfy`
- **Target:** `FindFirstOccurrence`; pilot masked name `ComputeWitness`
- **Why non-trivial:** The implementation combines two search levels,
  substring-boundary reasoning, quantified invariants, and a returned witness
  index. Empty patterns, short inputs, matches, and exhausted search take
  different control-flow and proof cases.
- **Context/risk:** Keep the occurrence and result predicates; remove `Main`,
  examples, goal comments, and the original name. The contract leaves the
  failure index open, so later comparison must say whether that index is
  observable.

### 2. ID010 — least-frequency entry selection

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/CS5232_Project_tmp_tmpai_cfrng_LFUSimple.dfy`
- **Target:** `LFUCache.getLFUKey`; proposed masked name `ChooseEntry`
- **Why non-trivial:** The method must choose an entry with globally minimal
  frequency from a finite map, maintaining a partition between visited and
  unvisited map items and quantified minimality invariants.
- **Context/risk:** Keep a minimal class shell, the map field, its validity
  condition, and the exact target contract. Remove constructors, clients,
  cache operations, prints, and source-specific names. Equal-frequency ties
  leave more than one valid key, so comparison must account for that freedom.

### 3. ID107 — insertion into an ordered tree

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Dafny-Practice_tmp_tmphnmt4ovh_BST.dfy`
- **Target:** `InsertBST`; proposed masked name `ExtendStructure`
- **Why non-trivial:** The method recursively constructs a datatype tree while
  preserving strict inorder ordering and adding exactly one value to its
  abstract contents. It must coordinate structural recursion with facts about
  both subtrees and their sequence/set abstractions.
- **Context/risk:** Keep `Tree`, `Inorder`, `BST`, the content definitions, and
  only necessary lemma interfaces. Abstract contents may permit more than one
  tree shape, so later comparison must distinguish shape from abstract
  behavior.

### 4. ID117 — higher-order local-transition trace

- **Status:** existing pilot
- **Ground truth:** `DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_automaton.dfy`
- **Target:** `ExecuteAutomaton`; pilot masked name `BuildTrace`
- **Why non-trivial:** It constructs a sequence of complete states under a
  higher-order transition function, requiring nested iteration, fixed row
  dimensions, and separate boundary and interior cases.
- **Context/risk:** Keep only the higher-order signature and quantified
  transition contract. Remove example rules, tests, automaton prose, and
  identifying class/method names.

### 5. ID119 — expansion of a finite multiplicity map

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_map-multiset-implementation.dfy`
- **Target:** `Map2Seq`; proposed masked name `ExpandRepresentation`
- **Why non-trivial:** The method traverses a finite key set and expands each
  key according to its natural-number multiplicity. Its nested loops must
  coordinate quantified invariants over processed and unprocessed keys with
  the multiset represented by the growing sequence.
- **Context/risk:** Keep a minimal class shell, the bodyless abstraction
  function contract, the reverse-abstraction lemma interface, and the target
  contract. Remove the ADT trait, fields, constructors, sibling operations,
  tests, and original names. The output order is unconstrained, so compare the
  result multiset rather than the raw sequence.

### 6. ID288 — local repair of an array-backed heap

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_algorithms and leetcode_heap2.dfy`
- **Target:** `heapify`; proposed masked name `RepairAt`
- **Why non-trivial:** The method mutates an array-backed binary tree, chooses
  between up to two children, and must establish the heap invariant or identify
  the next location needing repair. Mutation and quantified parent/child
  obligations make this more than a scalar-return task.
- **Context/risk:** Keep the representation fields, `parent`, `IsMaxHeap`, and
  `IsAlmostMaxHeap`. Compare both the mutated array and returned index; do not
  silently add conventional heap properties absent from the frozen contract.

### 7. ID308 — in-place reversal of a heap-allocated list

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_ListContents.dfy`
- **Target:** `ReverseInPlace`; proposed masked name `Rewire`
- **Why non-trivial:** The method destructively reverses a linked structure
  while maintaining a recursive invariant, dynamic-frame ownership,
  representation disjointness, and a relation to the old abstract sequence.
- **Context/risk:** Keep the node fields, ghost list and footprint, and
  validity predicate. Later comparison should use the abstract list and an
  explicit heap/alias observation, not raw cross-run object identity.

### 8. ID309 — append to a dynamically framed queue

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_Queue.dfy`
- **Target:** `Enqueue`; proposed masked name `UpdateStructure`
- **Why non-trivial:** Appending one logical element requires allocation,
  tail-pointer mutation, and coordinated updates to node footprints, the queue
  spine, and ghost sequence contents.
- **Context/risk:** Keep the queue/node representation, `Valid`, and exact
  contract; omit unrelated queue operations and clients. Compare abstract
  contents and stated freshness/frame properties rather than raw identity.

### 9. ID311 — selection of two repeated values

- **Status:** existing pilot
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy`
- **Target:** `Search`; pilot masked name `ChooseWitnesses`
- **Why non-trivial:** It tracks earlier occurrences and must return two
  distinct duplicated values under a quantified existence precondition,
  combining index safety, initialization, progress, and witness reasoning.
- **Context/risk:** Keep only the duplicate predicates and target declaration.
  Raw pair order, unordered witness-set equality, and contract satisfaction are
  distinct observations.

### 10. ID313 — majority-candidate search

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy`
- **Target:** `SearchForWinner`; proposed masked name `SelectCandidate`
- **Why non-trivial:** The executable search maintains a candidate and counter
  while discarding balanced sequence portions. Its proof connects local counts
  with a global majority assumption and handles termination without a promised
  majority.
- **Context/risk:** Keep `Count`, the majority predicate, and necessary lemma
  interfaces. Remove all sibling or near-duplicate solution methods. The
  result is not fixed when no winner is promised.

### 11. ID327 — recovery from a mutation log

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_lightening_verifier.dfy`
- **Target:** `UndoLog.recover`; proposed masked name `RestoreState`
- **Why non-trivial:** Recovery replays an undo log backwards into a mutable
  array and then resets persistent state. Its loop proof relates concrete
  indices and writes to a ghost recovery function while preserving several
  representation invariants.
- **Context/risk:** Keep only the record types, arrays, ghost-state functions,
  invariant predicates, and lemma interfaces required by the target contract.
  Remove transaction clients, write operations, crash theorem, source prose,
  and original names. Context extraction is larger than for most candidates
  and must be frozen before generation.

### 12. ID417 — maximum distinct-character window

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/dafleet_tmp_tmpa2e4kb9v_0001-0050_0003-longest-substring-without-repeating-characters.dfy`
- **Target:** `method lengthOfLongestSubstring(s: string) returns (n: int,
  ghost best_iv: interval)`; proposed masked name `SelectDistinctWindow`
- **Why non-trivial:** It must construct and justify a globally maximum
  interval while maintaining a moving window and character set, relating local
  updates to quantified claims over competing intervals.
- **Context/risk:** Keep the interval type, length function, and validity
  predicate. Remove problem text, examples, algorithm discussion, and the
  sibling method ending in `'`. This is intentionally the shortlist's one
  highly recognizable programming-problem stress case: masking cannot remove
  its elevated training-contamination risk. Maximal length may be unique when
  the ghost interval is not.

### 13. ID482 — propagation through a parent-linked structure

- **Status:** proposed and unrun
- **Ground truth:** `DafnyBench/dataset/ground_truth/dafny-language-server_tmp_tmpkir0kenl_Test_vacid0_Composite.dfy`
- **Target:** `Composite.Adjust`; proposed masked name `PropagateUpdate`
- **Why non-trivial:** The method walks a parent chain while propagating an
  aggregate delta. It must re-establish validity throughout a dynamic frame,
  preserve topology and payloads, respect a field-restricted modifies clause,
  and prove termination from acyclicity.
- **Context/risk:** Keep the node fields, validity and acyclicity definitions,
  and the exact target contract. Remove constructors, update/attach/detach
  operations, clients, tests, and original names. Compare the specified heap
  fields over the frozen footprint, not object identities across executions.

### 14. ID491 — interval extraction from a tree-structured string

- **Status:** existing pilot
- **Ground truth:** `DafnyBench/dataset/ground_truth/dafny-rope_tmp_tmpl4v_njmy_Rope.dfy`
- **Target:** `report`; pilot masked name `ExtractWindow`
- **Why non-trivial:** The method recursively maps an interval into a
  heap-allocated tree through left-only, right-only, leaf, empty, and
  cross-split cases, combining arithmetic translation with dynamic-frame
  reasoning.
- **Context/risk:** Keep the representation, abstract contents, validity
  predicate, and necessary size facts; remove constructors, clients, source
  comments, and rope-specific names.

### 15. ID690 — arrangement of four datatype constructors

- **Status:** existing pilot
- **Ground truth:** `DafnyBench/dataset/ground_truth/formal_verication_dafny_tmp_tmpwgl2qz28_Challenges_ex7.dfy`
- **Target:** `Sorter`; pilot masked name `Transform`
- **Why non-trivial:** The reference maintains four moving regions and uses
  swaps to place four constructors in order while preserving the multiset,
  exercising multi-region invariants rather than a simple output.
- **Context/risk:** Keep the masked datatype, ordering relation, arrangement
  predicate, and contract; remove exercise comments, tests, and identifying
  names. Freeze helper availability before generation.

## Decisions to freeze before any of the ten proposed runs

The following are proposed controls for advisor review. They are not described
as having governed the already-completed five-case pilot.

1. Confirm the final task subset using only source-level exclusion reasons.
   Exclude a task if a self-contained body hole cannot be made without exposing
   a sibling/reference solution, if its pinned source does not verify, or if an
   executable specification directly computes the target and makes generation
   mechanically trivial.
2. Use one designated target body hole and one masked condition per task.
   Decide the number of independent samples before running any task. Run
   exactly that many samples regardless of verifier outcome; do not add retries
   after failures or stop early after a pass.
3. Freeze every visible datatype, predicate, function, lemma body, and helper
   interface. Do not expand context after observing a response.
4. Remove original paths, repository names, attribution comments, examples,
   algorithm discussions, sibling implementations, and obvious declaration
   names. Masking is contamination mitigation, not proof of no prior exposure.
5. Preserve every first response and failure. A task later judged unsuitable
   stays disclosed; a replacement is an additional task rather than a silent
   swap.
6. Before viewing a generated output, state the task-specific observation
   relation to be compared (for example raw tuple, abstract sequence, heap
   contents, or result modulo constructor renaming).
7. Disable Web/search capability for generation rather than relying only on a
   prompt prohibition. Do not expose the benchmark checkout or hidden
   reference through filesystem or tool context; if the platform cannot enforce
   this boundary, disclose that limitation before running.
8. Record the prompt artifact, masked input, model configuration, response
   hash, verifier log, and tool-use boundary. Only verifier-pass attempts
   proceed to equivalence analysis.
