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
  // Implement this body.
}
