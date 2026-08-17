# Case 011: appending one item to a verified queue

After matching the old cells and treating the two newly allocated cells as
corresponding, the reference and generated programs produce the same queue
contents, links, and recorded ownership. One part of this conclusion depends
on a manual check that the mathematical summaries in the comparison file
match the two source bodies.

## Problem given to the model

This is DafnyBench ID309. The program represents a queue by a first cell, a
last cell, a set of cells, ownership sets, and a ghost sequence `model`. Each
cell stores a value, a successor, a ghost suffix, and its own ownership set.
The consistency predicate connects all of these fields. In particular, the
last cell has no successor and `model` is the suffix stored at the first cell.

The model received the class definitions and the following method contract,
but not the reference implementation:

```dafny
method UpdateStructure(item: T)
  requires Consistent()
  modifies owned
  ensures Consistent() && fresh(owned - old(owned))
  ensures model == old(model) + [item]
```

Thus it had to allocate and connect a new cell, update the ghost state needed
by `Consistent`, and prove that the abstract queue gained exactly `item`.

## What the two programs do

The reference `Queue.Enqueue` performs the following steps:

```text
allocate a new node and store item in it
set the old tail's next pointer to the new node
make the new node the tail
append item to every old node's ghost suffix
add the new node's ownership set to every old node
extend the queue-level contents, footprint, and node set
```

The generated `Buffer.UpdateStructure` performs the same state changes. Its
proof is much longer: it first records maps of all old fields, links the new
cell, and then uses a ghost work-set loop to update each old cell exactly once.
It finally rebuilds the queue-level sets and assigns `model` from the first
cell's updated suffix. The difference is therefore in proof organization, not
in the resulting queue.

## Comparison and Dafny results

Two independent executions cannot have equal object addresses, because each
allocates its own new cell. The comparison therefore gives every pre-existing
cell a stable integer identifier and gives the one newly allocated cell the
same fresh identifier in both executions. Under these identifiers, the
comparison records the first and last cells, all cells and owned objects, each
value and successor, every ghost suffix and cell ownership set, and the
abstract sequence. It also records that the only old successor changed is the
old last cell's successor.

Under this numbering, the two described post-states are equal for every valid
input queue, appended value, and unused fresh identifier. Dafny 4.3.0 reports:

```text
Reference program:    18 verified, 0 errors
Generated program:     6 verified, 0 errors
Combined comparison:  35 verified, 0 errors
```

The equality proof shows that both normalized queues have the old first cell,
the same newly mapped last cell, the old abstract sequence followed by
`item`, identical old values and links except for the tail link, and identical
updated ghost summaries.

## What is and is not established

The public method contract alone guarantees only a valid queue and the updated
abstract sequence. It does not uniquely determine all pointers and ownership
sets. The comparison file therefore defines the complete state change visible
in each retained source body and proves those two definitions equal.

Dafny checks equality of the two state-change definitions for arbitrary
queues. Matching each field in those definitions to the assignments in the
two retained method bodies is the manual step. The conclusion therefore
applies to these two bodies; the short public contract alone would also permit
other pointer and ownership arrangements.

## Reproduction

```bash
./reproduce.sh --case 011
```
