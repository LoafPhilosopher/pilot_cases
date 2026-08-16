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
4. verifies the pilot, extension-freeze, and extension-result artifact
   checksums and reruns the recorded heuristic text scan for forbidden
   constructs;
5. reruns every reference, all 15 generated attempts, and each available
   post-gate comparison; and
6. executes the concrete counterexamples for cases 001, 003, and 012.

Cases 002, 009, 010, and 013 are recorded failures. Reproduction succeeds only
when their saved first attempts reproduce the recorded diagnostics: Case 002
has `3 verified, 2 errors`, Case 009 has `5 verified, 1 error`, Case 010 has 17
resolution/type errors, and Case 013 has `6 verified, 2 errors`. The script
does not repair or silently drop them.

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

Automatic setup requires `bash`, `curl`, `git`, `unzip`, and `sha256sum`.
Python 3 is required for the three runtime counterexamples. Downloaded
dependencies are stored in ignored directories `.tools/` and
`third_party/`; each reproduction run receives a new timestamped directory
under `.repro/runs/`.

## Options

Run one active case (001 through 015):

```bash
./reproduce.sh --case 004
```

Skip the three runtime counterexamples while retaining all formal verification:

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

## Historical command records

Each `verification.txt` preserves commands as originally executed inside the
larger `verifierbench` workspace. Those paths are historical provenance and
are not standalone instructions. Use `./reproduce.sh` in this repository; its
paths are anchored to the clone location and do not depend on the caller's
working directory.

Dafny's Python compilation output is staged under that run's ignored
`runtime/` directory, so running the counterexamples does not recreate
generated `*-py/` directories in the tracked case folders.
