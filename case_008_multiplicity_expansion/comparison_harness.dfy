include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_map-multiset-implementation.dfy"
include "generated_attempt_01.dfy"

// Compare the actual calls.  The proof does not assume an iteration order: it
// derives equality of every multiset multiplicity from the two public
// contracts and their inherited abstraction-function interfaces.
method ImplementationsAgreeAsMultisets(
    reference: MultisetImplementationWithMap,
    generated: CountRepresentation,
    counts: map<int, nat>)
  returns (referenceValues: seq<int>, generatedValues: seq<int>)
  requires forall key | key in counts.Keys ::
    key in counts.Keys <==> counts[key] > 0
  ensures multiset(referenceValues) == multiset(generatedValues)
{
  referenceValues := reference.Map2Seq(counts);
  generatedValues := generated.ExpandRepresentation(counts);

  forall key: int
    ensures multiset(referenceValues)[key] ==
      multiset(generatedValues)[key]
  {
    if key in counts {
      assert multiset(referenceValues)[key] == counts[key];
      assert multiset(generatedValues)[key] == counts[key];
    } else {
      assert key !in reference.A(counts);
      assert reference.A(counts) == multiset(referenceValues);
      assert key !in multiset(referenceValues);
      assert multiset(referenceValues)[key] == 0;

      assert key !in generated.AbstractView(counts);
      assert generated.AbstractView(counts) ==
        multiset(generatedValues);
      assert key !in multiset(generatedValues);
      assert multiset(generatedValues)[key] == 0;
    }
  }
  assert multiset(referenceValues) == multiset(generatedValues);
}

ghost predicate ReferenceResultContract(
    reference: MultisetImplementationWithMap,
    counts: map<int, nat>,
    values: seq<int>)
{
  (forall key | key in counts.Keys ::
    multiset(values)[key] == counts[key]) &&
  (forall key | key in counts.Keys :: key in values) &&
  reference.A(counts) == multiset(values) &&
  (forall key | key in counts ::
    counts[key] == multiset(values)[key]) &&
  (counts == map[] <==> multiset(values) == multiset{})
}

ghost predicate GeneratedResultContract(
    generated: CountRepresentation,
    counts: map<int, nat>,
    values: seq<int>)
{
  (forall key | key in counts.Keys ::
    multiset(values)[key] == counts[key]) &&
  (forall key | key in counts.Keys :: key in values) &&
  generated.AbstractView(counts) == multiset(values) &&
  (forall key | key in counts ::
    counts[key] == multiset(values)[key]) &&
  (counts == map[] <==> multiset(values) == multiset{})
}

// Both orders satisfy every frozen return postcondition for this concrete
// two-key input.  Thus raw sequence equality is not a consequence of the
// specification, while the primary multiset relation still holds.
lemma RawOrderWitness(
    reference: MultisetImplementationWithMap,
    generated: CountRepresentation)
  ensures [1, 2] != [2, 1]
  ensures multiset([1, 2]) == multiset([2, 1])
  ensures ReferenceResultContract(
    reference, map[1 := 1, 2 := 1], [1, 2])
  ensures ReferenceResultContract(
    reference, map[1 := 1, 2 := 1], [2, 1])
  ensures GeneratedResultContract(
    generated, map[1 := 1, 2 := 1], [1, 2])
  ensures GeneratedResultContract(
    generated, map[1 := 1, 2 := 1], [2, 1])
{
  var counts := map[1 := 1, 2 := 1];
  assert multiset([1, 2]) == multiset([2, 1]);

  reference.LemmaReverseA(counts, [1, 2]);
  reference.LemmaReverseA(counts, [2, 1]);
  generated.RepresentationAgreement(counts, [1, 2]);
  generated.RepresentationAgreement(counts, [2, 1]);
}
