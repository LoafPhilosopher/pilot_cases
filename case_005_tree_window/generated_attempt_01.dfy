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
      if first == null {
        if second == null {
          assert Model == chunk;
          out := chunk[start..stop];
        } else {
          assert second.WellFormed();
          assert second.Footprint < Footprint;
          assert Model == second.Model;
          assert stop <= |second.Model|;
          out := second.ExtractWindow(start, stop);
        }
      } else if second == null {
        assert first.WellFormed();
        assert first.Footprint < Footprint;
        assert Model == first.Model;
        assert stop <= |first.Model|;
        out := first.ExtractWindow(start, stop);
      } else {
        assert first.WellFormed();
        assert second.WellFormed();
        assert first.Footprint < Footprint;
        assert second.Footprint < Footprint;
        assert Model == first.Model + second.Model;
        assert pivot == |first.Model|;
        assert |Model| == |first.Model| + |second.Model|;
        assert (first.Model + second.Model)[..pivot] == first.Model;
        assert (first.Model + second.Model)[pivot..] == second.Model;

        if stop <= pivot {
          assert stop <= |first.Model|;
          out := first.ExtractWindow(start, stop);
          assert (first.Model + second.Model)[start..stop] ==
            ((first.Model + second.Model)[..pivot])[start..stop];
          assert Model[start..stop] == first.Model[start..stop];
        } else if pivot <= start {
          assert 0 <= start - pivot <= stop - pivot <= |second.Model|;
          out := second.ExtractWindow(start - pivot, stop - pivot);
          assert (first.Model + second.Model)[start..stop] ==
            ((first.Model + second.Model)[pivot..])[
              (start - pivot)..(stop - pivot)];
          assert Model[start..stop] ==
            second.Model[(start - pivot)..(stop - pivot)];
        } else {
          assert start < pivot < stop;
          assert start <= pivot <= |first.Model|;
          assert 0 <= stop - pivot <= |second.Model|;

          var leftPart := first.ExtractWindow(start, pivot);
          var rightPart := second.ExtractWindow(0, stop - pivot);
          out := leftPart + rightPart;

          assert (first.Model + second.Model)[start..stop] ==
            (first.Model + second.Model)[start..pivot] +
            (first.Model + second.Model)[pivot..stop];
          assert (first.Model + second.Model)[start..pivot] ==
            ((first.Model + second.Model)[..pivot])[start..pivot];
          assert (first.Model + second.Model)[pivot..stop] ==
            ((first.Model + second.Model)[pivot..])[0..stop - pivot];
          assert Model[start..stop] ==
            first.Model[start..pivot] +
            second.Model[0..stop - pivot];
        }
      }
    }
  }
}
