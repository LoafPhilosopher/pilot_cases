class CountRepresentation {
  function AbstractView(counts: map<int, nat>): multiset<int>
    ensures (forall key | key in counts :: counts[key] == AbstractView(counts)[key]) &&
      (counts == map[] <==> AbstractView(counts) == multiset{}) &&
      (forall key :: key in counts <==> key in AbstractView(counts))

  lemma RepresentationAgreement(counts: map<int, nat>, values: seq<int>)
    requires (forall key | key in counts :: counts[key] == multiset(values)[key]) &&
      (counts == map[] <==> multiset(values) == multiset{})
    ensures AbstractView(counts) == multiset(values)

  method ExpandRepresentation(counts: map<int, nat>) returns (values: seq<int>)
    requires forall key | key in counts.Keys :: key in counts.Keys <==> counts[key] > 0
    ensures forall key | key in counts.Keys :: multiset(values)[key] == counts[key]
    ensures forall key | key in counts.Keys :: key in values
    ensures AbstractView(counts) == multiset(values)
    ensures (forall key | key in counts :: counts[key] == multiset(values)[key]) &&
      (counts == map[] <==> multiset(values) == multiset{})
  {
    values := [];
    var remaining := counts.Keys;

    while remaining != {}
      invariant remaining <= counts.Keys
      invariant forall key | key in counts.Keys - remaining ::
        multiset(values)[key] == counts[key]
      invariant forall key | key in remaining ::
        multiset(values)[key] == 0
      invariant forall key | key !in counts.Keys ::
        multiset(values)[key] == 0
      decreases |remaining|
    {
      var key :| key in remaining;
      var before := values;

      assert forall other | other in counts.Keys - remaining ::
        multiset(before)[other] == counts[other];
      assert forall other | other in remaining ::
        multiset(before)[other] == 0;
      assert forall other | other !in counts.Keys ::
        multiset(before)[other] == 0;

      var i: nat := 0;
      while i < counts[key]
        invariant i <= counts[key]
        invariant multiset(values)[key] == i
        invariant forall other | other != key ::
          multiset(values)[other] == multiset(before)[other]
        decreases counts[key] - i
      {
        values := values + [key];
        i := i + 1;
      }

      assert multiset(values)[key] == counts[key];

      forall other | other in counts.Keys - (remaining - {key})
        ensures multiset(values)[other] == counts[other]
      {
        if other != key {
          assert other in counts.Keys - remaining;
        }
      }

      forall other | other in remaining - {key}
        ensures multiset(values)[other] == 0
      {
        assert other != key;
      }

      forall other | other !in counts.Keys
        ensures multiset(values)[other] == 0
      {
        assert other != key;
      }

      remaining := remaining - {key};
    }

    assert remaining == {};

    forall key | key in counts.Keys
      ensures multiset(values)[key] == counts[key]
    {
      assert key in counts.Keys - remaining;
    }

    forall key | key in counts.Keys
      ensures key in values
    {
      assert key in counts.Keys <==> counts[key] > 0;
      assert counts[key] > 0;
      assert multiset(values)[key] == counts[key];
      if key !in values {
        assert multiset(values)[key] == 0;
        assert false;
      }
    }

    if counts == map[] {
      assert counts.Keys == {};
      forall key
        ensures multiset(values)[key] == 0
      {
        assert key !in counts.Keys;
      }
      assert forall key :: multiset(values)[key] == multiset{}[key];
      assert multiset(values) == multiset{};
    } else {
      assert counts.Keys != {};
      var key :| key in counts.Keys;
      assert key in counts.Keys <==> counts[key] > 0;
      assert counts[key] > 0;
      assert multiset(values)[key] == counts[key];
      assert multiset(values)[key] > 0;
      assert multiset(values) != multiset{};
    }

    assert counts == map[] <==> multiset(values) == multiset{};
    assert (forall key | key in counts ::
      counts[key] == multiset(values)[key]) &&
      (counts == map[] <==> multiset(values) == multiset{});

    RepresentationAgreement(counts, values);
  }
}
