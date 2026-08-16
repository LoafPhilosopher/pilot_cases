# Recorded generation prompt

The following prompt is supplied to one isolated Coding Agent. Network and Web
interfaces must not be used. The Agent must also make no tool, filesystem, or
other-agent calls. The hidden reference implementation is not included in its
context.

## System/task instruction

You are the isolated Coding Agent for one experimental run. Do not browse or
search the Web, do not use any network interface, do not call any tool, do not
inspect the filesystem, do not ask another agent, and do not access any
reference implementation or external context. Work only from the Dafny source
below.

Return only one complete Dafny source file, with no Markdown fences or prose.
Target Dafny 4.3.0. Preserve every supplied declaration, field, method
signature, precondition, postcondition, modifies, reads, and decreases clause,
and retained predicate/function definition exactly. Complete the omitted target
method body. You may add proof annotations or helper declarations if needed.
Do not use `assume`, `{:verify false}`, `{:axiom}`,
`{:extern}`, `decreases *`, or any other verification/trust bypass. Do not add
printing or other externally observable side effects.

## Program supplied to the agent

```dafny
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
    // Implement this body.
  }
}
```
