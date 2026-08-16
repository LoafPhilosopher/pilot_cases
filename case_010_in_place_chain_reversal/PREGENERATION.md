# Pregeneration record: case 010

## Frozen status and source

- **Status:** prepared and unrun; no model output exists for this case.
- **Preparation date:** 2026-08-16.
- **DafnyBench ID:** 308.
- **Pinned DafnyBench commit:**
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`.
- **Hidden source:**
  `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_ListContents.dfy`.
- **Hidden target:** `Node<T>.ReverseInPlace`; frozen target:
  `Link<T>.Rewire`.

The complete pinned source was checked locally with Dafny 4.3.0 before freezing
this input:

```text
Dafny program verifier finished with 10 verified, 0 errors
```

The check used `dafny verify --cores 2`; lowering verifier concurrency does not
change the source or verification conditions.

The frozen `input_masked.dfy` is 984 bytes with SHA-256
`fbf828eacff025a2c82d82a974786b9b8e7e3d350f816636f31eb42eefbc6f3e`.
The Dafny block embedded in `PROMPT.md` is byte-for-byte identical. Dafny 4.3.0
`resolve --cores 2` reports zero parse or type-resolution errors. A deliberate
`verify` of the body-hole artifact reaches the target and reports only its five
unproved postcondition obligations (`3 verified, 5 errors`); retained context
does not add an independent verification error.

## Frozen context decision

The input keeps only the node fields, recursive representation predicate, the
single-element constructor required for a concrete class with an unconstrained
generic field, and the target declaration. The predecessor constructor,
`Prepend`, `SkipHead`, source comments, the original target body, and all
source-identifying names are excluded. None of those omitted declarations is
called by the hidden target. The target contract and retained declarations are
preserved exactly modulo the following consistent semantic aliases:

| Hidden source | Frozen input |
|---|---|
| `Node` | `Link` |
| `List` | `View` |
| `Repr` | `Owned` |
| `data` | `value` |
| `next` | `successor` |
| `Valid` | `Consistent` |
| constructor `Node(d)` | constructor `Create(initial)` |
| `ReverseInPlace` | `Rewire` |
| return `reverse` | return `result` |

Formatting and line wrapping are non-semantic. There are no other contract or
representation deviations. The retained constructor is necessary for Dafny to
resolve the concrete generic class and is not an implementation of reversal.
In particular, the input does not add freshness, frame, acyclicity, or
raw-reference postconditions absent from the source.

## Frozen run policy

Exactly one independent first response will be requested. It will be retained
whether it verifies or fails; there will be no repair turn, retry, or
outcome-dependent replacement. `PROMPT.md` is the only task-specific
experimental payload, and the isolated agent is instructed not to use Web,
network, tools, the filesystem, other agents, or a hidden reference.
Unavoidable platform system/developer and environment context and tool
interfaces remain present, so the retained log will be audited for zero actual
calls before the first response. Only a verifier-pass response proceeds to
equivalence analysis.

## Observation relation fixed before output

For the same valid initial heap, compare the returned list through:

1. the full abstract sequence `result.View`;
2. the concrete successor chain reachable from `result`, including its length,
   element order, and membership in the old ownership set; and
3. mutation/aliasing visible through references to nodes in the original
   `Owned` set.

Fresh cross-run object identity is not compared, but this target performs no
allocation in the hidden implementation, so a generated allocation would be a
material behavioral and framing difference if its contract permitted one.
Abstract-sequence agreement alone is not sufficient to claim heap equivalence.

## Risks fixed in advance

- The class shape and recursive predicate still reveal a singly linked chain;
  masking reduces the original benchmark fingerprint but cannot remove the
  representation semantics needed for verification.
- The contract fixes the reversed abstract sequence but does not explicitly say
  that every old node remains reachable, that `result.Owned == old(Owned)`, or
  that each individual pointer is the reference algorithm's pointer. Those
  properties require separate relational or heap inspection.
- Aliases held by a client can observe destructive pointer changes even when the
  returned abstract sequence agrees.
