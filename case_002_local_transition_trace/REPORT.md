# Case 002: local transition trace

## Task and selection rationale

This is DafnyBench test `117`. Given a Boolean seed row, a higher-order local
transition function, and a number of rounds, the target must construct the
complete sequence of rows. Each next cell depends on three cells from the
previous row, with `false` used beyond the two boundaries.

The task is non-trivial as a programming and verification problem: it combines
a higher-order function, a nested sequence result, boundary cases, recursive or
nested iteration, and doubly quantified postconditions. The original benchmark
examples, comments, class name, and method name were removed. The Agent saw
only the neutral interface in `input_masked.dfy`.

Hidden reference:

`DafnyBench/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_automaton.dfy`

## One-shot generation result

The isolated Coding Agent received `PROMPT.md` and was instructed not to use
Web, tools, the filesystem, or a reference. The generation log records zero
such calls before its response, and the reference was not included in its
context. It generated a recursive trace builder and a sequence-constructor
helper. The raw first attempt is preserved unchanged in
`generated_attempt_01.dfy`.

The hidden reference verifies:

```text
Dafny program verifier finished with 3 verified, 0 errors
```

The generated attempt does not:

```text
Dafny program verifier finished with 3 verified, 2 errors
```

Both errors are index-safety proof failures in the fallback branch of the
`BuildNext` sequence-constructor lambda. No forbidden verification bypass or
extra output side effect was found.

## Equivalence status

**Status: verifier-fail; semantic comparison not entered.**

The experiment's gate is to compare reference behavior only after a generated
candidate passes Dafny. Although the intended recurrence closely follows the
contract, an unverifiable attempt is not treated as a contract-conforming
program and is not assigned an equivalence result. Repairing the two proof
obligations could be a separate follow-up attempt, but doing so would not alter
this recorded first-attempt outcome.

## Reproduction

From the project root:

```bash
./verifierbench/dafny verify \
  verifierbench/pilot_cases/case_002_local_transition_trace/generated_attempt_01.dfy
```

The concise result and reference command are recorded in `verification.txt`.
