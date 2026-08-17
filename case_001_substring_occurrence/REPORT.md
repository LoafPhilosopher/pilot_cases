# Case 001: substring search returns different failure indices

Both the original program and the generated program pass Dafny, but they do
not always return the same `(ok, index)` pair. For `source = "a"` and
`pattern = "b"`, the original returns `(false, 1)` and the generated program
returns `(false, 0)`.

## Problem

The method searches for `pattern` in `source`. The model was given the
following specification, with the method body removed:

```dafny
ghost predicate ContainsAtLeastOnce(source: string, pattern: string) {
  exists position ::
    0 <= position <= |source| &&
    pattern <= source[position..]
}

ghost predicate ResultCondition(
    source: string, pattern: string, ok: bool, index: nat) {
  (ok <==> ContainsAtLeastOnce(source, pattern)) &&
  (ok ==> index + |pattern| <= |source| &&
          pattern <= source[index..])
}

method ComputeWitness(source: string, pattern: string)
    returns (ok: bool, index: nat)
  ensures ResultCondition(source, pattern, ok, index)
```

Here `pattern <= source[position..]` means that `pattern` is a prefix of the
suffix beginning at `position`, so an occurrence starts there. The contract
requires `ok` to say whether an occurrence exists. When `ok` is true, `index`
must point to an occurrence.

Two choices are left unspecified: the contract does not require the first
occurrence when several exist, and it imposes no condition on `index` when
`ok` is false.

## What the two programs do

The original DafnyBench program searches using possible *end* positions:

```text
if pattern is empty, return (true, 0)
if source is shorter than pattern, return (false, 0)
for each possible end position, from left to right:
    compare pattern and source backwards, one character at a time
    if every character matches, return the corresponding start position
return (false, |source|)
```

The generated program searches using possible *start* positions:

```text
index := 0
for start := 0, 1, ..., |source|:
    if pattern is a prefix of source[start..]:
        return (true, start)
return (false, 0)
```

Writing `n = |source|`, `m = |pattern|`, and `k` for the first match, inspection
of the two bodies gives the complete comparison below.

| Input | Original | Generated |
|---|---|---|
| `m = 0` | `(true, 0)` | `(true, 0)` |
| `m > 0` and a match exists | `(true, k)` | `(true, k)` |
| no match and `n < m` | `(false, 0)` | `(false, 0)` |
| no match and `n >= m` | `(false, n)` | `(false, 0)` |

## Result

The concrete difference occurs on the smallest equal-length failed search:

```text
source = "a", pattern = "b"
original:  ok=false, index=1
generated: ok=false, index=0
```

The original checks the only possible location and then advances its search
position to `|source| = 1`. The generated program initializes `index` to zero
and leaves it unchanged when no match is found. Both results satisfy the
contract because the implication that constrains `index` applies only when
`ok` is true.

The verification and execution results were:

| Check | Result | Meaning |
|---|---|---|
| Original program, Dafny 4.3.0 | `12 verified, 0 errors` | The original satisfies its specification. |
| Generated program | `3 verified, 0 errors` | The generated program satisfies the same specification. |
| File containing both programs and the executable harness | `16 verified, 0 errors` | Both programs and the harness verify; this is **not** a proof that their results are equal. |
| Execution on `("a", "b")` | `(false,1)` versus `(false,0)` | A concrete input distinguishes the complete return values. |

## What this establishes

The two implementations are not equal as functions returning the complete
pair `(ok, index)`. Their Boolean results are equal for every input because
both verified programs must satisfy the same `ok <==> ContainsAtLeastOnce(...)`
condition.

Inspection of these particular method bodies also shows that they return the
same first match on success. Their complete pairs are equal exactly when

```text
ContainsAtLeastOnce(source, pattern) || |source| < |pattern|.
```

Equivalently, they behave the same if a caller ignores `index` after a failed
search. These general statements about the two algorithms come from checking
their branches; the current Dafny harness does not contain a relational proof
of them. The executed example is sufficient, however, to disprove equality of
the complete return values for all inputs.

To make exact tuple equality follow from the specification, the postcondition
would need to choose a failure index. It would also need a minimality condition
if returning the first occurrence, rather than any occurrence, is intended.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 001
```

This case is DafnyBench ID004. The model received the specification above and
necessary definitions, but not the original method body.
