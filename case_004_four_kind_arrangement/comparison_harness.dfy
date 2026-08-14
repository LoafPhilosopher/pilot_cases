include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/formal_verication_dafny_tmp_tmpwgl2qz28_Challenges_ex7.dfy"
include "generated_attempt_01.dfy"

// The generated specification's AllowedPair predicate is exactly the
// nondecreasing order induced by Rank.
lemma AllowedPairImpliesRank(first: Kind, second: Kind)
  requires AllowedPair(first, second)
  ensures Rank(first) <= Rank(second)
{
  match first {
    case K0 =>
    case K1 =>
      match second {
        case K0 => assert !AllowedPair(first, second);
        case K1 =>
        case K2 =>
        case K3 =>
      }
    case K2 =>
      match second {
        case K0 => assert !AllowedPair(first, second);
        case K1 => assert !AllowedPair(first, second);
        case K2 =>
        case K3 =>
      }
    case K3 =>
      match second {
        case K0 => assert !AllowedPair(first, second);
        case K1 => assert !AllowedPair(first, second);
        case K2 => assert !AllowedPair(first, second);
        case K3 =>
      }
  }
}

lemma EqualRanksAreEqual(first: Kind, second: Kind)
  requires Rank(first) == Rank(second)
  ensures first == second
{
  match first {
    case K0 =>
      match second {
        case K0 =>
        case K1 => assert Rank(first) != Rank(second);
        case K2 => assert Rank(first) != Rank(second);
        case K3 => assert Rank(first) != Rank(second);
      }
    case K1 =>
      match second {
        case K0 => assert Rank(first) != Rank(second);
        case K1 =>
        case K2 => assert Rank(first) != Rank(second);
        case K3 => assert Rank(first) != Rank(second);
      }
    case K2 =>
      match second {
        case K0 => assert Rank(first) != Rank(second);
        case K1 => assert Rank(first) != Rank(second);
        case K2 =>
        case K3 => assert Rank(first) != Rank(second);
      }
    case K3 =>
      match second {
        case K0 => assert Rank(first) != Rank(second);
        case K1 => assert Rank(first) != Rank(second);
        case K2 => assert Rank(first) != Rank(second);
        case K3 =>
      }
  }
}

lemma MemberHasIndex(item: Kind, items: seq<Kind>)
  requires item in multiset(items)
  ensures exists i :: 0 <= i < |items| && items[i] == item
  decreases |items|
{
  assert 0 < |items|;
  assert items == [items[0]] + items[1..];
  if items[0] == item {
    assert 0 <= 0 < |items| && items[0] == item;
  } else {
    assert item !in multiset{items[0]};
    assert item in multiset(items[1..]);
    MemberHasIndex(item, items[1..]);
    var i :| 0 <= i < |items[1..]| && items[1..][i] == item;
    assert 0 <= i + 1 < |items| && items[i + 1] == item;
  }
}

lemma ValidArrangementTail(items: seq<Kind>)
  requires 0 < |items|
  requires ValidArrangement(items)
  ensures ValidArrangement(items[1..])
{
  forall j, k | 0 <= j < k < |items[1..]|
    ensures AllowedPair(items[1..][j], items[1..][k])
  {
    assert items[1..][j] == items[j + 1];
    assert items[1..][k] == items[k + 1];
    assert 0 <= j + 1 < k + 1 < |items|;
  }
}

lemma FirstHasLeastRank(items: seq<Kind>, item: Kind)
  requires 0 < |items|
  requires ValidArrangement(items)
  requires item in multiset(items)
  ensures Rank(items[0]) <= Rank(item)
{
  MemberHasIndex(item, items);
  var i :| 0 <= i < |items| && items[i] == item;
  if i == 0 {
  } else {
    assert 0 < i < |items|;
    assert AllowedPair(items[0], items[i]);
    AllowedPairImpliesRank(items[0], items[i]);
  }
}

lemma CancelKindSingleton(left: multiset<Kind>, right: multiset<Kind>, item: Kind)
  requires multiset{item} + left == multiset{item} + right
  ensures left == right
{
  forall k: Kind
    ensures left[k] == right[k]
  {
    assert (multiset{item} + left)[k] == (multiset{item} + right)[k];
  }
}

