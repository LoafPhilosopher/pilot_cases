# Generation provenance

`manifest.json` records the model configuration exposed by the local Codex
logs, session identifiers and timestamps, hashes of the recorded prompt
artifacts and outputs, and event counts before each first code response.

The complete JSONL logs are retained privately rather than committed. They
contain platform instructions, encrypted reasoning, absolute local paths, and
later analysis turns unrelated to the isolated generation. The first assistant
response in each listed session is code-only and is publicly represented by
`generated_attempt_01.dfy` with one trailing LF added. The raw response's byte
length and hash allow that mapping to be checked if the retained log is later
made available under controlled conditions.

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
independently establish the event history. Accordingly, the repository states
that the local logs were audited as having zero calls before the saved
response; it does not claim capability-level isolation or public independent
verification of that fact.

Run the public artifact integrity check from the repository root:

```bash
sha256sum -c provenance/SHA256SUMS
```
