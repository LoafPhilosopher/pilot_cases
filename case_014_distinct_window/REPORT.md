# Case 014: maximum pairwise-distinct window

## Outcome

The untouched first generation passes Dafny.  Its primary executable result is
proved equal to the hidden reference result for every input string:

```text
Dafny program verifier finished with 13 verified, 0 errors
```

Classification for the frozen primary observation: **proved-equivalent**.  The
returned integer is the unique maximum admissible-window length, even when the
input has several different maximizing windows.

The secondary `ghost` span needs a separate qualification.  Both contracts
allow any maximizing span.  The harness proves endpoint equality when the
maximizing span is unique; the contracts alone do not imply endpoint equality
when there is a tie.  This ghost freedom is not an executable-output
difference.

The hidden source is DafnyBench ID417:

`third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafleet_tmp_tmpa2e4kb9v_0001-0050_0003-longest-substring-without-repeating-characters.dfy`

## Verification gate

Using pinned Dafny 4.3.0, all three files pass without repair:

```text
Hidden reference:                         4 verified, 0 errors
Generated attempt:                        4 verified, 0 errors
Combined unit, including both sources:   13 verified, 0 errors
```

The harness declarations alone account for `5 verified, 0 errors`; the
combined count uses `--verify-included-files` so that both included source
files are verified in the same command.

The saved generation was compared only after its verifier-pass result.  The
comparison did not edit `generated_attempt_01.dfy`, `input_masked.dfy`,
`PROMPT.md`, or `PREGENERATION.md`.

## Primary relational proof

The reference and generated programs use nominally different subset types and
predicate names, so `comparison_harness.dfy` first proves that conversion of
the two endpoint pairs preserves validity and length.  It then calls both
actual methods on the same string.

Let the reference return length `r` and the generation return `g`.  The
generated witness is a valid reference interval, so reference maximality gives
`g <= r`.  Conversely, the reference witness is an admissible generated span,
so generated maximality gives `r <= g`.  Dafny therefore proves `r == g` for an
arbitrary string.  This is an unbounded contract-level proof, not finite
testing and not a comparison with a few expected outputs.

## Ghost span and tie handling

The harness also proves the conditional statement:

```text
if every valid interval of maximum length equals the reference witness,
then the reference and generated endpoints are equal.
```

Without that uniqueness premise, exact endpoints are underdetermined by both
public contracts.  For example, `"abba"` has two length-two admissible spans,
`[0,2)` and `[2,4)`.  Either one satisfies the declared result relation.

Inspection of the actual bodies suggests the endpoints agree even on ties:
the reference scans right endpoints in increasing order and replaces its
witness only on a strict improvement; the generated body enumerates left
endpoints in increasing order and likewise replaces only on a strict
improvement.  For equal maximum lengths, earliest right endpoint and earliest
left endpoint identify the same span.  This tie-breaking observation is a
source-code argument, not a consequence proved by the combined harness, so it
is not used to upgrade the primary result or to claim unconditional declared-
tuple equality.

## Implementation comparison

The reference is a linear sliding-window algorithm with a character set.  The
generation independently uses nested enumeration plus a quantified
`RangeDistinct` function, making it asymptotically slower but still fully
verified.  Their algorithmic structures are materially different; the public
maximum contracts, rather than syntactic similarity, establish equality of
the executable integer.

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 014
```

The exact commands and outputs used for this report are retained in
`verification.txt`.
