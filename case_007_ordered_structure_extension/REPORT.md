# Case 007: inserting an integer into an ordered tree

**Result: Dafny directly proves that calls to the two methods return the same
set of integers. Their tree shapes are also equal in machine-checked copies of
the executable branches; a manual check connects those copies to the two
source bodies.**

## Problem and specification

This task is DafnyBench ID107. A tree is either empty or a node containing an
integer and two subtrees. Its `Layout` is the inorder traversal. A tree is
`Structured` when this traversal is strictly increasing, so it represents a
binary search tree with no duplicate values.

The model saw these definitions and this contract, but not the reference body:

```dafny
method ExtendStructure(base: Structure, item: int)
    returns (result: Structure)
  requires Structured(base) && item !in ValuesOf(base)
  ensures Structured(result)
  ensures ValuesOf(result) == ValuesOf(base) + {item}
```

Thus the result must remain ordered and contain exactly the old values plus
`item`. The contract does not itself prescribe a unique tree shape. For
example, a root `1` with right child `2` and a root `2` with left child `1`
are both ordered trees containing `{1, 2}`.

## Reference and generated algorithms

The reference method performs ordinary recursive binary-search-tree
insertion. On an empty tree it creates a leaf containing `item`. At a node, it
recurses into the left subtree when `item` is smaller than the node value and
into the right subtree otherwise, then rebuilds that node around the returned
subtree.

The generated method uses exactly those executable branches. Most of its
length consists of Dafny lemmas showing that inorder sequences remain strictly
increasing and that the value set changes as required. These proof statements
do not change the returned tree.

## Evidence

Dafny 4.3.0 reports:

```text
Reference program: 14 verified, 0 errors
Generated program: 11 verified, 0 errors
Comparison proof:  38 verified, 0 errors
```

There are two parts to the comparison. First, a datatype conversion maps the
reference constructors `Empty` and `Node` to the generated constructors
`Blank` and `Piece`. Dafny proves that the conversion preserves the inorder
sequence, the ordering predicate, and the set of stored values. Calling the
two actual methods then proves that their result sets are equal for every
permitted tree and inserted integer.

Second, the comparison writes each method's executable statements as a pure
recursive function. Both functions insert a leaf at an empty position, take
the same comparison branch, and rebuild the same node. Structural induction
proves that the two functions return identical tree shapes after constructor
renaming. Clone methods containing those executable statements also verify
against the pure functions.

## What is and is not established

Equality of the abstract value sets is machine-checked directly for calls to
the two actual methods. Equality of tree shape has a small additional step:
the executable projections were manually copied from the two included method
bodies because Dafny does not automatically turn a method body into a pure
function for relational reasoning. Dafny checks the projections, their clone
methods, and their equality for trees of any size; a human check connects each
projection to the corresponding source body. The contract alone would prove
only equal value sets, not equal shapes.

The original filename `BST.dfy` was visible in platform metadata during
generation. The method body was not visible, and the generation made no Web,
file, tool, or inter-agent calls. Even so, this case cannot independently show
that renaming the declarations prevented recognition of the original task.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 007
```
