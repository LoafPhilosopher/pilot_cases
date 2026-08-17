# Conclusion before repair

Among the 15 first attempts, 5 are equivalent to the original programs under
the comparison used in this study, 3 have concrete behavioral
counterexamples, 3 are equivalent only under an additional condition, and 4
failed verification and are awaiting repair.

| Classification | Count | Cases |
|---|---:|---|
| Equivalent under the current comparison | 5 | 004, 005, 007, 011, 015 |
| Concrete counterexample; behavior differs | 3 | 001, 003, 012 |
| Equivalent only under an additional condition | 3 | 006, 008, 014 |
| First attempt failed verification; awaiting repair | 4 | 002, 009, 010, 013 |

The non-equivalent or conditional cases are explained by specific omissions in
the supplied specifications:

- **001:** when `ok == false`, the returned `index` is unconstrained. The
  specification also does not require the earliest occurrence.
- **003:** the specification does not choose which two repeated values to
  return or fix their order.
- **006:** when several keys have the same minimum frequency, the
  specification does not choose one key.
- **008:** the specification fixes element multiplicities but not their order
  in the returned sequence.
- **012:** when `promised == false`, the return value is unconstrained.
- **014:** when several maximum windows tie, the ghost interval endpoints are
  not uniquely determined. The executable maximum length is still the same.

Cases 002, 009, 010, and 013 will be repaired under
[`REPAIR_PROTOCOL.md`](REPAIR_PROTOCOL.md). This table will be updated only
after the saved repairs have been verified and compared with their hidden
references.
