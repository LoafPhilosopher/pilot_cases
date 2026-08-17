# Reproducing the recorded Dafny results

## Quick start

From a standalone clone of this repository on a glibc-based Linux x86-64
system compatible with the official Ubuntu 20.04 package:

```bash
./reproduce.sh
```

The script:

1. downloads the official Dafny 4.3.0 Ubuntu 20.04 x64 archive;
2. verifies its SHA-256 digest;
3. checks out DafnyBench at the exact recorded commit;
4. checks the bytewise repair chains, reconstructs every repair prompt, replays
   each Round 01 verifier feedback file and the verifier output passed into Case
   009 Round 02, verifies all four artifact checksum manifests, and then reruns
   the heuristic text scan for forbidden constructs on both first attempts and
   saved repair outputs;
5. reruns every reference, all 15 first attempts, and each first-attempt
   post-gate comparison;
6. reproduces every saved repair round for cases 002, 009, 010, and 013,
   then checks each final repair comparison; and
7. executes the concrete counterexamples for cases 001, 003, 009, 010,
   and 012.

Cases 002, 009, 010, and 013 are recorded first-attempt failures.
Reproduction succeeds only when those attempts reproduce the recorded
diagnostics, rather than merely returning a nonzero exit code. Case 002 has
`3 verified, 2 errors`. Case 009 has `5 verified, 1 error` and must report at
`(51,15)` that the array element assignment may update outside the enclosing
modifies clause. Case 010 must report exactly 17 occurrences of Dafny 4.3.0's
diagnostic
`Error: type seq<T> does not have a member Length`, together with its recorded
17-error resolution summary. Case 013 has `6 verified, 2 errors`, and both
modifies-clause diagnostics must occur at `(226,12)` and `(307,11)`. Thus an
unrelated failure with the same error count is rejected.

The bytewise chain checks confirm that each Round 01 input is the corresponding
first attempt and that each saved raw response is exactly the program sent to
Dafny. For Case 009, they also confirm that the Round 01 output became the Round
02 input and that the Round 01 verification log became the Round 02 verifier
feedback.

For every saved repair prompt, the script extracts the Dafny program and
verifier-feedback blocks and compares them byte for byte with that round's
saved input files. It also reconstructs the complete prompt from a fixed
instruction template and compares the whole file, so added instructions or
other text outside the two blocks cause the check to fail.

The four Round 01 feedback files are independently recreated by running Dafny
4.3.0 from the corresponding round directory on `input_program.dfy`, with the
recorded two-worker setting. The script compares both the exit code and the
complete combined verifier output byte for byte with `verifier_feedback.txt`.
For Case 009 it also runs Round 01's `output_program.dfy` and compares the exit
code and complete output byte for byte with `round_01/verification.txt`. The
chain check then connects that independently reproduced result to
`round_02/verifier_feedback.txt` and to the feedback block in the Round 02
prompt.

The script then verifies the already saved repair history; it does not call an
agent or generate new repair code. Case 002 passes in round 1 (`4 verified, 0
errors`). Case 009 still fails in round 1 at its saved assertion (`5 verified,
1 error`) and passes in round 2 (`6 verified, 0 errors`). Cases 010 and 013 pass
in round 1 with `8 verified, 0 errors` and `7 verified, 0 errors`, respectively.
Only those final passing programs are used by the repair comparison harnesses.
Their recorded verification summaries are 12/0 for case 002, 13/0 for case
009, 19/0 for case 010, and 50/0 for case 013. Executing the case 009 and 010
harnesses also checks their concrete behavioral differences from the pinned
reference implementations.

Case 006 verifies, but its generation log records one prohibited outbound
progress call before the final code response. Reproduction checks the Dafny
artifact; it does not turn that attempt into a protocol-conforming sample.

## Pinned inputs

- Dafny: `4.3.0`
- Official archive:
  `https://github.com/dafny-lang/dafny/releases/download/v4.3.0/dafny-4.3.0-x64-ubuntu-20.04.zip`
- Archive SHA-256:
  `6920fc19db0d5d4d07e8ef2c2386511eb97a02175b38a994774a2b830ad0e11e`
- DafnyBench repository: `https://github.com/sun-wendy/DafnyBench.git`
- DafnyBench commit:
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`

Automatic setup requires `awk`, `bash`, `cmp`, `curl`, `git`, `unzip`, and
`sha256sum`.
Python 3 is required for the five runtime counterexamples. Downloaded
dependencies are stored in ignored directories `.tools/` and
`third_party/`; each reproduction run receives a new timestamped directory
under `.repro/runs/`.

## Options

Run one active case (001 through 015):

```bash
./reproduce.sh --case 004
```

Skip the five runtime counterexamples while retaining all formal verification:

```bash
./reproduce.sh --skip-runtime
```

The superseded ID771 run is excluded by default. Reproduce it explicitly with:

```bash
./reproduce.sh --case archive-771
```

or append it to all active checks with `--include-archive`.

For offline or preinstalled environments, point to an executable Dafny 4.3.0
and an existing DafnyBench checkout at the pinned commit:

```bash
DAFNY_BIN=/absolute/path/to/dafny \
DAFNYBENCH_DIR=/absolute/path/to/DafnyBench \
./reproduce.sh
```

The setup script verifies both supplied versions before running.
Verification uses two solver workers by default to remain predictable on
shared machines. Set `DAFNY_CORES` to another positive integer if needed.
The exact repair-record replays always use the recorded two-worker setting;
`DAFNY_CORES` controls the other verification and runtime checks.

## Historical command records

Each `verification.txt` preserves commands as originally executed inside the
larger `verifierbench` workspace. Those paths are historical provenance and
are not standalone instructions. Use `./reproduce.sh` in this repository; its
paths are anchored to the clone location and do not depend on the caller's
working directory.

Dafny's Python compilation output is staged under that run's ignored
`runtime/` directory, so running the counterexamples does not recreate
generated `*-py/` directories in the tracked case folders.
