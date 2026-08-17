# Generation provenance

`manifest.json` records the five-case pilot. `extension_manifest.json` records
the prospectively frozen ten-case extension. They contain the model
configuration exposed by the local Codex logs, session identifiers and
timestamps, hashes of the recorded prompt artifacts and outputs, verifier
outcomes, and event counts before each saved final code response.

The complete JSONL logs are retained privately rather than committed. They
contain platform instructions, encrypted reasoning, absolute local paths, and
later analysis turns unrelated to the isolated generation. Each saved raw code
response is publicly represented by `generated_attempt_01.dfy` with one
trailing LF added. The raw response's byte length and hash allow that mapping
to be checked if the retained log is later made available under controlled
conditions. Case 006 made one outbound progress call before its final code
response; the manifest and `protocol_deviation.txt` preserve that violation,
and the attempt is excluded from protocol-conforming counts.

The inter-agent task payload itself is encrypted in the retained JSONL.
Consequently, `PROMPT.md` is a recorded prompt artifact whose public hash can
be checked, but a third party cannot use the repository or encrypted envelope
alone to prove that the file is byte-for-byte identical to the delivered task.
On 2026-08-14, the repository-only title in each prompt artifact was changed
from “Exact generation prompt” to “Recorded generation prompt” to reflect this
limitation; the recorded instruction and Dafny source beneath the title were
not changed. The manifest hashes the current files.

This is stronger provenance than an un-hashed narrative record, but it has an
important limit: a digest of a non-public log does not let a third party
independently establish the event history. Accordingly, the repository reports
the audited call counts—including the Case 006 exception—but does not claim
capability-level isolation or public independent verification of the
unpublished event history.

Run the public artifact integrity check from the repository root:

```bash
sha256sum -c provenance/SHA256SUMS
sha256sum -c provenance/extension_freeze_SHA256SUMS
sha256sum -c provenance/extension_results_SHA256SUMS
sha256sum -c provenance/repair_SHA256SUMS
```

The extension freeze checksum covers the exact pre-generation task set,
prompts, and observation decisions. The extension results checksum separately
covers generated outputs, reports, comparison harnesses, verification records,
result metadata, and the standalone reproduction entry points. The repair
checksum covers the fixed protocol, every saved repair round, the four final
comparisons, and the updated case reports and conclusion.
