include "../../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_lightening_verifier.dfy"
include "round_01/output_program.dfy"

ghost predicate StatesCorrespond(reference: GhostState, generated: StateRecord)
{
  reference.num_entry == generated.entryCount &&
  reference.log == generated.entries &&
  reference.mem_len == generated.valueCount &&
  reference.mem == generated.currentValues &&
  reference.old_mem == generated.baselineValues &&
  reference.ideal_mem == generated.intendedValues &&
  reference.countdown == generated.remainingSteps &&
  reference.first_log_pos == generated.firstEntry
}

// reverse_recovery updates only the abstract memory sequence.  The source
// function already specifies preservation of old_mem and first_log_pos; this
// induction records the remaining unchanged datatype fields needed for the
// cross-program relation.
lemma ReverseRecoveryPreservesOtherFields(initial: GhostState, index: int)
  requires ghost_tx_inv(initial)
  requires old_mem_equiv(initial)
  requires 0 <= index <= initial.num_entry
  ensures reverse_recovery(initial, index).log == initial.log
  ensures reverse_recovery(initial, index).mem_len == initial.mem_len
  ensures reverse_recovery(initial, index).old_mem == initial.old_mem
  ensures reverse_recovery(initial, index).ideal_mem == initial.ideal_mem
  ensures reverse_recovery(initial, index).countdown == initial.countdown
  ensures reverse_recovery(initial, index).first_log_pos == initial.first_log_pos
  decreases index
{
  if index > 0 {
    var entry := index - 1;
    var offset := initial.log[entry * 2];
    var restored := initial.log[entry * 2 + 1];
    var updated := initial.(mem := initial.mem[offset := restored]);

    assert 0 <= entry < initial.num_entry;
    assert offset in initial.first_log_pos;
    assert ghost_tx_inv(updated);
    assert old_mem_equiv(updated) by {
      forall other |
        !(other in updated.first_log_pos) &&
        0 <= other < |updated.mem|
        ensures updated.mem[other] == updated.old_mem[other]
      {
        assert other != offset;
        assert initial.mem[other] == initial.old_mem[other];
      }
    }
    ReverseRecoveryPreservesOtherFields(updated, index - 1);
  }
}

lemma RecoveredStatesCorrespond(reference: GhostState, generated: StateRecord)
  requires ghost_tx_inv(reference)
  requires old_mem_equiv(reference)
  requires ActiveState(generated)
  requires BaselineRelation(generated)
  requires StatesCorrespond(reference, generated)
  ensures StatesCorrespond(ghost_recover(reference), SpecifiedState(generated))
{
  ReverseRecoveryPreservesOtherFields(reference, reference.num_entry);

  var recovered := ghost_recover(reference);
  var restored := SpecifiedState(generated);

  assert recovered.num_entry == 0;
  assert restored.entryCount == 0;
  assert recovered.mem == reference.old_mem;
  assert restored.currentValues == generated.baselineValues;
}

// This theorem calls each actual public method and snapshots its observable
// value state immediately after the call.  Immutable snapshots let the two
// executions be compared without assuming cross-run pointer equality.
method FinalAbstractStateAndContentsAgree(
    reference: UndoLog,
    generated: MutableContainer)
  returns (referenceLog: seq<int>, generatedRecords: seq<int>,
           referenceMemory: seq<int>, generatedValues: seq<int>,
           referenceCountdown: int, generatedRemaining: int,
           ghost referenceState: GhostState,
           ghost generatedState: StateRecord)
  requires reference.state_inv()
  requires ghost_tx_inv(reference.gs)
  requires old_mem_equiv(reference.gs)
  requires reference.ghost_state_equiv(reference.gs)
  requires generated.ContainerInvariant()
  requires ActiveState(generated.model)
  requires BaselineRelation(generated.model)
  requires generated.Represents(generated.model)
  requires StatesCorrespond(reference.gs, generated.model)
  requires reference.log_ != generated.records
  requires reference.log_ != generated.values
  requires reference.mem_ != generated.records
  requires reference.mem_ != generated.values
  modifies reference.log_, reference.mem_, reference
  modifies generated.records, generated.values, generated
  ensures StatesCorrespond(referenceState, generatedState)
  ensures referenceLog == generatedRecords
  ensures referenceMemory == generatedValues
  ensures referenceCountdown == generatedRemaining
{
  ghost var initialReference := reference.gs;
  ghost var initialGenerated := generated.model;

  reference.recover();
  referenceLog := reference.log_[..];
  referenceMemory := reference.mem_[..];
  referenceCountdown := reference.impl_countdown;
  referenceState := reference.gs;

  generated.RestoreState();
  generatedRecords := generated.records[..];
  generatedValues := generated.values[..];
  generatedRemaining := generated.remainingSteps;
  generatedState := generated.model;

  RecoveredStatesCorrespond(initialReference, initialGenerated);
  assert referenceState == ghost_recover(initialReference);
  assert generatedState == SpecifiedState(initialGenerated);
  assert StatesCorrespond(referenceState, generatedState);

  assert referenceMemory == referenceState.mem;
  assert generatedValues == generatedState.currentValues;
  assert referenceCountdown == referenceState.countdown;
  assert generatedRemaining == generatedState.remainingSteps;

  assert referenceLog[1..] == referenceState.log;
  assert generatedRecords[1..] == generatedState.entries;
  assert referenceLog[0] == referenceState.num_entry;
  assert generatedRecords[0] == generatedState.entryCount;
  assert |referenceLog| == |referenceState.log| + 1;
  assert |generatedRecords| == |generatedState.entries| + 1;
  assert referenceLog == [referenceLog[0]] + referenceLog[1..];
  assert generatedRecords == [generatedRecords[0]] + generatedRecords[1..];
}
