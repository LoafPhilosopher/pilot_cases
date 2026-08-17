# Case 014: longest substring without repeated characters

The reference and generated programs return the same maximum length for every
input string. Dafny also proves that their ghost interval endpoints match when
the maximizing interval is unique; the current proof and the two contracts do
not determine what happens to those endpoints when maxima tie.

## Problem given to the model

This is DafnyBench ID417. A span is a half-open interval `[start,end)`. It is
admissible when it lies inside the string and no two positions in it contain
the same character. The model received the following specification, with the
method body removed:

```dafny
ghost predicate IsAdmissible(text: string, span: Span) {
  0 <= span.0 <= span.1 <= |text| &&
  (forall i, j | span.0 <= i < j < span.1 :: text[i] != text[j])
}

method SelectDistinctWindow(text: string)
    returns (size: int, ghost chosen: Span)
  ensures IsAdmissible(text, chosen) && chosen.1 - chosen.0 == size
  ensures forall candidate | IsAdmissible(text, candidate) ::
    candidate.1 - candidate.0 <= size
```

Thus `chosen` must describe a substring with distinct characters, `size` must
be its length, and no other admissible span may be longer. The endpoints are
ghost data used for the proof and are not part of the compiled result.

The integer result is uniquely determined even if several spans reach the
maximum: all maximum spans have the same length. The ghost result is different
because the specification asks only for one maximizing witness and gives no
tie-breaking rule. Separating these two returns is necessary when deciding
what the comparison proves.

### Synthesis task and supplied context

The only runtime input is `text`, and the only compiled output is `size`.
`chosen` is a ghost proof witness. `Span`, `SpanSize`, and `IsAdmissible` were
supplied as specification context, not as additional runtime inputs. The target
`SelectDistinctWindow` body was omitted. The recorded prompt contains no
reference body, test case, example string, example output, or required
maximizing interval ([`PROMPT.md`](PROMPT.md)). The examples below were created
for the later analysis and were not shown to the agent.

## What the two programs do

The reference program uses a sliding window:

```text
keep a current interval [lo,hi) and its set of characters
extend hi when the next character is new
otherwise move lo right until extension is possible
record a new best interval only when its length strictly increases
return the best length and ghost interval
```

The generated program exhaustively examines candidate spans:

```text
for each possible left endpoint
    for each possible right endpoint
        test whether all characters in [left,right) are distinct
        record it only if it is longer than the current best
return the recorded length and ghost span
```

The generated algorithm is less efficient, but its nested-loop invariants
prove that every already examined admissible span is no longer than the saved
one.

For example, on `"abcabcbb"` both methods must return length `3`. The reference
reaches this result while moving one window through the string in a single
left-to-right scan. The generated method reaches it after considering all
endpoint pairs. The comparison does not depend on this example. Its proof
covers an arbitrary string and does not assume a fixed alphabet.

## Result

The comparison maps the reference interval type and generated span type by
copying their two endpoints. It proves that this conversion preserves both
admissibility and length, then calls the two actual methods on an arbitrary
string. Let their returned lengths be `r` and `g`. The generated witness is a
valid reference interval, so reference maximality gives `g <= r`. The
reference witness is also a valid generated span, so generated maximality
gives `r <= g`. Dafny therefore proves `r == g` without enumerating strings.

Dafny 4.3.0 reports:

```text
Reference program:     4 verified, 0 errors
Generated program:     4 verified, 0 errors
Combined comparison:  13 verified, 0 errors
```

## Ghost endpoints and ties

Maximum length does not always identify one interval. For example, `"abba"`
has two admissible spans of maximum length two: `[0,2)` is `"ab"`, and `[2,4)`
is `"ba"`. The contracts permit either witness. The comparison proves equal
endpoints if the maximum span is unique, but it cannot obtain unconditional
endpoint equality from these contracts.

Inspection suggests that the retained bodies both keep the first maximum they
encounter, including on tied inputs such as `"abba"`. That tie-breaking claim
is not proved by the current comparison method, and no differing endpoint
example was observed for these two implementations. The unconditional result
is equality of the executable integer. The current proof additionally gives
endpoint equality when the maximum is unique; with ties, it proves neither
equality nor a difference for the two retained bodies. The specification would
permit another verified implementation to return a different tied span while
preserving the same maximum length.

## Reproduction

```bash
./reproduce.sh --case 014
```
