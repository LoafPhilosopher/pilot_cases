# Case 012: the false-promise branch exposes a raw-output counterexample

## Outcome

**Overall classification: `counterexample`.** The implementations are
proved-equivalent when `promised`/`hasWinner` is true, but they are not
equivalent for all formally permitted calls. With the ghost flag false, the
following concrete input produces different raw candidates:

```text
values:     [0, 1, 2]
generated:  0
reference:  2
```

The false flag makes the output postcondition vacuous, so both results conform
to the shared contract. This is precisely why verifier-pass is not sufficient
for raw-output equivalence here.

## Sources compared

- DafnyBench ID313 at pinned commit
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`;
- hidden target `SearchForWinner` in
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy`;
- frozen target `SelectCandidate` in `generated_attempt_01.dfy`; and
- proof/runtime artifact `comparison_harness.dfy`.

The generated file has SHA-256
`9ff9e8daaec0f438276f9027f7b332be2b5fe18eccb1a588eae37941e80210bb`.
The pinned reference file has SHA-256
`1d31d1d76157284fd04e9230f9818611c273efe2b2c90c5013a7a96f3028b57e`.

## Proved true-flag equivalence

`FrequenciesAgree` proves that the masked `SegmentFrequency` and reference
`Count` definitions are equal for every valid interval. The relational method
`PromisedBranchAgree` then calls both actual implementations. Given a strict
majority for `designated`, their public postconditions force both raw returns
to equal `designated`.

This proof is general over element type, sequence length, values, and the
position of the majority value. It is not bounded testing.

The combined result, including verification of both included source files, is:

```text
Dafny program verifier finished with 28 verified, 0 errors
```

## Concrete false-flag counterexample

The harness executes the exact included bodies on `[0,1,2]` with the flag false
and records:

```text
Dafny program verifier finished with 5 verified, 0 errors
input:     [0, 1, 2]
generated: 0
reference: 2
```

The output difference follows directly from their control flow:

- The generated body initializes `candidate` to `values[0]` and replaces it
  only with an element whose frequency is a strict majority of the complete
  sequence. No element of `[0,1,2]` has such a majority, so it returns `0`.
- The reference body starts with candidate `0`. At index 1, the different value
  removes the candidate's strict lead over the current segment. Because one
  value remains, it resets its candidate to `values[2]`, namely `2`, and then
  terminates.

The harness deliberately does not attach an exact-output postcondition to the
runtime method. Dafny verifies contract conformance of the calls; the displayed
values are an execution of the two concrete included programs, not a modular
proof derivable from their vacuous false-flag postconditions.

## Exact condition split

There is no remaining `undetermined` branch in this comparison:

- if the ghost promise is true and its majority precondition holds, raw-output
  equality is proved for all inputs;
- if the ghost promise is false, universal raw-output equality is refuted by
  the concrete witness above.

For the two current bodies, the ghost flag has no executable influence: all
flag-dependent statements are proof-only. Therefore, if the sequence actually
has a strict majority even when the caller passes false, both executions still
return that unique majority (the same executable run could instead be called
with a true ghost flag and that majority as `designated`). If no strict majority
exists, the generated body returns the first element, whereas the reference
returns its final cancellation-segment candidate; they agree exactly when that
reference candidate equals the first element. These latter body-level facts
come from source inspection, not from the false-flag contract.

## Verification summary

Using pinned Dafny 4.3.0:

```text
Hidden reference:       16 verified, 0 errors
Generated attempt:       7 verified, 0 errors
Combined harness:       28 verified, 0 errors
Runtime harness:         5 verified, 0 errors
```

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 012
```

The exact commands and results are preserved in `verification.txt`.
