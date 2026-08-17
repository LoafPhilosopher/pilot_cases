datatype StateRecord = StateRecord(
  entryCount: int,
  entries: seq<int>,
  valueCount: int,
  currentValues: seq<int>,
  baselineValues: seq<int>,
  intendedValues: seq<int>,
  remainingSteps: int,
  firstEntry: map<int, int>
)

predicate StateInvariant(state: StateRecord)
{
  0 <= state.entryCount * 2 < |state.entries| &&
  |state.entries| > 0 &&
  |state.currentValues| == state.valueCount &&
  |state.intendedValues| == state.valueCount &&
  |state.baselineValues| == state.valueCount &&
  state.remainingSteps >= 0
}

predicate BaselineRelation(state: StateRecord)
  requires StateInvariant(state)
{
  forall offset ::
    !(offset in state.firstEntry) && 0 <= offset < |state.currentValues| ==>
      state.currentValues[offset] == state.baselineValues[offset]
}

predicate ActiveState(state: StateRecord)
{
  StateInvariant(state) &&
  (forall offset :: offset in state.firstEntry ==> 0 <= offset < state.valueCount) &&
  (forall offset :: offset in state.firstEntry ==>
    0 <= state.firstEntry[offset] < state.entryCount) &&
  (forall offset :: offset in state.firstEntry ==>
    0 <= state.firstEntry[offset] * 2 + 1 < |state.entries|) &&
  (forall offset :: offset in state.firstEntry ==>
    state.entries[state.firstEntry[offset] * 2] == offset) &&
  (forall offset :: offset in state.firstEntry ==>
    state.entries[state.firstEntry[offset] * 2 + 1] == state.baselineValues[offset]) &&
  (forall offset :: offset in state.firstEntry ==>
    forall i :: 0 <= i < state.firstEntry[offset] ==>
      state.entries[i * 2] != offset) &&
  (forall i :: 0 <= i < state.entryCount ==>
    state.entries[i * 2] in state.firstEntry)
}

ghost function SpecifiedState(initial: StateRecord): StateRecord
  requires ActiveState(initial)
  requires BaselineRelation(initial)
  ensures SpecifiedState(initial).entryCount == 0
  ensures SpecifiedState(initial).entries == initial.entries
  ensures SpecifiedState(initial).valueCount == initial.valueCount
  ensures SpecifiedState(initial).currentValues == initial.baselineValues
  ensures SpecifiedState(initial).baselineValues == initial.baselineValues
  ensures SpecifiedState(initial).intendedValues == initial.intendedValues
  ensures SpecifiedState(initial).remainingSteps == initial.remainingSteps
  ensures SpecifiedState(initial).firstEntry == initial.firstEntry

class MutableContainer {
  var records: array<int>
  var values: array<int>
  var remainingSteps: int
  ghost var model: StateRecord

  predicate Represents(state: StateRecord)
    reads this, values, records
  {
    records.Length > 0 &&
    values[..] == state.currentValues &&
    records[1..] == state.entries &&
    records[0] == state.entryCount &&
    remainingSteps == state.remainingSteps
  }

  predicate ContainerInvariant()
    reads this, records
  {
    records.Length > 1 &&
    0 <= records[0] &&
    records[0] * 2 < records.Length &&
    records.Length < 0xffffffff &&
    values != records &&
    (forall i: int ::
      0 <= i < records[0] ==> 0 <= records[i * 2 + 1] < values.Length) &&
    remainingSteps >= 0
  }

