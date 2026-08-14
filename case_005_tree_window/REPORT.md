# Pilot case 005: extracting an interval from a tree-structured string

## Outcome

The untouched first generation passes Dafny and is output-equivalent to the
hidden DafnyBench reference under the natural representation relation: the two
input objects denote the same abstract string and receive the same interval.
The combined harness proves this for every well-formed pair of inputs and every
permitted interval:

```text
Dafny program verifier finished with 26 verified, 0 errors
```

This is a general, unbounded relational proof rather than bounded testing.

The hidden reference is DafnyBench ID491:

`third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafny-rope_tmp_tmpl4v_njmy_Rope.dfy`

Its target is the original `report` method. The source supplied for generation
renames the module, class, fields, invariant, and target method, and removes the
reference body, all other methods, constructors, comments, examples, and source
identifiers.

## Why this is a non-trivial programming task

The input is a heap-allocated tree whose leaves store nonempty string chunks.
Internal nodes describe concatenation through two nullable children and a
concrete split position. The target must materialize an arbitrary half-open
interval of the abstract string. A correct executable body has to handle:

- an empty interval;
- a leaf chunk;
- one-child nodes;
- an interval contained entirely in either child; and
- an interval crossing the split point, including offset translation and
  concatenation of two recursive results.

It must also prove that recursive calls decrease by the representation set and
that all translated slice bounds are safe. The abstract `Model` field is ghost,
so it cannot be copied into the executable return value. Unlike the superseded
ID771 case, the prompt exposes no executable specification function that
computes the answer.

## Isolated generation and verification

The generator was instructed to make no Web, network, tool, filesystem, or
other-agent calls. The structured session log records zero such calls before
the first and only code response. The reference implementation was not in the
generator's context.

The saved program is the first returned Dafny content, with only a final newline
added when it was written to disk. It was not repaired before verification and
contains none of the screened verification bypasses or output side effects.

Using Dafny 4.3.0:

```text
Hidden reference:       21 verified, 0 errors
Generated attempt:       3 verified, 0 errors
Combined harness:       26 verified, 0 errors
```

Warnings in the reference concern deprecated unnecessary semicolons; they are
not verification errors.

## Relational equivalence proof

`comparison_harness.dfy` calls both concrete implementations and proves their
returned strings equal under these conditions:

```dafny
reference.Valid()
generated.WellFormed()
reference.Contents == generated.Model
0 <= start <= stop <= |reference.Contents|
```

The two contracts yield:

```dafny
referenceOut == reference.Contents[start..stop]
generatedOut == generated.Model[start..stop]
```

The representation relation equates the two abstract strings, so the outputs
are equal. This also explains why the result is determined without assigning a
pre-existing “strong” or “weak” label: for a fixed abstract input and interval,
the postcondition permits exactly one observable string.

The theorem does not claim that a reference heap object and a renamed generated
heap object are pointer-identical. They belong to different modules and are
related through their abstract string views, which is the relevant input
observation for this read-only method.

## Implementation comparison

Both programs discover the natural recursive decomposition implied by the
representation invariant, but the generated body is independently expressed:

- the reference treats the empty interval first, then distinguishes a leaf
  from internal nodes and dispatches left, right, or across the split;
- the generation first expands all nullable-child shapes, then treats the
  two-child case with three interval positions and explicit sequence-slice
  equalities.

Their structural similarity is explainable from the contract and data
representation and is not evidence that training contamination has been
eliminated. Name masking only reduces obvious benchmark fingerprints.

## Reproduction

From this repository root:

```bash
./reproduce.sh --case 005
```

Historical results and isolation evidence are preserved in `verification.txt`.
