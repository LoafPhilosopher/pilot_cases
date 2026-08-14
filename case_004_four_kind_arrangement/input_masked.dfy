datatype Kind = K0 | K1 | K2 | K3

predicate AllowedPair(first: Kind, second: Kind)
{
  first == second ||
  first == K0 ||
  (first == K1 && (second == K2 || second == K3)) ||
  (first == K2 && second == K3) ||
  second == K3
}

predicate ValidArrangement(items: seq<Kind>)
{
  forall j, k :: 0 <= j < k < |items| ==> AllowedPair(items[j], items[k])
}

method Transform(items: seq<Kind>) returns (result: seq<Kind>)
  requires 0 < |items|
  ensures |result| == |items|
  ensures ValidArrangement(result)
  ensures multiset(items) == multiset(result)
{
  // Target body omitted for generation.
}
