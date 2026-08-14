# Exact generation prompt

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
signature, precondition, postcondition, and decreases clause exactly. Complete
the omitted target method body. You may add proof annotations or helper
declarations if needed. Do not use `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, `decreases *`, or any other verification/trust bypass. Do not add
printing or other externally observable side effects.

## Program supplied to the agent

```dafny
module StructuredStore {
  class NodeStore {
    ghost var Model: string
    ghost var Footprint: set<NodeStore>

    var chunk: string
    var pivot: nat
    var first: NodeStore?
    var second: NodeStore?

    ghost predicate WellFormed()
      reads this, Footprint
      ensures WellFormed() ==> this in Footprint
    {
      this in Footprint &&
      (first != null ==>
        first in Footprint &&
        first.Footprint < Footprint && this !in first.Footprint &&
        first.WellFormed() &&
        (forall child :: child in first.Footprint ==> child.pivot <= pivot)) &&
      (second != null ==>
        second in Footprint &&
        second.Footprint < Footprint && this !in second.Footprint &&
        second.WellFormed()) &&
      (first == null && second == null ==>
        Footprint == {this} &&
        Model == chunk &&
        pivot == |chunk| &&
        chunk != "") &&
      (first != null && second == null ==>
        Footprint == {this} + first.Footprint &&
        Model == first.Model &&
        pivot == |first.Model| &&
        chunk == "") &&
      (first == null && second != null ==>
        Footprint == {this} + second.Footprint &&
        Model == second.Model &&
        pivot == 0 &&
        chunk == "") &&
      (first != null && second != null ==>
        Footprint == {this} + first.Footprint + second.Footprint &&
        first.Footprint !! second.Footprint &&
        Model == first.Model + second.Model &&
        pivot == |first.Model| &&
        chunk == "")
    }

    method ExtractWindow(start: nat, stop: nat) returns (out: string)
      requires 0 <= start <= stop <= |this.Model|
      requires WellFormed()
      ensures out == this.Model[start..stop]
      decreases Footprint
    {
      // Target body omitted for generation.
    }
  }
}
```