  method RestoreState()
    modifies records
    modifies values
    modifies this
    requires ContainerInvariant()
    requires ActiveState(model)
    requires BaselineRelation(model)
    requires Represents(model)
    ensures model == SpecifiedState(old(model))
    ensures Represents(model)
  {
    var originalRecords := records;
    var originalValues := values;
    assert originalRecords == old(records);
    assert originalValues == old(values);

    ghost var initial := model;
    assert initial == old(model);
    assert ActiveState(initial);
    assert BaselineRelation(initial);
    assert records[0] == initial.entryCount;
    assert records[1..] == initial.entries;
    assert values[..] == initial.currentValues;
    assert remainingSteps == initial.remainingSteps;
    assert values.Length == initial.valueCount;
    assert |initial.baselineValues| == values.Length;

    assert forall offset ::
      0 <= offset < values.Length &&
      !(offset in initial.firstEntry) ==>
        values[offset] == initial.baselineValues[offset] by {
      forall offset |
        0 <= offset < values.Length &&
        !(offset in initial.firstEntry)
        ensures values[offset] == initial.baselineValues[offset]
      {
        assert 0 <= offset < |initial.currentValues|;
        assert initial.currentValues[offset] ==
          initial.baselineValues[offset];
        assert values[offset] == initial.currentValues[offset];
      }
    }

    var count := records[0];
    assert count == initial.entryCount;

    assert forall offset ::
      0 <= offset < values.Length &&
      offset in initial.firstEntry &&
      initial.firstEntry[offset] >= count ==>
        values[offset] == initial.baselineValues[offset] by {
      forall offset |
        0 <= offset < values.Length &&
        offset in initial.firstEntry &&
        initial.firstEntry[offset] >= count
        ensures values[offset] == initial.baselineValues[offset]
      {
        assert initial.firstEntry[offset] < initial.entryCount;
        assert count == initial.entryCount;
        assert false;
      }
    }

    while count > 0
      invariant ContainerInvariant()
      invariant records == originalRecords
      invariant values == originalValues
      invariant model == initial
      invariant ActiveState(initial)
      invariant BaselineRelation(initial)
      invariant records[0] == initial.entryCount
      invariant records[1..] == initial.entries
      invariant remainingSteps == initial.remainingSteps
      invariant values.Length == initial.valueCount
      invariant |initial.baselineValues| == values.Length
      invariant 0 <= count <= records[0]
      invariant forall offset ::
        0 <= offset < values.Length &&
        !(offset in initial.firstEntry) ==>
          values[offset] == initial.baselineValues[offset]
      invariant forall offset ::
        0 <= offset < values.Length &&
        offset in initial.firstEntry &&
        initial.firstEntry[offset] >= count ==>
          values[offset] == initial.baselineValues[offset]
      decreases count
    {
      var index := count - 1;
      assert 0 <= index < records[0];
      assert 0 <= index * 2 + 1 < records.Length;
      assert 0 <= index * 2 + 2 < records.Length;

      var offset := records[index * 2 + 1];
      var restored := records[index * 2 + 2];

      assert 0 <= offset < values.Length;
      assert 0 <= index < initial.entryCount;
      assert 0 <= index * 2 + 1 < |initial.entries|;
      assert records[index * 2 + 1] ==
        (records[1..])[index * 2];
      assert records[index * 2 + 2] ==
        (records[1..])[index * 2 + 1];
      assert offset == initial.entries[index * 2];
      assert restored == initial.entries[index * 2 + 1];
      assert offset in initial.firstEntry;
      assert 0 <= initial.firstEntry[offset] < initial.entryCount;

      if index < initial.firstEntry[offset] {
        assert initial.entries[index * 2] != offset;
        assert false;
      }
      assert initial.firstEntry[offset] <= index;

      ghost var previousValues := values[..];

      assert forall o ::
        0 <= o < values.Length &&
        !(o in initial.firstEntry) ==>
          previousValues[o] == initial.baselineValues[o] by {
        forall o |
          0 <= o < values.Length &&
          !(o in initial.firstEntry)
          ensures previousValues[o] == initial.baselineValues[o]
        {
          assert previousValues[o] == values[o];
        }
      }

      assert forall o ::
        0 <= o < values.Length &&
        o in initial.firstEntry &&
        initial.firstEntry[o] >= count ==>
          previousValues[o] == initial.baselineValues[o] by {
        forall o |
          0 <= o < values.Length &&
          o in initial.firstEntry &&
          initial.firstEntry[o] >= count
          ensures previousValues[o] == initial.baselineValues[o]
        {
          assert previousValues[o] == values[o];
        }
      }

      values[offset] := restored;

      assert forall o ::
        0 <= o < values.Length &&
        !(o in initial.firstEntry) ==>
          values[o] == initial.baselineValues[o] by {
        forall o |
          0 <= o < values.Length &&
          !(o in initial.firstEntry)
          ensures values[o] == initial.baselineValues[o]
        {
          assert o != offset;
          assert previousValues[o] == initial.baselineValues[o];
          assert values[o] == previousValues[o];
        }
      }

      assert forall o ::
        0 <= o < values.Length &&
        o in initial.firstEntry &&
        initial.firstEntry[o] >= index ==>
          values[o] == initial.baselineValues[o] by {
        forall o |
          0 <= o < values.Length &&
          o in initial.firstEntry &&
          initial.firstEntry[o] >= index
          ensures values[o] == initial.baselineValues[o]
        {
          if initial.firstEntry[o] == index {
            assert initial.entries[
              initial.firstEntry[o] * 2] == o;
            assert initial.entries[index * 2] == o;
            assert o == offset;
            assert initial.entries[
              initial.firstEntry[o] * 2 + 1] ==
                initial.baselineValues[o];
            assert restored == initial.baselineValues[o];
            assert values[o] == restored;
          } else {
            assert initial.firstEntry[o] > index;
            assert initial.firstEntry[o] >= count;
            if o == offset {
              assert initial.firstEntry[o] ==
                initial.firstEntry[offset];
              assert false;
            }
            assert previousValues[o] ==
              initial.baselineValues[o];
            assert values[o] == previousValues[o];
          }
        }
      }

      count := index;
    }

    assert count == 0;
    assert forall offset ::
      0 <= offset < values.Length ==>
        values[offset] == initial.baselineValues[offset] by {
      forall offset | 0 <= offset < values.Length
        ensures values[offset] == initial.baselineValues[offset]
      {
        if offset in initial.firstEntry {
          assert 0 <= initial.firstEntry[offset];
          assert initial.firstEntry[offset] >= count;
        }
      }
    }

    assert forall offset ::
      0 <= offset < |values[..]| ==>
        (values[..])[offset] == initial.baselineValues[offset];
    assert values[..] == initial.baselineValues;

    ghost var completedValues := values[..];
    ghost var savedEntries := records[1..];
    assert completedValues == initial.baselineValues;
    assert savedEntries == initial.entries;
    assert values != records;

    records[0] := 0;

    assert values[..] == completedValues;
    assert records[1..] == savedEntries;
    assert values[..] == initial.baselineValues;
    assert records[1..] == initial.entries;
    assert records[0] == 0;
    assert remainingSteps == initial.remainingSteps;

    model := SpecifiedState(initial);

    assert model == SpecifiedState(initial);
    assert model.entryCount == 0;
    assert model.entries == initial.entries;
    assert model.currentValues == initial.baselineValues;
    assert model.remainingSteps == initial.remainingSteps;
    assert values[..] == model.currentValues;
    assert records[1..] == model.entries;
    assert records[0] == model.entryCount;
    assert remainingSteps == model.remainingSteps;
    assert Represents(model);
    assert initial == old(model);
    assert model == SpecifiedState(old(model));
  }
}
