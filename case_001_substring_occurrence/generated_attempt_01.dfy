ghost predicate ContainsAtLeastOnce(source: string, pattern: string) {
  exists position :: 0 <= position <= |source| && pattern <= source[position..]
}

ghost predicate ResultCondition(source: string, pattern: string, ok: bool, index: nat) {
  (ok <==> ContainsAtLeastOnce(source, pattern)) &&
  (ok ==> index + |pattern| <= |source| && pattern <= source[index..])
}

method ComputeWitness(source: string, pattern: string) returns (ok: bool, index: nat)
  ensures ResultCondition(source, pattern, ok, index)
{
  ok := false;
  index := 0;
  var i: nat := 0;

  while i <= |source|
    invariant i <= |source| + 1
    invariant !ok
    invariant index == 0
    invariant forall j: int :: 0 <= j < i ==> !(pattern <= source[j..])
    decreases |source| + 1 - i
  {
    if pattern <= source[i..] {
      ok := true;
      index := i;
      assert ContainsAtLeastOnce(source, pattern) by {
        assert 0 <= i <= |source| && pattern <= source[i..];
      }
      assert |pattern| <= |source[i..]|;
      assert |source[i..]| == |source| - i;
      assert index + |pattern| <= |source|;
      assert ResultCondition(source, pattern, ok, index);
      return;
    }

    assert forall j: int :: 0 <= j < i + 1 ==> !(pattern <= source[j..]) by {
      forall j: int | 0 <= j < i + 1
        ensures !(pattern <= source[j..])
      {
        if j < i {
          assert !(pattern <= source[j..]);
        } else {
          assert j == i;
          assert !(pattern <= source[i..]);
        }
      }
    }
    i := i + 1;
  }

  assert i == |source| + 1;
  assert forall j: int :: 0 <= j <= |source| ==> !(pattern <= source[j..]) by {
    forall j: int | 0 <= j <= |source|
      ensures !(pattern <= source[j..])
    {
      assert j < i;
      assert !(pattern <= source[j..]);
    }
  }
  assert !ContainsAtLeastOnce(source, pattern);
  assert ResultCondition(source, pattern, ok, index);
}
