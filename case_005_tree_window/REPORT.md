# Case 005: extracting part of a tree-structured string

Dafny proves that the reference and generated programs return the same string for every valid interval on corresponding trees.

## Problem

The input object represents a string as a tree. A leaf stores a nonempty text
chunk. An internal node represents the concatenation of its children; it may
also have only a left child or only a right child. A ghost field called `Model`
records the complete abstract string, and `pivot` is the length of the left
part when a left child exists. The well-formedness predicate connects the
tree's fields to that abstract string and ensures that recursive calls move to
smaller, disjoint subtrees.

The target method receives a half-open interval `[start, stop)` and must return
that part of the represented string:

```dafny
method ExtractWindow(start: nat, stop: nat) returns (out: string)
  requires 0 <= start <= stop <= |this.Model|
  requires WellFormed()
  ensures out == this.Model[start..stop]
  decreases Footprint
```

This is not implemented by simply returning `Model[start..stop]`, because
`Model` is a ghost field and is unavailable to executable code. The program
must navigate the concrete tree, translate indices when it moves to the right
child, combine two recursive results when an interval crosses the pivot, and
prove that every slice and recursive call is valid.

## What the reference and generated programs do

The reference program first handles an empty interval. For a nonempty
interval, it uses the following recursion:

```text
if this is a leaf: return the requested slice of its chunk
if stop <= pivot: recurse into the left child
if pivot <= start: recurse into the right child with both indices minus pivot
otherwise: concatenate the left suffix [start, pivot)
           and the right prefix [0, stop - pivot)
```

The generated program reaches the same decomposition but organizes its cases
differently. It first distinguishes all four possible child configurations.
A leaf slices its chunk; a one-child node delegates to that child; and a
two-child node selects the left, right, or crossing case. It includes explicit
equalities relating slices of `first.Model + second.Model` to slices of the two
children so that Dafny can prove the postcondition.

## Result and evidence

Dafny 4.3.0 reports:

```text
Reference program:   21 verified, 0 errors
Generated program:    3 verified, 0 errors
Comparison file:     26 verified, 0 errors
```

The two source files use different class and field names. The comparison file
takes one valid reference object and one well-formed generated object, assumes
that they denote the same abstract string, and supplies the same `start` and
`stop` values to both methods:

```dafny
requires reference.Contents == generated.Model
requires 0 <= start <= stop <= |reference.Contents|
ensures referenceOut == generatedOut
```

It calls both actual implementations. The reference contract gives
`referenceOut == reference.Contents[start..stop]`, while the generated
contract gives `generatedOut == generated.Model[start..stop]`. Since the two
abstract strings are equal, Dafny proves that the returned strings are equal.
The argument covers every valid tree pair and every permitted interval; it is
not based on a finite set of test inputs.

## What is proved and what is not

The proof establishes equality of the complete executable return value under
the natural input correspondence: both tree objects represent the same string
and receive the same interval. This includes empty intervals, leaf slices,
one-child nodes, and intervals lying on either side of or crossing a pivot.

It does not claim that the two heap objects are identical or that their trees
have the same shape. Those properties are neither required nor relevant to
this read-only operation. The equality proof follows from the two verified
postconditions; the source comparison explains how each implementation
computes the required slice but is not needed as an additional assumption.

## Reproduce

Run `./reproduce.sh --case 005` from the repository root.