// Relational specification theorem: there is at most one valid arrangement
// for any given multiset.  This is independent of either implementation.
lemma UniqueValidArrangement(left: seq<Kind>, right: seq<Kind>)
  requires ValidArrangement(left)
  requires ValidArrangement(right)
  requires multiset(left) == multiset(right)
  ensures left == right
  decreases |left|
{
  assert |left| == |multiset(left)|;
  assert |right| == |multiset(right)|;
  assert |left| == |right|;

  if |left| == 0 {
    assert left == [];
    assert right == [];
  } else {
    assert 0 < |right|;
    assert left == [left[0]] + left[1..];
    assert right == [right[0]] + right[1..];
    assert left[0] in multiset(left);
    assert right[0] in multiset(right);
    assert left[0] in multiset(right);
    assert right[0] in multiset(left);

    FirstHasLeastRank(left, right[0]);
    FirstHasLeastRank(right, left[0]);
    assert Rank(left[0]) == Rank(right[0]);
    EqualRanksAreEqual(left[0], right[0]);

    ValidArrangementTail(left);
    ValidArrangementTail(right);
    assert multiset{left[0]} + multiset(left[1..]) ==
           multiset{left[0]} + multiset(right[1..]);
    CancelKindSingleton(multiset(left[1..]), multiset(right[1..]), left[0]);
    UniqueValidArrangement(left[1..], right[1..]);
    assert left == right;
  }
}

// Two calls are proved equal using only Transform's public contract.
method GeneratedCallsAgree(items: seq<Kind>) returns (first: seq<Kind>, second: seq<Kind>)
  requires 0 < |items|
  ensures first == second
{
  first := Transform(items);
  second := Transform(items);
  UniqueValidArrangement(first, second);
}

function ToKind(base: Bases): Kind
{
  match base
    case A => K0
    case C => K1
    case G => K2
    case T => K3
}

function ToBase(kind: Kind): Bases
{
  match kind
    case K0 => A
    case K1 => C
    case K2 => G
    case K3 => T
}

lemma BaseRoundTrip(base: Bases)
  ensures ToBase(ToKind(base)) == base
{
  match base {
    case A =>
    case C =>
    case G =>
    case T =>
  }
}

lemma KindRoundTrip(kind: Kind)
  ensures ToKind(ToBase(kind)) == kind
{
  match kind {
    case K0 =>
    case K1 =>
    case K2 =>
    case K3 =>
  }
}

lemma ToKindInjective(first: Bases, second: Bases)
  requires ToKind(first) == ToKind(second)
  ensures first == second
{
  BaseRoundTrip(first);
  BaseRoundTrip(second);
  assert ToBase(ToKind(first)) == ToBase(ToKind(second));
}

lemma MappingCorrespondence(base: Bases, kind: Kind)
  ensures (ToKind(base) == kind) <==> (base == ToBase(kind))
{
  BaseRoundTrip(base);
  KindRoundTrip(kind);
  if ToKind(base) == kind {
    assert ToBase(ToKind(base)) == ToBase(kind);
  } else if base == ToBase(kind) {
    assert ToKind(base) == ToKind(ToBase(kind));
  }
}

function Encode(items: seq<Bases>): seq<Kind>
  ensures |Encode(items)| == |items|
  decreases |items|
{
  if |items| == 0 then
    []
  else
    [ToKind(items[0])] + Encode(items[1..])
}

lemma EncodeAt(items: seq<Bases>, i: int)
  requires 0 <= i < |items|
  ensures Encode(items)[i] == ToKind(items[i])
  decreases i
{
  assert 0 < |items|;
  assert Encode(items) == [ToKind(items[0])] + Encode(items[1..]);
  if i == 0 {
  } else {
    assert 0 <= i - 1 < |items[1..]|;
    EncodeAt(items[1..], i - 1);
    assert Encode(items)[i] == Encode(items[1..])[i - 1];
    assert items[i] == items[1..][i - 1];
  }
}

