include "../../DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy"
include "generated_attempt_01.dfy"

method {:main} Counterexample() {
  var values := new int[4];
  values[0], values[1], values[2], values[3] := 0, 1, 1, 0;

  assert 0 <= 0 < 3 < values.Length && values[0] == values[3] == 0;
  assert exists i, j ::
    0 <= i < j < values.Length && values[i] == values[j] == 0;
  assert HasWitnessBefore(values, values.Length, 0);
  assert HasWitness(values, 0);

  assert 0 <= 1 < 2 < values.Length && values[1] == values[2] == 1;
  assert exists i, j ::
    0 <= i < j < values.Length && values[i] == values[j] == 1;
  assert HasWitnessBefore(values, values.Length, 1);
  assert HasWitness(values, 1);

  assert exists x, y ::
    x != y && HasWitness(values, x) && HasWitness(values, y);
  assert IsDuplicate(values, 0) && IsDuplicate(values, 1);
  assert forall i ::
    0 <= i < values.Length ==> 0 <= values[i] < values.Length - 2;

  var generatedX, generatedY := ChooseWitnesses(values);

  assert IsDuplicate(values, 0) && IsDuplicate(values, 1);
  assert exists p, q ::
    p != q && IsDuplicate(values, p) && IsDuplicate(values, q);
  assert forall i ::
    0 <= i < values.Length ==> 0 <= values[i] < values.Length - 2;
  var groundX, groundY := Search(values);

  print "input:        ", values[..], "\n";
  print "ground truth: (", groundX, ", ", groundY, ")\n";
  print "generated:    (", generatedX, ", ", generatedY, ")\n";

  var threeValues := new int[6];
  threeValues[0], threeValues[1], threeValues[2] := 0, 1, 2;
  threeValues[3], threeValues[4], threeValues[5] := 2, 1, 0;

  assert 0 <= 0 < 5 < threeValues.Length &&
    threeValues[0] == threeValues[5] == 0;
  assert 0 <= 1 < 4 < threeValues.Length &&
    threeValues[1] == threeValues[4] == 1;
  assert 0 <= 2 < 3 < threeValues.Length &&
    threeValues[2] == threeValues[3] == 2;
  assert HasWitness(threeValues, 0) && HasWitness(threeValues, 1) &&
    HasWitness(threeValues, 2);
  assert IsDuplicate(threeValues, 0) && IsDuplicate(threeValues, 1) &&
    IsDuplicate(threeValues, 2);
  assert exists x, y ::
    x != y && HasWitness(threeValues, x) && HasWitness(threeValues, y);
  assert exists x, y ::
    x != y && IsDuplicate(threeValues, x) && IsDuplicate(threeValues, y);
  assert forall i ::
    0 <= i < threeValues.Length ==>
      0 <= threeValues[i] < threeValues.Length - 2;

  var generatedX2, generatedY2 := ChooseWitnesses(threeValues);
  assert IsDuplicate(threeValues, 0) && IsDuplicate(threeValues, 1) &&
    IsDuplicate(threeValues, 2);
  assert exists x, y ::
    x != y && IsDuplicate(threeValues, x) && IsDuplicate(threeValues, y);
  assert forall i ::
    0 <= i < threeValues.Length ==>
      0 <= threeValues[i] < threeValues.Length - 2;
  var groundX2, groundY2 := Search(threeValues);

  print "\ninput:        ", threeValues[..], "\n";
  print "ground truth: (", groundX2, ", ", groundY2, ")\n";
  print "generated:    (", generatedX2, ", ", generatedY2, ")\n";
}
