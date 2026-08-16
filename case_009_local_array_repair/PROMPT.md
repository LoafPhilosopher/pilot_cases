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
class ArrayState {
  var data: array<int>

  constructor Create(input: array<int>)
    ensures this.data == input
  {
    this.data := input;
  }

  function EarlierPosition(position: int): int
  {
    if position == 0 then -1
    else if position % 2 == 0 then (position - 2) / 2
    else (position - 1) / 2
  }

  predicate GloballyOrdered(input: seq<int>)
  {
    forall i :: 0 <= i < |input| ==>
      (2 * i + 1 < |input| ==> input[i] >= input[2 * i + 1]) &&
      (2 * i + 2 < |input| ==> input[i] >= input[2 * i + 2])
  }

  predicate OrderedAwayFrom(input: seq<int>, position: int)
    requires 0 <= position
  {
    (forall i :: 0 <= i < |input| ==>
      (2 * i + 1 < |input| && i != position ==> input[i] >= input[2 * i + 1]) &&
      (2 * i + 2 < |input| && i != position ==> input[i] >= input[2 * i + 2])) &&
    (0 <= EarlierPosition(position) < |input| && 2 * position + 1 < |input| ==>
      input[EarlierPosition(position)] >= input[2 * position + 1]) &&
    (0 <= EarlierPosition(position) < |input| && 2 * position + 2 < |input| ==>
      input[EarlierPosition(position)] >= input[2 * position + 2])
  }

  method RepairAt(position: int) returns (next: int)
    modifies this, this.data
    requires 0 <= position < this.data.Length
    requires OrderedAwayFrom(this.data[..], position)
    ensures next == -1 || position < next < this.data.Length
    ensures next == -1 ==> GloballyOrdered(this.data[..])
    ensures position < next < this.data.Length ==>
      OrderedAwayFrom(this.data[..], next)
  {
    // Target body omitted for generation.
  }
}
```