lemma EncodeMultiplicity(items: seq<Bases>, kind: Kind)
  ensures multiset(Encode(items))[kind] == multiset(items)[ToBase(kind)]
  decreases |items|
{
  if |items| == 0 {
  } else {
    assert items == [items[0]] + items[1..];
    assert Encode(items) == [ToKind(items[0])] + Encode(items[1..]);
    EncodeMultiplicity(items[1..], kind);
    MappingCorrespondence(items[0], kind);

    if ToKind(items[0]) == kind {
      assert items[0] == ToBase(kind);
      assert multiset(Encode(items))[kind] ==
             1 + multiset(Encode(items[1..]))[kind];
      assert multiset(items)[ToBase(kind)] ==
             1 + multiset(items[1..])[ToBase(kind)];
    } else {
      assert items[0] != ToBase(kind);
      assert multiset(Encode(items))[kind] ==
             multiset(Encode(items[1..]))[kind];
      assert multiset(items)[ToBase(kind)] ==
             multiset(items[1..])[ToBase(kind)];
    }
  }
}

lemma EncodePreservesMultisetEquality(first: seq<Bases>, second: seq<Bases>)
  requires multiset(first) == multiset(second)
  ensures multiset(Encode(first)) == multiset(Encode(second))
{
  forall kind: Kind
    ensures multiset(Encode(first))[kind] == multiset(Encode(second))[kind]
  {
    EncodeMultiplicity(first, kind);
    EncodeMultiplicity(second, kind);
    assert multiset(first)[ToBase(kind)] == multiset(second)[ToBase(kind)];
  }
}

lemma BelowImpliesAllowedPair(first: Bases, second: Bases)
  requires below(first, second)
  ensures AllowedPair(ToKind(first), ToKind(second))
{
  match first {
    case A =>
    case C =>
      match second {
        case A => assert !below(first, second);
        case C =>
        case G =>
        case T =>
      }
    case G =>
      match second {
        case A => assert !below(first, second);
        case C => assert !below(first, second);
        case G =>
        case T =>
      }
    case T =>
      match second {
        case A => assert !below(first, second);
        case C => assert !below(first, second);
        case G => assert !below(first, second);
        case T =>
      }
  }
}

lemma EncodePreservesArrangement(items: seq<Bases>)
  requires bordered(items)
  ensures ValidArrangement(Encode(items))
{
  forall j, k | 0 <= j < k < |Encode(items)|
    ensures AllowedPair(Encode(items)[j], Encode(items)[k])
  {
    assert 0 <= j < k < |items|;
    EncodeAt(items, j);
    EncodeAt(items, k);
    assert below(items[j], items[k]);
    BelowImpliesAllowedPair(items[j], items[k]);
  }
}

lemma EncodeInjective(first: seq<Bases>, second: seq<Bases>)
  requires Encode(first) == Encode(second)
  ensures first == second
{
  assert |first| == |second|;
  forall i | 0 <= i < |first|
    ensures first[i] == second[i]
  {
    EncodeAt(first, i);
    EncodeAt(second, i);
    assert Encode(first)[i] == Encode(second)[i];
    ToKindInjective(first[i], second[i]);
  }
}

// The two concrete implementations agree after the obvious constructor
// renaming A/C/G/T <-> K0/K1/K2/K3.
method ImplementationsAgree(items: seq<Bases>)
    returns (original: seq<Bases>, generated: seq<Kind>)
  requires 0 < |items|
  ensures Encode(original) == generated
{
  original := Sorter(items);
  generated := Transform(Encode(items));

  EncodePreservesArrangement(original);
  EncodePreservesMultisetEquality(original, items);
  assert multiset(Encode(original)) == multiset(Encode(items));
  assert multiset(Encode(items)) == multiset(generated);
  UniqueValidArrangement(Encode(original), generated);
}

// The same specification-level argument also proves that two calls to the
// ground-truth implementation cannot choose different valid arrangements.
method GroundTruthCallsAgree(items: seq<Bases>)
    returns (first: seq<Bases>, second: seq<Bases>)
  requires 0 < |items|
  ensures first == second
{
  first := Sorter(items);
  second := Sorter(items);

  EncodePreservesArrangement(first);
  EncodePreservesArrangement(second);
  assert multiset(first) == multiset(second);
  EncodePreservesMultisetEquality(first, second);
  UniqueValidArrangement(Encode(first), Encode(second));
  EncodeInjective(first, second);
}
