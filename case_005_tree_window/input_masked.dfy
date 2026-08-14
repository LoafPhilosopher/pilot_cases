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
