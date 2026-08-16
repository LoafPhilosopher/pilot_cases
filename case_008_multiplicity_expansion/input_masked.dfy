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
    // Target body omitted for generation.
  }
}
