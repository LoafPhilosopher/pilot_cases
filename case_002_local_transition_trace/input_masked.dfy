class TraceBuilder {
  method BuildTrace(seed: seq<bool>, transition: (bool, bool, bool) -> bool, rounds: nat)
    returns (trace: seq<seq<bool>>)
    requires |seed| >= 2
    ensures |trace| == 1 + rounds
    ensures trace[0] == seed
    ensures forall i | 0 <= i < |trace| :: |trace[i]| == |seed|
    ensures forall i | 0 <= i < |trace| - 1 ::
      forall j | 1 <= j <= |trace[i]| - 2 ::
        trace[i + 1][j] == transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
    ensures forall i | 0 <= i < |trace| - 1 ::
      trace[i + 1][0] == transition(false, trace[i][0], trace[i][1]) &&
      trace[i + 1][|trace[i]| - 1] ==
        transition(trace[i][|trace[i]| - 2], trace[i][|trace[i]| - 1], false)
  {
    // Target body omitted for generation.
  }
}
