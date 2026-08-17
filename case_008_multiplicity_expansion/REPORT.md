# Case 008: expanding integer multiplicities into a sequence

**Result: the generated program verifies and always returns the same multiset
of integers as the reference program. It is not guaranteed to return them in
the same sequence order.**

## Problem and specification

This task is DafnyBench ID119. Its input is a finite map from an integer to a
positive natural-number count. The method must return a sequence containing
each key exactly the number of times recorded in the map. For example,
`map[4 := 2, 9 := 1]` may be expanded to `[4, 4, 9]`, `[9, 4, 4]`, or another
permutation with the same multiplicities.

The generated program received the following essential specification:

```dafny
method ExpandRepresentation(counts: map<int, nat>)
    returns (values: seq<int>)
  requires forall key | key in counts.Keys :: counts[key] > 0
  ensures forall key | key in counts.Keys ::
    multiset(values)[key] == counts[key]
  ensures forall key | key in counts.Keys :: key in values
  ensures AbstractView(counts) == multiset(values)
```

Additional postconditions restate the same multiplicity and empty-map facts.
None of them fixes the position of any key in the returned sequence.

### Synthesis task and supplied context

The only data argument is `counts`, and the runtime output is `values`. The
enclosing `CountRepresentation` object has no fields. The agent was given the
class declaration, the bodyless `AbstractView` function and
`RepresentationAgreement` lemma, and the `ExpandRepresentation` signature and
contract, with the target body omitted. The function and lemma are
specification and proof context, not additional runtime inputs. The recorded
prompt contains no reference body, test case, example output, or required key
order ([`PROMPT.md`](PROMPT.md)).

The synthesis task was to return a sequence with the required multiplicities,
not to recover the reference program's enumeration order.

## Reference and generated algorithms

The reference starts with an empty sequence and a set containing all map keys.
It chooses an arbitrary remaining key using Dafny's `:|` operator, appends
that key `counts[key]` times, removes the key from the set, and repeats.

The generated program uses the same outline. Its outer-loop invariants divide
keys into processed and remaining sets, while the inner-loop invariants count
the copies of the current key already appended. The generated proof also shows
that no integer outside the map is introduced.

Because selection from the key set is nondeterministic, neither body promises
the same enumeration order on every execution.

## Evidence

Dafny 4.3.0 reports:

```text
Reference program: 27 verified, 0 errors
Generated program:  4 verified, 0 errors
Comparison proof:  37 verified, 0 errors
```

The comparison calls both actual methods with the same map. For every integer,
it proves that the two returned sequences contain that integer with the same
multiplicity. Keys in the map occur exactly as often as their recorded counts;
keys outside the map occur zero times. This proves equality of the complete
result multisets for arbitrary permitted maps.

Raw sequence equality is different. For the concrete input

```text
map[1 := 1, 2 := 1]
```

the sequences `[1, 2]` and `[2, 1]` are unequal, but Dafny proves that both
satisfy every return postcondition of both versions. This is a proof about
what both specifications permit; the harness does not call the methods and
observe these two orders. Inspection of the saved bodies shows that each uses
the nondeterministic `:|` operator to choose the next map key, so neither body
fixes one enumeration order.

## What is and is not established

The multiset equality result is a proof for maps of any finite size, not a
finite test. The two-order example is a machine-checked contract witness. The
claim that the retained bodies also leave the order open uses the source-level
fact that both make a nondeterministic key choice; it is not a recorded run in
which the methods happened to return different orders.

Both files contain a bodyless abstraction function (`A` in the reference and
`AbstractView` in the generated context) whose contract connects a count map
to a multiset. The comparison uses those declared contracts, which were
already part of the task context. It does not assume a fixed runtime order for
iterating over map keys.

## Reproduce

From the repository root:

```bash
./reproduce.sh --case 008
```
