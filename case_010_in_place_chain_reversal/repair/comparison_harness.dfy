include "round_01/output_program.dfy"

// This is the pinned reference implementation translated through the frozen
// name mapping from PREGENERATION.md.  The method body is otherwise unchanged.
class ReferenceLink<T> {
  ghost var View: seq<T>
  ghost var Owned: set<ReferenceLink<T>>

  var value: T
  var successor: ReferenceLink?<T>

  ghost predicate Consistent()
    reads this, Owned
  {
    this in Owned &&
    (successor == null ==> View == [value]) &&
    (successor != null ==>
      successor in Owned && successor.Owned <= Owned &&
      this !in successor.Owned &&
      View == [value] + successor.View &&
      successor.Consistent())
  }

  constructor Create(initial: T)
    ensures Consistent() && fresh(Owned)
    ensures View == [initial]
  {
    value, successor := initial, null;
    View, Owned := [initial], {this};
  }

  constructor InitAsPredecessor(initial: T, nextNode: ReferenceLink<T>)
    requires nextNode.Consistent()
    ensures Consistent() && fresh(Owned - nextNode.Owned)
    ensures View == [initial] + nextNode.View
  {
    value, successor := initial, nextNode;
    View := [initial] + nextNode.View;
    Owned := {this} + nextNode.Owned;
  }

  method Rewire() returns (result: ReferenceLink<T>)
    requires Consistent()
    modifies Owned
    ensures result.Consistent() && result.Owned <= old(Owned)
    ensures |result.View| == |old(View)|
    ensures forall i ::
      0 <= i < |result.View| ==>
        result.View[i] == old(View)[|old(View)| - 1 - i]
  {
    var current := successor;
    result := this;
    result.successor := null;
    result.Owned := {result};
    result.View := [value];

    while current != null
      invariant result.Consistent() && result.Owned <= old(Owned)
      invariant current == null ==> |old(View)| == |result.View|
      invariant current != null ==>
        current.Consistent() &&
        current in old(Owned) && current.Owned <= old(Owned) &&
        current.Owned !! result.Owned
      invariant current != null ==>
        |old(View)| == |result.View| + |current.View| &&
        current.View == old(View)[|result.View|..]
      invariant forall i ::
        0 <= i < |result.View| ==>
          result.View[i] == old(View)[|result.View| - 1 - i]
      decreases if current != null then |current.View| else -1
    {
      var following := current.successor;

      current.successor := result;
      current.Owned := {current} + result.Owned;
      current.View := [current.value] + result.View;

      result := current;
      current := following;
    }
  }
}

// A two-node execution is enough to distinguish the methods under the frozen
// comparison relation.  The assertions about View follow from both public
// contracts.  The printed concrete fields come from executing the included
// repaired method and the translated pinned reference method above.
method Main()
{
  var referenceTail := new ReferenceLink.Create(2);
  var referenceHead := new ReferenceLink.InitAsPredecessor(1, referenceTail);

  var repairedTail := new Link.Create(2);
  var repairedHead := new Link.Create(1);
  repairedHead.successor := repairedTail;
  repairedHead.View := [1, 2];
  repairedHead.Owned := {repairedHead} + repairedTail.Owned;
  assert repairedHead.Consistent();

  var referenceResult := referenceHead.Rewire();
  assert referenceResult.View == [2, 1];

  var repairedResult := repairedHead.Rewire();
  assert repairedResult.View == [2, 1];
  assert referenceResult.View == repairedResult.View;

  print "input values: [1, 2]\n";
  print "abstract returned sequences agree: [2, 1]\n";
  print "reference returns old tail: ", referenceResult == referenceTail, "\n";
  print "repaired returns old head: ", repairedResult == repairedHead, "\n";
  print "reference returned successor is old head: ",
    referenceResult.successor == referenceHead, "\n";
  print "repaired returned successor is old tail: ",
    repairedResult.successor == repairedTail, "\n";
  print "reference old-head value / old-tail value: ",
    referenceHead.value, " / ", referenceTail.value, "\n";
  print "repaired old-head value / old-tail value: ",
    repairedHead.value, " / ", repairedTail.value, "\n";
  print "reference old-head successor is null: ",
    referenceHead.successor == null, "\n";
  print "repaired old-head successor is old tail: ",
    repairedHead.successor == repairedTail, "\n";
}
