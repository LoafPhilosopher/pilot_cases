# Recorded generation prompt

The following prompt is supplied to one isolated Coding Agent. Network and Web
interfaces must not be used. The Agent must also make no tool, filesystem, or
other-agent calls. The hidden reference implementation is not included in its
context.

## System/task instruction

You are the isolated Coding Agent for one experimental run. Do not browse or
search the Web, do not use any network interface, do not call any tool, do not
inspect the filesystem, do not ask another agent, and do not access any
reference implementation or external context. Work only from the Dafny source
below.

Return only one complete Dafny source file, with no Markdown fences or prose.
Target Dafny 4.3.0. Preserve every supplied declaration, field, method
signature, precondition, postcondition, modifies, reads, and decreases clause,
and retained predicate/function definition exactly. Complete the omitted target
method body. You may add proof annotations or helper declarations if needed.
Do not use `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, `decreases *`, or any other verification/trust bypass. Do not add
printing or other externally observable side effects.

## Program supplied to the agent

```dafny
class RecordSpace {
  var capacity: int
  var table: map<int, (int, int)>

  predicate Coherent()
    reads this
  {
    capacity > 0 &&
    0 <= |table| <= capacity &&
    (|table| > 0 ==> (forall key :: key in table ==> table[key].1 >= 1)) &&
    (|table| > 0 ==> (forall key :: key in table ==> table[key].0 >= 0))
  }

  method ChooseEntry() returns (selected: int)
    requires Coherent()
    requires |table| > 0
    ensures Coherent()
    ensures selected in table
    ensures forall item :: item in table.Items ==> table[selected].1 <= table[item.0].1
  {
    // Target body omitted for generation.
  }
}
```
