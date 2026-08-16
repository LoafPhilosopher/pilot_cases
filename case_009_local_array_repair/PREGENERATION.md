# Pre-generation record

## Status and frozen run policy

- Status: prepared and unrun. No generation agent has been contacted for this
  case.
- Samples: exactly one first response from one isolated Coding Agent.
- No retries, repairs, continuation prompts, or replacement samples are
  permitted, regardless of verifier outcome.
- The exact prompt in `PROMPT.md` will be the only task-specific experimental
  payload. The Agent will be instructed not to use Web, network, tools, the
  filesystem, other agents, or a hidden reference. Unavoidable platform
  system/developer and environment context and tool interfaces remain present,
  so the retained log will be audited for zero actual calls before the first
  response.
- Preserve the complete raw response and its hash before running Dafny.

## Pinned source

- DafnyBench commit: `0cd28feed9cd0179b07fdb9d002f8c39063658e4`
- Test ID: `288`
- Source path: `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_algorithms and leetcode_heap2.dfy`
- Original target: `Heap.heapify`
- Frozen target: `ArrayState.RepairAt`
- Source baseline: Dafny 4.3.0, `6 verified, 0 errors`.

## Preparation checks

- The Dafny fenced block in `PROMPT.md` is byte-for-byte identical to
  `input_masked.dfy`.
- `dafny resolve input_masked.dfy` succeeds with no parse, type, or name
  resolution error.
- Verifying the deliberately empty target gives `5 verified, 5 errors`; all
  five diagnostics are the expected target postcondition failures at the
  omitted body, with no context diagnostic.

## Frozen context boundary

Kept, under consistent alpha-renaming:

- the backing array and a minimal constructor needed to initialize its
  non-null field;
- the exact predecessor-index function and both quantified representation
  predicates, including their source-specific boundary implications;
- the exact target modifies set, preconditions, returned-index alternatives,
  and conditional postconditions.

Removed before generation:

- the source class/method/predicate vocabulary, source path, comments, and the
  hidden target body and proof blocks;
- no sibling algorithms existed; no client or example context was added.

The constructor was retained only to keep the class independently usable and
is an alpha-renamed copy of the source constructor. Other changes are
whitespace and alpha-renaming only. In particular, the unusual two final
clauses of `OrderedAwayFrom` were preserved verbatim modulo names; they were not
replaced with a conventional heap condition.

## Precommitted observation relation

For full behavioral comparison, relate the two initial heaps so that the
`data` field denotes the same pre-existing input array under the heap mapping.
After each call require all of the following:

1. the `data` field still denotes that original array (rather than a newly
   allocated replacement);
2. observers holding the original input-array alias see the same complete
   post-state contents; and
3. the returned integer `next` is equal.

Also report the weaker value-level relation `(data[..], next)` separately. The
contract permits assigning a different array reference because `modifies this`
allows the field to change, while the hidden reference mutates the original
array. Therefore equal sequence contents alone must not be called full
behavioral equivalence. Record contract satisfaction separately as well,
because the frozen contract may permit more than one repair choice. Do not
ignore the returned position or silently impose a full recursive repair not
required by the one-step contract.

## Known risk

The contract is intentionally the pinned source's local one-step relation, not
a conventional whole-heapify specification. Neutral names reduce direct cues,
but the `2*i+1` and `2*i+2` formulas necessarily expose a binary-layout
structure. Multiple verifier-passing post-states may be possible.
