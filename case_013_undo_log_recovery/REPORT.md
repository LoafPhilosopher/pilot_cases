# Case 013 — generation outcome

This is one of the ten prospectively frozen extension tasks. Exactly one
response was generated and preserved. Its log records the requested model and
reasoning effort and zero Web, network, filesystem, tool, or other-agent calls
before the final response.

## Outcome

The candidate reconstructs the intended reverse-log loop and extensive ghost
invariants from the denotational final-state specification. Dafny 4.3.0 verifies
six declarations but rejects two concrete array writes: `values[offset] :=
restored` and `records[0] := 0` are not justified by the enclosing loop/method
modification context as written. The final result is `6 verified, 2 errors`.

This failure is evidence that removing the executable reverse-recovery helper
did not make the programming task trivial: the model inferred the recovery
order and value relation, but did not complete the heap-frame proof. The
bodyless ghost function supplied only the uniquely determined final abstract
state, not the traversal algorithm.

## Comparison gate

Not entered. The candidate was not repaired, retried, or replaced. Therefore
neither the full relation (including preservation of the two original array
references and caller-held aliases) nor its weaker value-level relation is
classified against the hidden reference.

## Reproduction

From the repository root:

```bash
./reproduce.sh --case 013
```
