# Extension case 006: selecting a minimum entry

## Sources and frozen observation

- Generated attempt: `generated_attempt_01.dfy`
- DafnyBench ID010 reference:
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/CS5232_Project_tmp_tmpai_cfrng_LFUSimple.dfy`
- Relational proof: `comparison_harness.dfy`

The alpha-renaming relates reference `cacheMap` to generated `table`.  The
observable state is unchanged and the returned integer is compared directly
when the minimum frequency is unique.  With a tied minimum, raw keys are
reported separately and the primary relation accepts either globally minimal
key, exactly as frozen in `PREGENERATION.md`.

## Result

**Proved equivalent under the primary frozen relation.  Raw equality is proved
when the minimum is unique and is not guaranteed when it is tied.**

`ImplementationsMeetFrozenRelation` calls the actual reference and generated
methods on related maps.  Dafny proves, for arbitrary coherent nonempty maps,
that both returned keys satisfy `IsMinimumEntry`.  It also proves that
`MinimumEntryIsUnique` implies equality of the two returned integers.  This is
an unbounded relational proof, not bounded testing.

`TiedMinimumWitness` gives a concrete raw-output counterexample state:

```text
map[10 := (100, 1), 20 := (200, 1)]
```

Both `10` and `20` satisfy the complete observable minimum condition, yet
`10 != 20`.  Both source bodies use nondeterministic choice over a finite set,
so separate executions may choose different tied minima.  The harness proves
the two keys are admissible results; it does not misdescribe this as a sampled
runtime trace.

## Verification

With pinned Dafny 4.3.0:

```text
Reference:          8 verified, 0 errors
Generated attempt:  3 verified, 0 errors
Combined harness:  15 verified, 0 errors
```

The reference warnings concern deprecated semicolons and its pre-existing
`exists ... ==> ...` quantifier form.  They are not verification errors.  An
anti-bypass scan of the generated file found no `assume`, `{:verify false}`,
`{:axiom}`, `{:extern}`, or `decreases *`.

## Protocol deviation

This result **must not be counted as a protocol-conforming sample**.  Before
returning the saved code, the isolated generation agent sent one outbound
progress message.  That violates the frozen zero-call/code-only condition.
There were no Web, filesystem, function-tool, or custom-tool calls, and the
first attempt was retained without retry or replacement.  The exact message
is preserved in `protocol_deviation.txt`; provenance is recorded in
`provenance/extension_manifest.json`.

## Classification

```text
PRIMARY RELATION: PROVED-EQUIVALENT
RAW INTEGER:      PROVED EQUAL UNDER UNIQUE MINIMUM;
                  CONCRETE TIED-MINIMUM DIVERGENCE WITNESS OTHERWISE
PROTOCOL:         DEVIATING (excluded from conforming counts)
```

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 006
```
