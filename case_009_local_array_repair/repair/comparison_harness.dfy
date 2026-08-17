include "../../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_algorithms and leetcode_heap2.dfy"
include "round_02/output_program.dfy"

// This executable witness compares the actual final repaired program with the
// pinned reference.  Each method receives a separate one-element array with
// the same initial contents.  Both objects retain their original array alias,
// but the reference leaves 7 in the array while the repaired program writes 0.
method Main()
{
  var referenceInput := new int[1];
  referenceInput[0] := 7;
  var generatedInput := new int[1];
  generatedInput[0] := 7;

  var reference := new Heap.Heap(referenceInput);
  var generated := new ArrayState.Create(generatedInput);

  assert reference.IsAlmostMaxHeap(reference.arr[..], 0);
  assert generated.OrderedAwayFrom(generated.data[..], 0);

  var referenceNext := reference.heapify(0);
  var generatedNext := generated.RepairAt(0);

  print "initial contents:       [7]\n";
  print "reference contents:     ", reference.arr[..], "\n";
  print "repaired contents:      ", generated.data[..], "\n";
  print "reference next:         ", referenceNext, "\n";
  print "repaired next:          ", generatedNext, "\n";
  print "reference alias kept:   ", reference.arr == referenceInput, "\n";
  print "repaired alias kept:    ", generated.data == generatedInput, "\n";
}
