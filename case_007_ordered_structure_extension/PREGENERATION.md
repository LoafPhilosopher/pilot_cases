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
- Test ID: `107`
- Source path: `DafnyBench/dataset/ground_truth/Dafny-Practice_tmp_tmphnmt4ovh_BST.dfy`
- Original target: `InsertBST`
- Frozen target: `ExtendStructure`
- Source baseline: Dafny 4.3.0, `14 verified, 0 errors`.

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

- the three-constructor-argument recursive datatype;
- the inorder-style sequence abstraction, its set abstraction, the strict
  ordering predicate, and the representation predicate;
- the exact target input/output types, precondition, and postcondition.

Removed before generation:

- `Main`, printing, the bulk builder, traversal client, comments, examples,
  source path, and ordered-tree terminology;
- all source-specific proof lemmas and the hidden target body. The Agent may
  create its own proof annotations or helper declarations under the prompt's
  no-trust-bypass rules.

Semantic changes are limited to alpha-renaming, naming the match-bound
constructor components locally, and deleting declarations not mentioned by the
target contract. The recursive datatype constructor order and every retained
definition and target formula remain unchanged.

## Precommitted observation relation

Raw datatype equality is externally observable and is compared first. Because
the contract permits more than one valid shape, also report abstract
equivalence separately: both results must satisfy `Structured`, and their
`ValuesOf` sets must equal the input set plus the inserted item. A raw-shape
difference is not silently promoted to proved raw equivalence merely because
the abstract sets agree.

## Known risk

The contract does not uniquely determine tree shape or preservation of the
input topology. Neutral naming reduces a direct benchmark-name cue, but the
inorder/strict-order definitions still expose the intended ordered-structure
semantics.
