include "../../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_ListContents.dfy"
include "round_01/output_program.dfy"

// A two-node execution distinguishes the original Node<T>.ReverseInPlace from
// the repaired Link<T>.Rewire under the frozen comparison relation.  The two
// classes have different names, so both saved implementations are included and
// called directly.
method Main()
{
  var referenceTail := new Node(2);
  var referenceHead := new Node.InitAsPredecessor(1, referenceTail);

  var repairedTail := new Link.Create(2);
  var repairedHead := new Link.Create(1);
  repairedHead.successor := repairedTail;
  repairedHead.View := [1, 2];
  repairedHead.Owned := {repairedHead} + repairedTail.Owned;
  assert repairedHead.Consistent();

  var referenceResult := referenceHead.ReverseInPlace();
  assert referenceResult.List == [2, 1];

  var repairedResult := repairedHead.Rewire();
  assert repairedResult.View == [2, 1];
  assert referenceResult.List == repairedResult.View;

  print "input values: [1, 2]\n";
  print "abstract returned sequences agree: [2, 1]\n";
  print "reference returns old tail: ", referenceResult == referenceTail, "\n";
  print "repaired returns old head: ", repairedResult == repairedHead, "\n";
  print "reference returned next is old head: ",
    referenceResult.next == referenceHead, "\n";
  print "repaired returned successor is old tail: ",
    repairedResult.successor == repairedTail, "\n";
  print "reference old-head data / old-tail data: ",
    referenceHead.data, " / ", referenceTail.data, "\n";
  print "repaired old-head value / old-tail value: ",
    repairedHead.value, " / ", repairedTail.value, "\n";
  print "reference old-head next is null: ",
    referenceHead.next == null, "\n";
  print "repaired old-head successor is old tail: ",
    repairedHead.successor == repairedTail, "\n";
}
