# Pilot case 003: repeated-value witnesses with different pair order

## Outcome

The generated implementation and DafnyBench ground truth both satisfy their
equivalent witness contracts, but they are not equivalent as raw ordered-pair
returning methods. The smallest permitted counterexample is:

```text
[0, 1, 1, 0]
```

The ground truth returns `(1, 0)`, while the generated implementation returns
`(0, 1)`.

ID 311 maps to:

`DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy`

## Formal-verification claims

Dafny 4.3.0 independently verifies the ground truth (`4 verified`), the
generated attempt (`18 verified`), and the combined comparison unit
(`23 verified`), all with zero errors. The combined command uses
`--verify-included-files`, so both included implementations and the harness are
verified.

The harness explicitly establishes that both displayed arrays satisfy both
methods' preconditions. For `[0,1,1,0]`, its length is four, every element is
in `[0, Length-2)`, and both `0` and `1` occur at least twice. The second array
similarly contains three duplicate values in the permitted range. Verification
also establishes each method's stated postcondition: its two returned values
are distinct duplicate witnesses.

These proofs do **not** establish either implementation's exact returned pair
or equality between their pairs. Neither postcondition specifies an ordering
rule, so those facts are unavailable to a modular caller.

## Runtime-counterexample claim

Running `comparison_harness.dfy` with the Python target printed:

```text
input:        [0, 1, 1, 0]
ground truth: (1, 0)
generated:    (0, 1)
```

This observed execution is a counterexample to raw ordered-pair equivalence.
It is not a Dafny proof of the exact outputs. On this input the unordered sets
of witnesses agree: both are `{0,1}`.

A second permitted input shows that the difference is not merely tuple order:

```text
input:        [0, 1, 2, 2, 1, 0]
ground truth: (2, 1)
generated:    (0, 1)
```

Here even the unordered witness sets differ: `{1,2}` versus `{0,1}`. Both are
legal because all three values occur twice and the contract asks for any two
distinct duplicate values.

## Code-inspection claims

The implementations select witnesses differently:

- The generated method performs two `i`-major, `j`-minor nested scans. It first
  returns the value of the lexicographically first equal-index pair, then
  restarts and finds the first equal pair with a different value. Thus it
  orders duplicate values by earliest first occurrence. Its runtime is
  quadratic and its nondeterministically chosen ghost witnesses are proof-only.
- The ground truth makes one left-to-right pass using an auxiliary first-seen
  table. It records the first value whose later occurrence is encountered,
  ignores further copies of that value, and returns on the first later
  occurrence of a different value. Thus it orders duplicate values by earliest
  second occurrence. Its runtime and auxiliary space are linear.

For `[0,1,1,0]`, `0` has the earlier first occurrence but `1` has the earlier
second occurrence, which reverses the returned order. The example is minimal
by array length: the shared precondition forbids every length below four, and
this length-four array satisfies all remaining preconditions.

For `[0,1,2,2,1,0]`, first-occurrence order begins `0,1,2`, while
second-occurrence order begins `2,1,0`; hence the implementations choose
different two-element subsets.

The ordering analysis, complexity statements, exact-output explanation, and
minimality argument in this section come from source/specification inspection;
they are not additional theorems proved in the harness.

## Conditions under which the implementations are equivalent

For these two concrete implementations, define two orders over the distinct
values that occur at least twice:

- **first-occurrence order** orders values by the index of their first
  occurrence; the generated implementation returns the first two values in
  this order;
- **second-occurrence order** orders values by the index at which their second
  occurrence is encountered; the ground truth returns the first two values in
  this order.

The implementations return the same raw ordered pair exactly when the first
two distinct duplicate values in these two orders are the same and occur in the
same order. This is a characterization of these implementations obtained by
code inspection; it is not a theorem established by the current Dafny harness.

A simpler sufficient input condition is:

1. exactly two distinct values occur at least twice; and
2. those two values have the same relative order by first occurrence and by
   second occurrence.

Under that condition, both methods return the same ordered pair. If condition
1 holds but condition 2 does not, the raw pairs may be reversed, as
`[0,1,1,0]` demonstrates.

Under a weaker observation relation, there is a broader guarantee: if exactly
two distinct values occur at least twice and the returned pair is treated as
an **unordered set**, both implementations return that same two-value set,
regardless of order. With three or more distinct duplicate values, even this
set equivalence is not guaranteed, as `[0,1,2,2,1,0]` demonstrates.

These are properties of the two current bodies, not consequences of the shared
contract alone. To make every contract-conforming implementation equivalent as
a raw ordered-pair function, the postcondition would need to prescribe a
canonical witness-selection and ordering rule—for example, the two smallest
duplicate values in increasing value order, or the first two duplicate values
under a formally specified occurrence order.

## Reproduction

From the project root:

```bash
./verifierbench/dafny verify \
  verifierbench/pilot_cases/case_003_repeated_value_pair/generated_attempt_01.dfy

./verifierbench/dafny verify \
  'verifierbench/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy'

./verifierbench/dafny verify --verify-included-files \
  verifierbench/pilot_cases/case_003_repeated_value_pair/comparison_harness.dfy

./verifierbench/dafny run \
  verifierbench/pilot_cases/case_003_repeated_value_pair/comparison_harness.dfy \
  -t:py
```

Concise outputs are recorded in `verification.txt`.
