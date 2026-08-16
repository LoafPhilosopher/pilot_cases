# Pregeneration record: case 011

## Frozen status and source

- **Status:** prepared and unrun; no model output exists for this case.
- **Preparation date:** 2026-08-16.
- **DafnyBench ID:** 309.
- **Pinned DafnyBench commit:**
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`.
- **Hidden source:**
  `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_Queue.dfy`.
- **Hidden target:** `Queue<T>.Enqueue`; frozen target:
  `Buffer<T>.UpdateStructure`.

The complete pinned source was checked locally with Dafny 4.3.0 before freezing
this input:

```text
Dafny program verifier finished with 18 verified, 0 errors
```

The check used `dafny verify --cores 2`; lowering verifier concurrency does not
change the source or verification conditions.

The frozen `input_masked.dfy` is 1722 bytes with SHA-256
`f41a7b48cff5ea1206d611978bedd1acba7daa33f1e60980412cb4c402a0d4c5`.
The Dafny block embedded in `PROMPT.md` is byte-for-byte identical. Dafny 4.3.0
`resolve --cores 2` reports zero parse or type-resolution errors. A deliberate
`verify` of the body-hole artifact reaches the target and reports only the
expected unproved appended-model postcondition (`5 verified, 1 error`);
retained context does not add an independent verification error.

## Frozen context decision

The input keeps the queue and node fields, both representation predicates, both
initialization constructors, and the target declaration. A queue constructor is
required because its non-null generic node fields have no field initializer;
the node constructor is also the allocation interface used by the hidden
target. `Rotate`, `RotateAny`, `IsEmpty`, `Front`, `Dequeue`, both client
methods, all examples, source comments, and the original target body are
excluded. The target contract and retained declarations are preserved exactly
modulo consistent aliases:

| Hidden source | Frozen input |
|---|---|
| `Queue` | `Buffer` |
| `Node` | `Cell` |
| `head`, `tail` | `first`, `last` |
| queue `contents`, `footprint`, `spine` | `model`, `owned`, `chain` |
| node `data`, `next` | `value`, `successor` |
| node `tailContents`, `footprint` | `suffix`, `owned` |
| both `Valid` predicates | both `Consistent` predicates |
| both constructors `Init` | `Create` in their respective classes |
| `Enqueue(t)` | `UpdateStructure(item)` |

Formatting, bound-variable names, and line wrapping are non-semantic. There
are no other specification or representation deviations. The retained
constructor bodies are ordinary initialization/allocation context, not sibling
implementations of the target.

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

For the same valid initial object and appended value, compare:

1. the full abstract sequence `model`;
2. the concrete chain from `first` to `last`, including node values and the
   final null successor;
3. the identities of all pre-existing cells and which existing pointers were
   mutated; and
4. freshness, ownership, and alias relationships for newly allocated cells.

New objects from separate executions are compared up to a bijection that fixes
all pre-existing objects; raw addresses of fresh cells are not compared.
Abstract-sequence equality by itself is not a complete heap-equivalence claim.

## Risks fixed in advance

- The retained linked representation and sentinel-style empty suffix still
  reveal the broad data-structure family despite neutral names.
- The postcondition uniquely fixes `model` but does not fully prescribe which
  fresh topology realizes it. A verifier-pass implementation can therefore be
  abstractly correct yet observably different through public fields or aliases.
- The target's quantified ghost updates over the old chain are proof-intensive;
  retaining the constructor but removing all sibling queue operations is the
  frozen compromise between completeness and leakage.
