# Case 006: selecting a minimum-frequency map entry

**Result: the generated program verifies and always returns a valid
minimum-frequency key, as does the reference program. The two returned keys
are guaranteed to be equal only when that minimum is unique.**

## Problem and specification

This task comes from DafnyBench ID010. The object stores a finite map from an
integer key to a pair `(value, frequency)`. The map is nonempty when the method
is called, and every stored frequency is positive. The method must return a
key whose frequency is no greater than the frequency of any other entry. It
does not change the map.

The generated program received the following essential contract, with neutral
names and without the reference method body:

```dafny
method ChooseEntry() returns (selected: int)
  requires Coherent()
  requires |table| > 0
  ensures Coherent()
  ensures selected in table
  ensures forall item :: item in table.Items ==>
    table[selected].1 <= table[item.0].1
```

Here `.1` is the frequency component of a map entry. The contract says which
keys are acceptable, but it does not specify how to choose between keys with
the same minimum frequency.

### Synthesis task and supplied context

The runtime input is the receiver object, whose state includes `capacity` and
`table`. `ChooseEntry` has no explicit argument. Its only output is `selected`.
The agent was given the class and field declarations, the definition of
`Coherent`, and the `ChooseEntry` signature and contract, with the target body
omitted. These declarations are supplied context, not additional runtime
inputs. The recorded prompt contains no reference body, test case, example
output, or prescribed minimum-frequency key ([`PROMPT.md`](PROMPT.md)). The
original filename was separately visible in platform metadata, as disclosed
below.

The synthesis task was to implement any body that returns a minimum-frequency
key allowed by the contract, not to recover the reference program's
tie-breaking choice.

## Reference and generated algorithms

The reference method chooses an arbitrary first entry, records its key and
frequency, and repeatedly removes an arbitrary entry from a set of unprocessed
entries. Whenever it sees a smaller frequency, it replaces the current
candidate.

The generated method follows the same general approach. It chooses an
arbitrary initial key, iterates over the remaining keys, and replaces the
candidate only when it finds a strictly smaller frequency. Its loop invariants
record that the candidate is no worse than every key already processed. Both
programs therefore leave tie-breaking to Dafny's nondeterministic choice
operator `:|`.

## Evidence

Dafny 4.3.0 reports:

```text
Reference program:  8 verified, 0 errors
Generated program:  3 verified, 0 errors
Comparison proof:  15 verified, 0 errors
```

The comparison calls both methods on objects with equal maps. For every
nonempty coherent map, Dafny proves that each returned key is in the map and
has globally minimum frequency. It also proves that, if only one key has the
minimum frequency, the two results must be that same key.

For a tied minimum, exact key equality does not follow. Consider:

```text
map[10 := (100, 1), 20 := (200, 1)]
```

The comparison proof checks that both `10` and `20` satisfy the complete
return condition and that they are different. This proof alone shows what the
specification permits; it does not call the two methods and obtain different
keys. Inspection of the two bodies adds the relevant implementation fact:
both select keys with Dafny's nondeterministic `:|` operator and neither fixes
a tie. Their executions may therefore choose different minimum keys, although
no sampled compiled run is presented as such a counterexample.

## What is and is not established

The minimum-entry behavior is proved for arbitrary permitted maps, and exact
key equality is proved under a unique minimum. With tied minima, the two-key
example is a machine-checked specification witness; the conclusion that the
saved bodies may choose differently also uses the direct body inspection just
described.

This run also has two execution issues. Before returning the code, the
generation agent sent one progress message to another agent, contrary to the
instruction not to contact other agents. It did not access the Web or any
file, and the first code response was kept without a retry. In addition, the
original filename `LFUSimple.dfy` was visible in platform metadata, although
the reference body was not. This case therefore cannot be used as a clean test
of whether neutral renaming prevented recognition of the source task.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 006
```
