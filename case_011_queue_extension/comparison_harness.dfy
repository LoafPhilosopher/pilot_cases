include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_Queue.dfy"
include "generated_attempt_01.dfy"

// Object identities from the two executions are normalized through the
// pre-existing heap bijection.  The one fresh cell allocated by each method is
// assigned the same freshId.  Consequently equality of these observations is
// equality up to a bijection that fixes every pre-existing object.
datatype NormalizedLink = End | Next(target: int)

datatype NormalizedQueue<T> = NormalizedQueue(
  firstId: int,
  lastId: int,
  cells: set<int>,
  ownedObjects: set<int>,
  values: map<int, T>,
  links: map<int, NormalizedLink>,
  suffixes: map<int, seq<T>>,
  cellOwnership: map<int, set<int>>,
  abstractModel: seq<T>)

datatype FrozenObservation<T> = FrozenObservation(
  postState: NormalizedQueue<T>,
  existingPointerWrites: set<int>,
  freshObjects: set<int>)

ghost predicate CompleteSnapshot<T>(state: NormalizedQueue<T>)
{
  state.firstId in state.cells &&
  state.lastId in state.cells &&
  state.cells <= state.ownedObjects &&
  state.values.Keys == state.cells &&
  state.links.Keys == state.cells &&
  state.suffixes.Keys == state.cells &&
  state.cellOwnership.Keys == state.cells &&
  state.suffixes[state.firstId] == state.abstractModel &&
  state.links[state.lastId] == End
}

function ExtendedValues<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): map<int, T>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  map id: int | id in state.cells + {freshId} ::
    if id == freshId then item else state.values[id]
}

function ExtendedLinks<T>(
    state: NormalizedQueue<T>, freshId: int): map<int, NormalizedLink>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  map id: int | id in state.cells + {freshId} ::
    if id == freshId then End
    else if id == state.lastId then Next(freshId)
    else state.links[id]
}

function ExtendedSuffixes<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): map<int, seq<T>>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  map id: int | id in state.cells + {freshId} ::
    if id == freshId then [] else state.suffixes[id] + [item]
}

function ExtendedCellOwnership<T>(
    state: NormalizedQueue<T>, freshId: int): map<int, set<int>>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  map id: int | id in state.cells + {freshId} ::
    if id == freshId then {freshId}
    else state.cellOwnership[id] + {freshId}
}

// This is the final observable transition of Queue.Enqueue after normalizing
// names and object identities.  Its source body creates exactly one Node,
// changes the old tail's next pointer, updates every old node's two ghost
// summaries, and extends the four queue-level summaries.
function ReferenceAfter<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): NormalizedQueue<T>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  NormalizedQueue(
    state.firstId,
    freshId,
    state.cells + {freshId},
    state.ownedObjects + {freshId},
    ExtendedValues(state, item, freshId),
    ExtendedLinks(state, freshId),
    ExtendedSuffixes(state, item, freshId),
    ExtendedCellOwnership(state, freshId),
    state.abstractModel + [item])
}

// This is the final observable transition of Buffer.UpdateStructure.  Unlike
// the reference source it assigns model from first.suffix, so that expression
// is retained here instead of silently replacing it by the postcondition.
function GeneratedAfter<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): NormalizedQueue<T>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  NormalizedQueue(
    state.firstId,
    freshId,
    state.cells + {freshId},
    state.ownedObjects + {freshId},
    ExtendedValues(state, item, freshId),
    ExtendedLinks(state, freshId),
    ExtendedSuffixes(state, item, freshId),
    ExtendedCellOwnership(state, freshId),
    ExtendedSuffixes(state, item, freshId)[state.firstId])
}

function ReferenceObservation<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): FrozenObservation<T>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  FrozenObservation(
    ReferenceAfter(state, item, freshId),
    {state.lastId},
    {freshId})
}

function GeneratedObservation<T>(
    state: NormalizedQueue<T>, item: T, freshId: int): FrozenObservation<T>
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
{
  FrozenObservation(
    GeneratedAfter(state, item, freshId),
    {state.lastId},
    {freshId})
}

// General, unbounded equality of every observation frozen before generation:
// abstract model, concrete chain/values/final null link, preservation of all
// old identities, the sole existing pointer write, and fresh ownership/alias
// relations.  No bounded enumeration is involved.
lemma FrozenObservationsAgree<T>(
    state: NormalizedQueue<T>, item: T, freshId: int)
  requires CompleteSnapshot(state)
  requires freshId !in state.ownedObjects
  ensures ReferenceObservation(state, item, freshId) ==
          GeneratedObservation(state, item, freshId)
{
  assert state.firstId in state.cells;
  assert freshId != state.firstId;
  assert ExtendedSuffixes(state, item, freshId)[state.firstId] ==
         state.suffixes[state.firstId] + [item];
  assert state.suffixes[state.firstId] == state.abstractModel;
  assert ReferenceAfter(state, item, freshId) ==
         GeneratedAfter(state, item, freshId);
}
