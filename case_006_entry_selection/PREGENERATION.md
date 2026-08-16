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
- Test ID: `010`
- Source path: `DafnyBench/dataset/ground_truth/CS5232_Project_tmp_tmpai_cfrng_LFUSimple.dfy`
- Original target: `LFUCache.getLFUKey`
- Frozen target: `RecordSpace.ChooseEntry`
- Source baseline: Dafny 4.3.0, `8 verified, 0 errors`.

## Preparation checks

- The Dafny fenced block in `PROMPT.md` is byte-for-byte identical to
  `input_masked.dfy`.
- `dafny resolve input_masked.dfy` succeeds with no parse, type, or name
  resolution error.
- Verifying the deliberately empty target gives `2 verified, 3 errors`; all
  three diagnostics are the expected target postcondition/definite-assignment
  failures at the omitted body, with no context diagnostic.

## Frozen context boundary

Kept, under consistent alpha-renaming:

- the two integer/map representation fields;
- the complete representation predicate, including its positivity constraints;
- the exact target parameters, returns, reads effect inherited through the
  predicate, preconditions, and postconditions.

Removed before generation:

- the constructor and all sibling operations (`get`, `put`, and `Main`);
- prints, clients, examples, comments, source path, repository vocabulary, and
  cache/eviction/frequency identifiers;
- the hidden target body and its loop invariants.

Semantic changes are limited to alpha-renaming and removal of declarations that
the target contract neither calls nor mentions. No precondition, postcondition,
state field, or predicate clause used by the target was strengthened or
weakened.

## Precommitted observation relation

The observable result is the returned integer in the unchanged `table` state.
If the minimum second component is unique, compare the candidate and reference
integers directly. If several keys tie for the minimum, different tied keys are
recorded as raw-output divergence but are equivalent under the primary
contract-level relation exactly when each returned key is present and has the
global minimum second component. Do not impose a tie-breaking rule absent from
the frozen contract.

## Known risk

The finite minimum is non-unique in tie states. The neutral names reduce direct
repository/name cues, but the quantified minimum contract necessarily reveals
the mathematical task.
