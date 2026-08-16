# Pregeneration record: case 012

## Frozen status and source

- **Status:** prepared and unrun; no model output exists for this case.
- **Preparation date:** 2026-08-16.
- **DafnyBench ID:** 313.
- **Pinned DafnyBench commit:**
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`.
- **Hidden source:**
  `DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy`.
- **Hidden target:** `SearchForWinner`; frozen target: `SelectCandidate`.

The complete pinned source was checked locally with Dafny 4.3.0 before freezing
this input:

```text
Dafny program verifier finished with 16 verified, 0 errors
```

The check used `dafny verify --cores 2`; lowering verifier concurrency does not
change the source or verification conditions.

The frozen `input_masked.dfy` is 1217 bytes with SHA-256
`5e340b4c817fdc9b88375e3d4beb9d81ba49a307ccf9c8b63512c69dcb5cac28`.
The Dafny block embedded in `PROMPT.md` is byte-for-byte identical. Dafny 4.3.0
`resolve --cores 2` reports zero parse or type-resolution errors. A deliberate
`verify` of the body-hole artifact verifies the retained function and lemmas
and reports only the target's unproved postcondition and uninitialized return
(`6 verified, 2 errors`).

## Frozen context decision

The input retains the interval-counting function and the two mathematical lemma
interfaces used by the hidden target. It excludes `HasMajority`, `FindWinner`,
`DetermineElection`, the result datatype, both alternative calculational
implementations, all source comments, and the original target body. In
particular, no sibling or near-duplicate majority-selection algorithm is shown.

The target contract and retained helpers are preserved exactly modulo these
consistent aliases:

| Hidden source | Frozen input |
|---|---|
| `Count` | `SegmentFrequency` |
| `SearchForWinner` | `SelectCandidate` |
| type parameter `Candidate` | `Choice` |
| `a`, `hasWinner`, `K`, return `k` | `values`, `promised`, `designated`, `candidate` |
| `Lemma_Split` | `FrequencySplit` |
| `Lemma_Unique` | `DistinctFrequencyBound` |
| helper bounds `s`, `t`, `u`, `x`, `y` | descriptive neutral names |

Formatting and line wrapping are non-semantic. The empty lemma bodies are the
same automatically proved mathematical helpers present in the pinned source;
they are not implementations of the target. There are no other semantic
deviations.

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

Compare the raw returned `candidate` for identical `values`, `promised`, and
`designated` inputs.

- When `promised` is true, the contract fixes `candidate == designated`, so any
  two verifier-conforming implementations are output-equivalent.
- When `promised` is false, the contract imposes no condition on `candidate`.
  Raw equality remains the primary observation; contract conformance alone is
  not treated as equivalence. Concrete counterexamples or a separate relation
  proof are required.

The ghost inputs do not exist at runtime, but they remain part of the formal
calling context used for the relational comparison.

## Risks fixed in advance

- `SegmentFrequency` is executable mathematical context and exposes how to
  count any candidate, but it does not compute or prescribe the target's output.
  It is retained because the original target contract and proof depend on it.
- `SelectCandidate` is still semantically suggestive even after removing the
  historically recognizable algorithm and sibling bodies. Name masking is only
  contamination mitigation.
- The false-`promised` branch is intentionally under-specified. A confident
  canonical strategy may arise from the problem shape or training exposure;
  one sample cannot distinguish those explanations.
