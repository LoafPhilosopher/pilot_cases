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
    decreases rounds
  {
    if rounds == 0 {
      trace := [seed];

      forall i | 0 <= i < |trace|
        ensures |trace[i]| == |seed|
      {
        assert i == 0;
      }
    } else {
      var prefix := BuildTrace(seed, transition, rounds - 1);
      assert |prefix| == 1 + (rounds - 1);
      assert |prefix| == rounds;
      assert |prefix| > 0;
      assert 0 <= |prefix| - 1 < |prefix|;
      assert |prefix[|prefix| - 1]| == |seed|;

      var current := prefix[|prefix| - 1];
      assert |current| == |seed|;
      assert |current| >= 2;

      var next := BuildNext(current, transition);
      trace := prefix + [next];

      assert |trace| == |prefix| + 1;
      assert |trace| == 1 + rounds;
      assert trace[0] == prefix[0];
      assert prefix[0] == seed;
      assert trace[0] == seed;

      forall i | 0 <= i < |trace|
        ensures |trace[i]| == |seed|
      {
        if i < |prefix| {
          assert trace[i] == prefix[i];
          assert |prefix[i]| == |seed|;
        } else {
          assert i == |prefix|;
          assert trace[i] == next;
          assert |next| == |current|;
        }
      }

      assert |trace| - 1 == |prefix|;

      forall i | 0 <= i < |trace| - 1
        ensures forall j | 1 <= j <= |trace[i]| - 2 ::
          trace[i + 1][j] ==
            transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
      {
        assert i < |prefix|;

        if i < |prefix| - 1 {
          assert trace[i] == prefix[i];
          assert trace[i + 1] == prefix[i + 1];
          assert |trace[i]| == |prefix[i]|;

          assert forall j | 1 <= j <= |prefix[i]| - 2 ::
            prefix[i + 1][j] ==
              transition(prefix[i][j - 1], prefix[i][j], prefix[i][j + 1]);

          forall j | 1 <= j <= |trace[i]| - 2
            ensures trace[i + 1][j] ==
              transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
          {
            assert 1 <= j <= |prefix[i]| - 2;
            assert prefix[i + 1][j] ==
              transition(prefix[i][j - 1], prefix[i][j], prefix[i][j + 1]);
          }
        } else {
          assert i == |prefix| - 1;
          assert trace[i] == current;
          assert i + 1 == |prefix|;
          assert trace[i + 1] == next;
          assert |trace[i]| == |current|;

          forall j | 1 <= j <= |trace[i]| - 2
            ensures trace[i + 1][j] ==
              transition(trace[i][j - 1], trace[i][j], trace[i][j + 1])
          {
            assert 1 <= j <= |current| - 2;
            assert next[j] ==
              transition(current[j - 1], current[j], current[j + 1]);
          }
        }
      }

      forall i | 0 <= i < |trace| - 1
        ensures trace[i + 1][0] ==
          transition(false, trace[i][0], trace[i][1]) &&
          trace[i + 1][|trace[i]| - 1] ==
            transition(
              trace[i][|trace[i]| - 2],
              trace[i][|trace[i]| - 1],
              false)
      {
        assert i < |prefix|;

        if i < |prefix| - 1 {
          assert trace[i] == prefix[i];
          assert trace[i + 1] == prefix[i + 1];
          assert |trace[i]| == |prefix[i]|;

          assert prefix[i + 1][0] ==
              transition(false, prefix[i][0], prefix[i][1]) &&
            prefix[i + 1][|prefix[i]| - 1] ==
              transition(
                prefix[i][|prefix[i]| - 2],
                prefix[i][|prefix[i]| - 1],
                false);

          assert trace[i + 1][0] ==
            transition(false, trace[i][0], trace[i][1]);
          assert trace[i + 1][|trace[i]| - 1] ==
            transition(
              trace[i][|trace[i]| - 2],
              trace[i][|trace[i]| - 1],
              false);
        } else {
          assert i == |prefix| - 1;
          assert trace[i] == current;
          assert i + 1 == |prefix|;
          assert trace[i + 1] == next;
          assert |trace[i]| == |current|;

          assert next[0] ==
            transition(false, current[0], current[1]);
          assert next[|current| - 1] ==
            transition(
              current[|current| - 2],
              current[|current| - 1],
              false);

          assert trace[i + 1][0] ==
            transition(false, trace[i][0], trace[i][1]);
          assert trace[i + 1][|trace[i]| - 1] ==
            transition(
              trace[i][|trace[i]| - 2],
              trace[i][|trace[i]| - 1],
              false);
        }
      }
    }
  }

  method BuildNext(row: seq<bool>, transition: (bool, bool, bool) -> bool)
    returns (next: seq<bool>)
    requires |row| >= 2
    ensures |next| == |row|
    ensures forall j | 1 <= j <= |row| - 2 ::
      next[j] == transition(row[j - 1], row[j], row[j + 1])
    ensures next[0] == transition(false, row[0], row[1])
    ensures next[|row| - 1] ==
      transition(row[|row| - 2], row[|row| - 1], false)
  {
    next := seq(|row|, j =>
      if j == 0 then
        transition(false, row[0], row[1])
      else if j == |row| - 1 then
        transition(row[j - 1], row[j], false)
      else if 0 < j && j < |row| - 1 then
        transition(row[j - 1], row[j], row[j + 1])
      else
        false);

    assert |next| == |row|;

    forall j | 1 <= j <= |row| - 2
      ensures next[j] == transition(row[j - 1], row[j], row[j + 1])
    {
      assert j != 0;
      assert j != |row| - 1;
    }

    assert 0 < |row|;
    assert next[0] == transition(false, row[0], row[1]);
    assert 0 <= |row| - 1 < |row|;
    assert |row| - 1 != 0;
    assert next[|row| - 1] ==
      transition(row[|row| - 2], row[|row| - 1], false);
  }
}
