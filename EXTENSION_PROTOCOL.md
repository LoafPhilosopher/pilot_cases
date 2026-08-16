# Frozen protocol for the ten-task extension

## Status

This document records decisions made on 2026-08-16 before any model output was
requested for the ten previously unrun entries in `SHORTLIST.md`. The advisor's
approval to proceed was reported by the researcher before this freeze.

The earlier five cases remain a disclosed feasibility pilot. The ten cases
below form a prospective extension; their outcomes will be reported separately
from the pilot before any combined descriptive summary is given.

## Frozen task set

| New case | DafnyBench ID | Masked target |
|---|---:|---|
| 006 | 010 | `ChooseEntry` |
| 007 | 107 | `ExtendStructure` |
| 008 | 119 | `ExpandRepresentation` |
| 009 | 288 | `RepairAt` |
| 010 | 308 | `Rewire` |
| 011 | 309 | `UpdateStructure` |
| 012 | 313 | `SelectCandidate` |
| 013 | 327 | `RestoreState` |
| 014 | 417 | `SelectDistinctWindow` |
| 015 | 482 | `PropagateUpdate` |

Each case directory contains the frozen masked source, the complete recorded
generation prompt, a pre-generation context decision, and an observation
relation selected before generation.

## Sampling and isolation

1. Run exactly one generation for each of the ten tasks, regardless of whether
   earlier tasks pass or fail verification. Do not retry, repair, replace, or
   stop early based on an outcome.
2. Use the same recorded configuration as the pilot: `gpt-5.6-sol` with
   `ultra` reasoning effort. If the execution log reports a different setting,
   retain the output but mark the attempt as a protocol deviation.
3. Start every generation in a fresh agent context. The only task-specific
   experimental payload is the recorded instruction and masked Dafny source.
   Do not put the benchmark checkout, source path, reference body, prior cases,
   or analysis into that payload. Unavoidable platform system/developer and
   environment context, together with exposed tool interfaces, remains present
   and is not experimental task material.
4. Instruct the agent not to browse or search the Web, use any network
   interface, call tools, inspect the filesystem, or contact another agent.
   The current platform does not remove those capabilities at the interface
   level, so the auditable condition is zero actual calls before the first
   response. Any nonzero call count is a protocol violation and is not replaced
   by another sample.
5. Save the first response before invoking Dafny. Do not edit it except for a
   recorded serialization normalization such as appending one final LF.

## Verification and comparison gate

- Verify each saved response with Dafny 4.3.0.
- Preserve every verifier error and diagnostic.
- Only verifier-pass attempts proceed to generated-versus-hidden-reference
  comparison.
- Do not treat bounded tests as a proof. Report concrete counterexamples,
  machine-checked relational results, or an explicitly undetermined outcome.
- Apply the observation relation frozen in that case's `PREGENERATION.md`.
  Raw allocation identities from separate runs are related through an initial
  heap mapping, not compared literally. Preserve field-reference identity and
  effects through pre-existing aliases whenever they are observable through
  the supplied public representation and frame, even if the postcondition does
  not explicitly mention freshness or aliasing.

## Reporting

The primary counts for this extension are ten first attempts and the number of
those ten that pass verification. Equivalence conclusions use the verifier-pass
count as their denominator. The original five-attempt pilot remains identified
separately because its active set was not preregistered.
