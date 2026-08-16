# Case 011: queue extension preserves the complete frozen heap observation

## Outcome

**Classification: `proved-equivalent`.** For the same valid initial queue and
the same appended value, the generated `Buffer.UpdateStructure` and hidden
DafnyBench `Queue.Enqueue` have the same final observation under the relation
frozen before generation. Fresh objects are compared up to a bijection that
fixes every pre-existing object.

The untouched generation, pinned reference, and combined comparison unit all
verify with Dafny 4.3.0:

```text
Hidden reference:       18 verified, 0 errors
Generated attempt:       6 verified, 0 errors
Combined harness:       35 verified, 0 errors
```

The comparison theorem is symbolic and unbounded; it does not enumerate queue
sizes or values.

## Sources compared

- DafnyBench ID309 at pinned commit
  `0cd28feed9cd0179b07fdb9d002f8c39063658e4`;
- hidden target `Queue<T>.Enqueue` in
  `third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_Queue.dfy`;
- frozen target `Buffer<T>.UpdateStructure` in `generated_attempt_01.dfy`; and
- relational artifact `comparison_harness.dfy`.

The generated file has SHA-256
`6b9f0f9d5e3a6988a775d8205223b5a798628a784f0e4330028366187cffaa48`.
The pinned reference file has SHA-256
`55e9bb47973f2ffcaa9d00dc4b2f29981efbefdaee832a1633d28723d7597f66`.

## Exact transition comparison

After applying the frozen aliases, both concrete bodies perform the same state
transition:

1. allocate exactly one fresh cell using the retained constructor, whose
   successor is null, suffix is empty, and ownership set is the singleton
   containing that cell;
2. assign the new cell's value to the appended item;
3. change the old last cell's successor to the new cell, leaving every other
   pre-existing concrete pointer and every old cell value unchanged;
4. append the item to every old cell's ghost suffix and add the new singleton
   ownership set to every old cell's ownership set;
5. retain the first cell, make the new cell the last cell, add it to the chain
   and queue ownership set, and set the abstract model to the old model plus
   the item.

The generated program uses a ghost work-set loop where the reference uses two
`forall` statements, and it performs some ghost assignments in a different
order. Each old cell is nevertheless updated exactly once, and the final
concrete and ghost states are identical after identity normalization.

## Coverage of the frozen observation relation

`FrozenObservationsAgree` represents corresponding old objects by the same
integer identity and gives the two fresh cells one shared fresh identity. It
proves equality of a record containing:

- the full abstract sequence;
- first and last identities, the complete cell set, every cell value, every
  successor, and the last cell's null successor;
- every per-cell suffix and ownership set, plus the queue ownership set;
- the set of newly allocated objects; and
- the set of pre-existing cells whose concrete successor field is written,
  namely the singleton containing the old last cell.

Thus the theorem covers all four observations fixed in `PREGENERATION.md`, not
only abstract-sequence equality. Old identities are unchanged, and the fresh
bijection extends the old bijection by mapping the one new reference node to
the one new generated cell.

## Proof boundary

Dafny verifies both included source files and proves equality of the two
normalized transition functions for every complete symbolic snapshot and
fresh identity. The extraction of those transition functions from the two
imperative bodies is transparent in `comparison_harness.dfy` and was checked
statement by statement as listed above, but Dafny does not automatically inline
the heap methods into that algebraic theorem. The machine-checked claim is the
unbounded transition equality; correspondence between each extracted field
update and its source statement is a source-audit obligation.

This qualification matters because the public postcondition by itself fixes
only the abstract model. It would permit other verifier-passing implementations
with different fresh topologies. The `proved-equivalent` result applies to
these two retained concrete bodies, not to every program satisfying the same
contract.

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 011
```

The exact commands and observed results are preserved in `verification.txt`.
