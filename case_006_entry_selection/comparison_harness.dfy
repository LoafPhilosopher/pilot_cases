include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/CS5232_Project_tmp_tmpai_cfrng_LFUSimple.dfy"
include "generated_attempt_01.dfy"

ghost predicate IsMinimumEntry(table: map<int, (int, int)>, key: int)
{
  key in table &&
  forall item :: item in table.Items ==>
    table[key].1 <= table[item.0].1
}

ghost predicate MinimumEntryIsUnique(table: map<int, (int, int)>)
{
  forall first, second ::
    IsMinimumEntry(table, first) && IsMinimumEntry(table, second) ==>
      first == second
}

// This method compares the actual generated and reference calls.  Their
// state is related by the frozen alpha-renaming cacheMap <-> table.
method ImplementationsMeetFrozenRelation(
    reference: LFUCache,
    generated: RecordSpace)
  returns (referenceKey: int, generatedKey: int)
  requires reference.Valid()
  requires generated.Coherent()
  requires 0 < |reference.cacheMap|
  requires reference.cacheMap == generated.table
  ensures IsMinimumEntry(reference.cacheMap, referenceKey)
  ensures IsMinimumEntry(reference.cacheMap, generatedKey)
  ensures MinimumEntryIsUnique(reference.cacheMap) ==>
    referenceKey == generatedKey
{
  referenceKey := reference.getLFUKey();
  generatedKey := generated.ChooseEntry();

  assert referenceKey in reference.cacheMap;
  assert generatedKey in generated.table;
  assert generatedKey in reference.cacheMap;

  assert forall item :: item in reference.cacheMap.Items ==>
    reference.cacheMap[referenceKey].1 <=
      reference.cacheMap[item.0].1;
  assert forall item :: item in reference.cacheMap.Items ==>
    reference.cacheMap[generatedKey].1 <=
      reference.cacheMap[item.0].1;

  assert IsMinimumEntry(reference.cacheMap, referenceKey);
  assert IsMinimumEntry(reference.cacheMap, generatedKey);
  if MinimumEntryIsUnique(reference.cacheMap) {
    assert referenceKey == generatedKey;
  }
}

// A concrete state showing why raw key equality is not implied when the
// minimum is tied.  Both 10 and 20 satisfy the full observable result
// predicate, but they are different integers.
lemma TiedMinimumWitness()
  ensures IsMinimumEntry(
    map[10 := (100, 1), 20 := (200, 1)], 10)
  ensures IsMinimumEntry(
    map[10 := (100, 1), 20 := (200, 1)], 20)
  ensures 10 != 20
  ensures !MinimumEntryIsUnique(
    map[10 := (100, 1), 20 := (200, 1)])
{
}
