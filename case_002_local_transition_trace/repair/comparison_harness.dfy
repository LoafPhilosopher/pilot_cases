include "../../third_party/DafnyBench/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_automaton.dfy"
include "round_01/output_program.dfy"

// The public postconditions of both methods describe every cell in every
// returned row.  This lemma shows that any two sequences satisfying those
// postconditions must therefore be identical.
lemma EqualTraceRow(
    left: seq<seq<bool>>,
    right: seq<seq<bool>>,
    seed: seq<bool>,
    transition: (bool, bool, bool) -> bool,
    row: nat)
  requires |seed| >= 2
  requires |left| == |right|
  requires 0 <= row < |left|
  requires left[0] == seed && right[0] == seed
  requires forall i | 0 <= i < |left| :: |left[i]| == |seed|
  requires forall i | 0 <= i < |right| :: |right[i]| == |seed|
  requires forall i | 0 <= i < |left| - 1 ::
    (forall j | 1 <= j <= |left[i]| - 2 ::
      left[i + 1][j] ==
        transition(left[i][j - 1], left[i][j], left[i][j + 1])) &&
    left[i + 1][0] == transition(false, left[i][0], left[i][1]) &&
    left[i + 1][|left[i]| - 1] ==
      transition(left[i][|left[i]| - 2], left[i][|left[i]| - 1], false)
  requires forall i | 0 <= i < |right| - 1 ::
    (forall j | 1 <= j <= |right[i]| - 2 ::
      right[i + 1][j] ==
        transition(right[i][j - 1], right[i][j], right[i][j + 1])) &&
    right[i + 1][0] == transition(false, right[i][0], right[i][1]) &&
    right[i + 1][|right[i]| - 1] ==
      transition(right[i][|right[i]| - 2], right[i][|right[i]| - 1], false)
  ensures left[row] == right[row]
  decreases row
{
  if row == 0 {
  } else {
    EqualTraceRow(left, right, seed, transition, row - 1);
    assert left[row - 1] == right[row - 1];
    assert |left[row]| == |right[row]|;

    forall j | 0 <= j < |left[row]|
      ensures left[row][j] == right[row][j]
    {
      assert 0 <= row - 1 < |left| - 1;
      assert 0 <= row - 1 < |right| - 1;
      if j == 0 {
        assert left[row][0] ==
          transition(false, left[row - 1][0], left[row - 1][1]);
        assert right[row][0] ==
          transition(false, right[row - 1][0], right[row - 1][1]);
      } else if j == |left[row]| - 1 {
        assert |left[row - 1]| == |left[row]|;
        assert |right[row - 1]| == |right[row]|;
        assert left[row][j] ==
          transition(
            left[row - 1][|left[row - 1]| - 2],
            left[row - 1][|left[row - 1]| - 1],
            false);
        assert right[row][j] ==
          transition(
            right[row - 1][|right[row - 1]| - 2],
            right[row - 1][|right[row - 1]| - 1],
            false);
      } else {
        assert 1 <= j <= |left[row - 1]| - 2;
        assert 1 <= j <= |right[row - 1]| - 2;
        assert left[row][j] ==
          transition(
            left[row - 1][j - 1],
            left[row - 1][j],
            left[row - 1][j + 1]);
        assert right[row][j] ==
          transition(
            right[row - 1][j - 1],
            right[row - 1][j],
            right[row - 1][j + 1]);
      }
    }
    assert left[row] == right[row];
  }
}

lemma UniqueTrace(
    left: seq<seq<bool>>,
    right: seq<seq<bool>>,
    seed: seq<bool>,
    transition: (bool, bool, bool) -> bool,
    rounds: nat)
  requires |seed| >= 2
  requires |left| == 1 + rounds && |right| == 1 + rounds
  requires left[0] == seed && right[0] == seed
  requires forall i | 0 <= i < |left| :: |left[i]| == |seed|
  requires forall i | 0 <= i < |right| :: |right[i]| == |seed|
  requires forall i | 0 <= i < |left| - 1 ::
    (forall j | 1 <= j <= |left[i]| - 2 ::
      left[i + 1][j] ==
        transition(left[i][j - 1], left[i][j], left[i][j + 1])) &&
    left[i + 1][0] == transition(false, left[i][0], left[i][1]) &&
    left[i + 1][|left[i]| - 1] ==
      transition(left[i][|left[i]| - 2], left[i][|left[i]| - 1], false)
  requires forall i | 0 <= i < |right| - 1 ::
    (forall j | 1 <= j <= |right[i]| - 2 ::
      right[i + 1][j] ==
        transition(right[i][j - 1], right[i][j], right[i][j + 1])) &&
    right[i + 1][0] == transition(false, right[i][0], right[i][1]) &&
    right[i + 1][|right[i]| - 1] ==
      transition(right[i][|right[i]| - 2], right[i][|right[i]| - 1], false)
  ensures left == right
{
  forall i | 0 <= i < |left|
    ensures left[i] == right[i]
  {
    EqualTraceRow(left, right, seed, transition, i);
  }
  assert left == right;
}

method ImplementationsAgree(
    seed: seq<bool>,
    transition: (bool, bool, bool) -> bool,
    rounds: nat)
  returns (referenceTrace: seq<seq<bool>>, repairedTrace: seq<seq<bool>>)
  requires |seed| >= 2
  ensures referenceTrace == repairedTrace
{
  var reference := new Automaton;
  var repaired := new TraceBuilder;
  referenceTrace := reference.ExecuteAutomaton(seed, transition, rounds);
  repairedTrace := repaired.BuildTrace(seed, transition, rounds);
  UniqueTrace(referenceTrace, repairedTrace, seed, transition, rounds);
}
