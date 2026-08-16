include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafny-language-server_tmp_tmpkir0kenl_Test_vacid0_Composite.dfy"
include "generated_attempt_01.dfy"

ghost predicate IsBijection(
    referenceUniverse: set<Composite>,
    generatedUniverse: set<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
{
  pairing.Keys == referenceUniverse &&
  pairing.Values == generatedUniverse &&
  (forall first, second: Composite |
     first in referenceUniverse && second in referenceUniverse &&
     pairing[first] == pairing[second]
     :: first == second)
}

ghost predicate ActiveSetsCorrespond(
    referenceActive: set<Composite>,
    generatedActive: set<AggregateNode>,
    referenceUniverse: set<Composite>,
    generatedUniverse: set<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
{
  referenceUniverse <= pairing.Keys &&
  referenceActive <= referenceUniverse &&
  generatedActive <= generatedUniverse &&
  (forall node: Composite | node in referenceUniverse
     :: (node in referenceActive) == (pairing[node] in generatedActive))
}

ghost predicate StructureAndPayloadCorrespond(
    referenceUniverse: set<Composite>,
    generatedUniverse: set<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
  reads referenceUniverse, generatedUniverse
{
  IsBijection(referenceUniverse, generatedUniverse, pairing) &&
  (forall reference: Composite | reference in referenceUniverse ::
    var generated := pairing[reference];
    reference.val == generated.payload &&
    ((reference.parent == null && generated.predecessor == null) ||
     (reference.parent != null && generated.predecessor != null &&
      reference.parent in referenceUniverse &&
      pairing[reference.parent] == generated.predecessor)) &&
    ((reference.left == null && generated.childA == null) ||
     (reference.left != null && generated.childA != null &&
      reference.left in referenceUniverse &&
      pairing[reference.left] == generated.childA)) &&
    ((reference.right == null && generated.childB == null) ||
     (reference.right != null && generated.childB != null &&
      reference.right in referenceUniverse &&
      pairing[reference.right] == generated.childB)))
}

ghost predicate FullHeapRelation(
    referenceUniverse: set<Composite>,
    generatedUniverse: set<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
  reads referenceUniverse, generatedUniverse
{
  StructureAndPayloadCorrespond(referenceUniverse, generatedUniverse, pairing) &&
  (forall reference: Composite | reference in referenceUniverse ::
    reference.sum == pairing[reference].aggregate)
}

// What the original public contracts expose after calls on two related heaps.
// This theorem is valid for the full frozen input domain.  Notice that the
// postcondition deliberately does not claim aggregate equality: neither public
// method contract states its per-node effect within the modifiable active set.
method ContractsPreserveStructureAndValidity(
    reference: Composite,
    generated: AggregateNode,
    change: int,
    ghost referenceActive: set<Composite>,
    ghost generatedActive: set<AggregateNode>,
    ghost referenceUniverse: set<Composite>,
    ghost generatedUniverse: set<AggregateNode>,
    ghost pairing: map<Composite, AggregateNode>)
  requires FullHeapRelation(referenceUniverse, generatedUniverse, pairing)
  requires ActiveSetsCorrespond(referenceActive, generatedActive,
                                referenceUniverse, generatedUniverse, pairing)
  requires reference in referenceUniverse && pairing[reference] == generated

  requires referenceActive <= referenceUniverse && reference.Acyclic(referenceActive)
  requires forall node :: node in referenceUniverse && node != reference ==> node.Valid(referenceUniverse)
  requires reference.parent != null ==>
    reference.parent in referenceUniverse &&
    (reference.parent.left == reference || reference.parent.right == reference)
  requires reference.left != null ==>
    reference.left in referenceUniverse && reference.left.parent == reference &&
    reference.left != reference.right
  requires reference.right != null ==>
    reference.right in referenceUniverse && reference.right.parent == reference &&
    reference.left != reference.right
  requires reference.sum + change == reference.val +
    (if reference.left == null then 0 else reference.left.sum) +
    (if reference.right == null then 0 else reference.right.sum)

  requires generatedActive <= generatedUniverse && generated.ChainFinite(generatedActive)
  requires forall node :: node in generatedUniverse && node != generated ==> node.Consistent(generatedUniverse)
  requires generated.predecessor != null ==>
    generated.predecessor in generatedUniverse &&
    (generated.predecessor.childA == generated || generated.predecessor.childB == generated)
  requires generated.childA != null ==>
    generated.childA in generatedUniverse && generated.childA.predecessor == generated &&
    generated.childA != generated.childB
  requires generated.childB != null ==>
    generated.childB in generatedUniverse && generated.childB.predecessor == generated &&
    generated.childA != generated.childB
  requires generated.aggregate + change == generated.payload +
    (if generated.childA == null then 0 else generated.childA.aggregate) +
    (if generated.childB == null then 0 else generated.childB.aggregate)

  modifies referenceActive`sum, generatedActive`aggregate
  ensures StructureAndPayloadCorrespond(referenceUniverse, generatedUniverse, pairing)
  ensures forall node :: node in referenceUniverse ==> node.Valid(referenceUniverse)
  ensures forall node :: node in generatedUniverse ==> node.Consistent(generatedUniverse)
{
  reference.Adjust(change, referenceActive, referenceUniverse);
  generated.PropagateUpdate(change, generatedActive, generatedUniverse);
}

ghost function ReferenceUpPath(node: Composite, active: set<Composite>): seq<Composite>
  requires node.Acyclic(active)
  reads active
  decreases active
{
  [node] +
    (if node.parent == null then []
     else ReferenceUpPath(node.parent, active - {node}))
}

ghost function GeneratedUpPath(node: AggregateNode, active: set<AggregateNode>): seq<AggregateNode>
  requires node.ChainFinite(active)
  reads active
  decreases active
{
  [node] +
    (if node.predecessor == null then []
     else GeneratedUpPath(node.predecessor, active - {node}))
}

ghost predicate PathsCorrespond(
    referencePath: seq<Composite>,
    generatedPath: seq<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
{
  |referencePath| == |generatedPath| &&
  (forall index | 0 <= index < |referencePath|
     :: referencePath[index] in pairing.Keys &&
        pairing[referencePath[index]] == generatedPath[index])
}

// The two traversal schemes visit corresponding predecessor chains.  This is
// an unbounded induction over the finite active set, not bounded testing.
lemma UpPathsCorrespond(
    reference: Composite,
    generated: AggregateNode,
    referenceActive: set<Composite>,
    generatedActive: set<AggregateNode>,
    referenceUniverse: set<Composite>,
    generatedUniverse: set<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
  requires StructureAndPayloadCorrespond(referenceUniverse, generatedUniverse, pairing)
  requires ActiveSetsCorrespond(referenceActive, generatedActive,
                                referenceUniverse, generatedUniverse, pairing)
  requires reference.Acyclic(referenceActive)
  requires generated.ChainFinite(generatedActive)
  requires reference in referenceUniverse && pairing[reference] == generated
  ensures PathsCorrespond(ReferenceUpPath(reference, referenceActive),
                          GeneratedUpPath(generated, generatedActive), pairing)
  decreases referenceActive
{
  assert reference in referenceActive;
  assert generated in generatedActive;
  assert (reference.parent == null) == (generated.predecessor == null);

  if reference.parent != null {
    assert generated.predecessor != null;
    assert reference.parent in referenceUniverse;
    assert pairing[reference.parent] == generated.predecessor;
    assert reference.parent.Acyclic(referenceActive - {reference});
    assert generated.predecessor.ChainFinite(generatedActive - {generated});

    assert ActiveSetsCorrespond(referenceActive - {reference},
                                generatedActive - {generated},
                                referenceUniverse, generatedUniverse, pairing) by {
      forall node: Composite | node in referenceUniverse
        ensures (node in referenceActive - {reference}) ==
                (pairing[node] in generatedActive - {generated})
      {
        if pairing[node] == generated {
          assert node == reference;
        }
      }
    }

    UpPathsCorrespond(reference.parent, generated.predecessor,
                      referenceActive - {reference}, generatedActive - {generated},
                      referenceUniverse, generatedUniverse, pairing);
  }
}

lemma MappedPathsHaveSameMembership(
    referencePath: seq<Composite>,
    generatedPath: seq<AggregateNode>,
    pairing: map<Composite, AggregateNode>)
  requires PathsCorrespond(referencePath, generatedPath, pairing)
  requires forall first, second: Composite |
    first in pairing.Keys && second in pairing.Keys &&
    pairing[first] == pairing[second]
    :: first == second
  ensures forall reference: Composite | reference in pairing.Keys ::
    (reference in referencePath) == (pairing[reference] in generatedPath)
{
  forall reference: Composite | reference in pairing.Keys
    ensures (reference in referencePath) == (pairing[reference] in generatedPath)
  {
    if reference in referencePath {
      var index :| 0 <= index < |referencePath| && referencePath[index] == reference;
      assert pairing[referencePath[index]] == generatedPath[index];
      assert pairing[reference] in generatedPath;
    }
    if pairing[reference] in generatedPath {
      var index :| 0 <= index < |generatedPath| &&
                    generatedPath[index] == pairing[reference];
      assert index < |referencePath|;
      assert referencePath[index] in pairing.Keys;
      assert pairing[referencePath[index]] == generatedPath[index];
      assert referencePath[index] == reference;
      assert reference in referencePath;
    }
  }
}

ghost predicate SnapshotCorresponds<R, G>(
    referenceUniverse: set<R>,
    generatedUniverse: set<G>,
    pairing: map<R, G>,
    referenceValues: map<R, int>,
    generatedValues: map<G, int>)
{
  pairing.Keys == referenceUniverse && pairing.Values == generatedUniverse &&
  referenceValues.Keys == referenceUniverse && generatedValues.Keys == generatedUniverse &&
  (forall reference | reference in referenceUniverse ::
    referenceValues[reference] == generatedValues[pairing[reference]])
}

ghost predicate AddsChangeExactlyOnPath<T>(
    universe: set<T>,
    path: seq<T>,
    before: map<T, int>,
    after: map<T, int>,
    change: int)
{
  before.Keys == universe && after.Keys == universe &&
  (forall node | node in universe ::
    after[node] == before[node] + (if node in path then change else 0))
}

// A full, per-node aggregate-effect theorem.  Its premises are exactly the
// effect seen in both bodies: add the same change on their corresponding
// upward paths and leave every other aggregate alone.
lemma CorrespondingPathEffectsPreserveValues<R, G>(
    referenceUniverse: set<R>,
    generatedUniverse: set<G>,
    pairing: map<R, G>,
    referencePath: seq<R>,
    generatedPath: seq<G>,
    referenceBefore: map<R, int>,
    generatedBefore: map<G, int>,
    referenceAfter: map<R, int>,
    generatedAfter: map<G, int>,
    change: int)
  requires SnapshotCorresponds(referenceUniverse, generatedUniverse, pairing,
                               referenceBefore, generatedBefore)
  requires |referencePath| == |generatedPath|
  requires forall index | 0 <= index < |referencePath| ::
    referencePath[index] in referenceUniverse &&
    pairing[referencePath[index]] == generatedPath[index]
  requires forall reference | reference in referenceUniverse ::
    (reference in referencePath) == (pairing[reference] in generatedPath)
  requires AddsChangeExactlyOnPath(referenceUniverse, referencePath,
                                  referenceBefore, referenceAfter, change)
  requires AddsChangeExactlyOnPath(generatedUniverse, generatedPath,
                                  generatedBefore, generatedAfter, change)
  ensures SnapshotCorresponds(referenceUniverse, generatedUniverse, pairing,
                              referenceAfter, generatedAfter)
{
}
