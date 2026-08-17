# Case 004: arranging four kinds

Dafny proves that the reference and generated programs return the same sequence, after matching the four renamed constructors.

## Problem

The input is a nonempty sequence whose elements come from four constructors,
renamed `K0`, `K1`, `K2`, and `K3` in the generated task. They have the order

```text
K0 < K1 < K2 < K3.
```

The method must rearrange the input into this order without adding or removing
elements. Its essential specification is:

```dafny
datatype Kind = K0 | K1 | K2 | K3

predicate ValidArrangement(items: seq<Kind>) {
  forall j, k :: 0 <= j < k < |items| ==>
    AllowedPair(items[j], items[k])
}

method Transform(items: seq<Kind>) returns (result: seq<Kind>)
  requires 0 < |items|
  ensures |result| == |items|
  ensures ValidArrangement(result)
  ensures multiset(result) == multiset(items)
```

`AllowedPair(a, b)` is true exactly when `a` is no later than `b` in the order
above. Consequently `ValidArrangement` requires every earlier element of the
result to be less than or equal to every later element. The multiset clause
preserves the number of occurrences of each constructor.

### Synthesis task and supplied context

The only runtime input is `items`. The runtime output is `result`. The agent
was given the `Kind` datatype, the complete definitions of `AllowedPair` and
`ValidArrangement`, and the `Transform` signature and contract, with the target
body omitted. These declarations define the input type and specification. They
are not additional method inputs. The recorded prompt contains no reference
datatype or body, constructor-name correspondence, test cases, example
outputs, or required sorting algorithm ([`PROMPT.md`](PROMPT.md)).

The synthesis task was to implement and verify any transformation that returns
the specified ordered permutation, not to reconstruct the reference
partitioning algorithm.

## What the reference and generated programs do

The reference program uses four moving regions, in the style of the Dutch
national flag algorithm. It scans an unclassified part of the sequence and
swaps the current element into the region belonging to its constructor. The
four reference constructors are named `A`, `C`, `G`, and `T`; they correspond
respectively to `K0`, `K1`, `K2`, and `K3`.

The generated program defines numeric ranks from zero to three and implements
functional insertion sort:

```text
Sort([]) = []
Sort(head + tail) = Insert(head, Sort(tail))
Insert(x, sorted) places x before the first element whose rank is at least x's
```

It supplies recursive lemmas showing that insertion preserves sortedness,
length, and the multiset. The algorithms are structurally different: one
partitions with swaps, while the other recursively constructs a sorted
sequence.

## Result and evidence

Dafny 4.3.0 reports:

```text
Reference program:   6 verified, 0 errors
Generated program:  18 verified, 0 errors
Comparison file:    49 verified, 0 errors
```

The central lemma in the comparison file proves that two valid arrangements
with the same multiset must be equal. The reason is simple. The first element
of each valid arrangement is no greater than any other element. Since the two
sequences contain the same elements, their first elements must have the same
rank and therefore be the same constructor. Removing that common first
element leaves two valid tails with the same multiset. Repeating the argument
proves that the complete sequences are equal.

The comparison then calls both actual methods and converts the reference
result from `A/C/G/T` to `K0/K1/K2/K3`. Dafny proves that this converted
reference result equals the generated result for every permitted input, not
only for a collection of examples.

## What is proved and what is not

The machine-checked conclusion covers sequences of arbitrary length and any
multiplicity of the four constructors. It establishes equality of the complete
returned sequence under the stated constructor renaming. The proof works
because the ordering and multiset conditions allow only one result.

The result does not say that the two implementations use the same algorithm or
have the same running time. It also does not compare the internal proof lemmas
line by line. Those differences are irrelevant to the returned sequence: once
both methods satisfy this contract, their outputs are forced to agree.

## Reproduce

Run `./reproduce.sh --case 004` from the repository root.
