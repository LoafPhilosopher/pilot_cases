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
- Test ID: `119`
- Source path: `DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_map-multiset-implementation.dfy`
- Original target: `MultisetImplementationWithMap.Map2Seq`
- Frozen target: `CountRepresentation.ExpandRepresentation`
- Source baseline: Dafny 4.3.0, `27 verified, 0 errors`.

## Preparation checks

- The Dafny fenced block in `PROMPT.md` is byte-for-byte identical to
  `input_masked.dfy`.
- `dafny resolve input_masked.dfy` succeeds with no parse, type, or name
  resolution error.
- Verifying the deliberately empty target gives `3 verified, 3 errors`; all
  three diagnostics are the expected target postcondition/definite-assignment
  failures at the omitted body, with no context diagnostic.

## Frozen context boundary

Kept, under consistent alpha-renaming:

- a minimal class shell;
- the original bodyless abstraction-function declaration and all its ensures;
- the original bodyless representation lemma declaration and complete
  requires/ensures interface;
- every target precondition and postcondition, including the source's redundant
  key-membership antecedent.

Removed before generation:

- the ADT trait, concrete state fields, constructor, and all sibling methods,
  especially `getElems`, which could otherwise be an indirect answer source;
- tests, comments, examples, repository terms, source path, and the hidden
  target body and invariants.

Semantic changes are limited to alpha-renaming and deletion of unused sibling
declarations. `AbstractView` and `RepresentationAgreement` intentionally remain
bodyless exactly as in the pinned source; they are specification interfaces,
not executable implementations. No executable specification oracle was added.

## Precommitted observation relation

Record raw sequence equality, but use multiset equality as the primary semantic
relation because the contract and hidden reference do not prescribe key order.
Candidate and reference are abstractly equivalent exactly when their result
multisets agree and every key has the frozen map multiplicity. A different
sequence permutation remains disclosed as raw-output divergence.

## Known risk

The bodyless abstraction and lemma are trusted interfaces inherited from the
source and must not be described as generated proofs. Result order is
intentionally underdetermined. The abstraction contract reveals multiplicity
semantics even after neutral renaming.
