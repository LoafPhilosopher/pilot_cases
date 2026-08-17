# Conclusion

After repairing only the four failed first attempts, **7 cases are equivalent
to the reference under the comparison used here, 5 have a concrete behavioral
counterexample, and 3 are equivalent only under an additional condition.**

Cases 007, 011, and 015 use a machine-checked abstract relation plus a disclosed
source-audited bridge; they are not single end-to-end automatic relational
proofs. No case exhausted the three-round repair budget.

| Classification | Count | Cases |
|---|---:|---|
| Equivalent under the current comparison | 7 | 002, 004, 005, 007, 011, 013, 015 |
| Concrete counterexample; behavior differs | 5 | 001, 003, 009, 010, 012 |
| Equivalent only under an additional condition | 3 | 006, 008, 014 |
| Repair exhausted without a verifier-passing program | 0 | None |

The five counterexamples and three conditional results come from these missing
parts of the supplied specifications:

- **001:** when `ok == false`, the returned `index` is unconstrained. The
  specification also does not require the earliest occurrence.
- **003:** the specification does not choose which two repeated values to
  return or fix their order.
- **006:** when several keys have the same minimum frequency, the
  specification does not choose one key.
- **008:** the specification fixes element multiplicities but not their order
  in the returned sequence.
- **009:** the specification does not preserve the input values or their
  multiset, and it does not restrict the repair to a local swap.
- **010:** the specification fixes the reversed sequence of values, but not
  the returned node, the reversed links, the value attached to each old node,
  or what aliases to those nodes observe.
- **012:** when `promised == false`, the return value is unconstrained.
- **014:** when several maximum windows tie, the ghost interval endpoints are
  not uniquely determined. The executable maximum length is still the same.

The first-attempt result remains **11 verifier-pass programs out of 15**. The
later repair outcomes were:

| Case | Saved repair history | Comparison of the first passing repair |
|---|---|---|
| 002 | Round 01 passed | Equivalent: the complete transition trace is equal. |
| 009 | Round 01 failed; Round 02 passed | Not equivalent: on `[7]`, the reference keeps `[7]` and the repair produces `[0]`. |
| 010 | Round 01 passed | Not equivalent: it reverses node values instead of links. |
| 013 | Round 01 passed | Equivalent: the recovered abstract state and complete array contents are equal. |

All failed programs, feedback, and intermediate repair rounds remain in their
case directories. The repair procedure is described in
[`REPAIR_PROTOCOL.md`](REPAIR_PROTOCOL.md).
