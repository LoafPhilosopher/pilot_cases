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

function Rank(k: Kind): nat
{
  if k == K0 then 0
  else if k == K1 then 1
  else if k == K2 then 2
  else 3
}

predicate Sorted(items: seq<Kind>)
  decreases |items|
{
  |items| <= 1 ||
  (Rank(items[0]) <= Rank(items[1]) && Sorted(items[1..]))
}

function Insert(item: Kind, items: seq<Kind>): seq<Kind>
  decreases |items|
{
  if |items| == 0 then
    [item]
  else if Rank(item) <= Rank(items[0]) then
    [item] + items
  else
    [items[0]] + Insert(item, items[1..])
}

function Sort(items: seq<Kind>): seq<Kind>
  decreases |items|
{
  if |items| == 0 then
    []
  else
    Insert(items[0], Sort(items[1..]))
}

lemma SortedTail(items: seq<Kind>)
  requires Sorted(items)
  requires 0 < |items|
  ensures Sorted(items[1..])
{
  if |items| == 1 {
    assert |items[1..]| == 0;
    assert Sorted(items[1..]);
  } else {
    assert 1 < |items|;
    assert Sorted(items[1..]);
  }
}

lemma PrependSorted(item: Kind, items: seq<Kind>)
  requires Sorted(items)
  requires 0 < |items| ==> Rank(item) <= Rank(items[0])
  ensures Sorted([item] + items)
{
  if |items| == 0 {
    assert |[item] + items| <= 1;
  } else {
    assert ([item] + items)[0] == item;
    assert ([item] + items)[1] == items[0];
    assert ([item] + items)[1..] == items;
    assert 1 < |[item] + items|;
  }
}

lemma InsertContent(item: Kind, items: seq<Kind>)
  ensures |Insert(item, items)| == |items| + 1
  ensures multiset(Insert(item, items)) == multiset(items) + multiset{item}
  decreases |items|
{
  if |items| == 0 {
    assert Insert(item, items) == [item];
    assert |Insert(item, items)| == |items| + 1;
    calc {
      multiset(Insert(item, items));
      == multiset([item]);
      == multiset{item};
      == multiset(items) + multiset{item};
    }
  } else if Rank(item) <= Rank(items[0]) {
    assert Insert(item, items) == [item] + items;
    assert |Insert(item, items)| == |items| + 1;
    calc {
      multiset(Insert(item, items));
      == multiset([item] + items);
      == multiset{item} + multiset(items);
      == multiset(items) + multiset{item};
    }
  } else {
    assert items == [items[0]] + items[1..];
    InsertContent(item, items[1..]);
    assert Insert(item, items) ==
      [items[0]] + Insert(item, items[1..]);
    calc {
      |Insert(item, items)|;
      == |[items[0]] + Insert(item, items[1..])|;
      == 1 + |Insert(item, items[1..])|;
      == 1 + (|items[1..]| + 1);
      == |items| + 1;
    }
    calc {
      multiset(Insert(item, items));
      == multiset([items[0]] + Insert(item, items[1..]));
      == multiset{items[0]} + multiset(Insert(item, items[1..]));
      == multiset{items[0]} +
         (multiset(items[1..]) + multiset{item});
      == (multiset{items[0]} + multiset(items[1..])) +
         multiset{item};
      == multiset(items) + multiset{item};
    }
  }
}

lemma InsertSorted(item: Kind, items: seq<Kind>)
  requires Sorted(items)
  ensures Sorted(Insert(item, items))
  decreases |items|
{
  if |items| == 0 {
    assert Insert(item, items) == [item] + items;
    PrependSorted(item, items);
  } else if Rank(item) <= Rank(items[0]) {
    assert Insert(item, items) == [item] + items;
    PrependSorted(item, items);
  } else {
    SortedTail(items);
    InsertSorted(item, items[1..]);
    InsertContent(item, items[1..]);

    assert 0 < |Insert(item, items[1..])|;
    assert Rank(items[0]) < Rank(item);

    if |items| == 1 {
      assert items[1..] == [];
      assert Insert(item, items[1..]) == [item];
      assert Insert(item, items[1..])[0] == item;
    } else {
      assert 1 < |items|;
      assert 0 < |items[1..]|;
      assert items[1..][0] == items[1];
      assert Rank(items[0]) <= Rank(items[1]);
      assert Rank(items[0]) <= Rank(items[1..][0]);

      if Rank(item) <= Rank(items[1..][0]) {
        assert Insert(item, items[1..]) == [item] + items[1..];
        assert Insert(item, items[1..])[0] == item;
      } else {
        assert Insert(item, items[1..]) ==
          [items[1..][0]] + Insert(item, items[1..][1..]);
        assert Insert(item, items[1..])[0] == items[1..][0];
      }
    }

    assert Rank(items[0]) <= Rank(Insert(item, items[1..])[0]);
    PrependSorted(items[0], Insert(item, items[1..]));
    assert Insert(item, items) ==
      [items[0]] + Insert(item, items[1..]);
  }
}

lemma SortProperties(items: seq<Kind>)
  ensures Sorted(Sort(items))
  ensures |Sort(items)| == |items|
  ensures multiset(Sort(items)) == multiset(items)
  decreases |items|
{
  if |items| == 0 {
    assert Sort(items) == [];
  } else {
    assert items == [items[0]] + items[1..];
    SortProperties(items[1..]);
    InsertSorted(items[0], Sort(items[1..]));
    InsertContent(items[0], Sort(items[1..]));
    assert Sort(items) == Insert(items[0], Sort(items[1..]));

    calc {
      |Sort(items)|;
      == |Insert(items[0], Sort(items[1..]))|;
      == |Sort(items[1..])| + 1;
      == |items[1..]| + 1;
      == |items|;
    }

    calc {
      multiset(Sort(items));
      == multiset(Insert(items[0], Sort(items[1..])));
      == multiset(Sort(items[1..])) + multiset{items[0]};
      == multiset(items[1..]) + multiset{items[0]};
      == multiset{items[0]} + multiset(items[1..]);
      == multiset(items);
    }
  }
}

lemma SortedFirstToIndex(items: seq<Kind>, i: int)
  requires Sorted(items)
  requires 0 <= i < |items|
  ensures Rank(items[0]) <= Rank(items[i])
  decreases i
{
  if i == 0 {
  } else {
    assert 1 < |items|;
    assert Rank(items[0]) <= Rank(items[1]);
    SortedTail(items);
    assert 0 <= i - 1 < |items[1..]|;
    SortedFirstToIndex(items[1..], i - 1);
    assert items[1..][0] == items[1];
    assert items[1..][i - 1] == items[i];
  }
}

lemma SortedIndexPair(items: seq<Kind>, j: int, k: int)
  requires Sorted(items)
  requires 0 <= j < k < |items|
  ensures Rank(items[j]) <= Rank(items[k])
  decreases j
{
  if j == 0 {
    SortedFirstToIndex(items, k);
  } else {
    SortedTail(items);
    assert 0 <= j - 1 < k - 1 < |items[1..]|;
    SortedIndexPair(items[1..], j - 1, k - 1);
    assert items[1..][j - 1] == items[j];
    assert items[1..][k - 1] == items[k];
  }
}

lemma RankAllows(first: Kind, second: Kind)
  requires Rank(first) <= Rank(second)
  ensures AllowedPair(first, second)
{
  assert first == K0 || first == K1 || first == K2 || first == K3;
  assert second == K0 || second == K1 || second == K2 || second == K3;

  if first == K0 {
    assert AllowedPair(first, second);
  } else if first == K1 {
    if second == K0 {
      assert Rank(first) == 1;
      assert Rank(second) == 0;
      assert false;
    } else if second == K1 {
      assert first == second;
      assert AllowedPair(first, second);
    } else if second == K2 {
      assert AllowedPair(first, second);
    } else {
      assert second == K3;
      assert AllowedPair(first, second);
    }
  } else if first == K2 {
    if second == K0 {
      assert Rank(first) == 2;
      assert Rank(second) == 0;
      assert false;
    } else if second == K1 {
      assert Rank(first) == 2;
      assert Rank(second) == 1;
      assert false;
    } else if second == K2 {
      assert first == second;
      assert AllowedPair(first, second);
    } else {
      assert second == K3;
      assert AllowedPair(first, second);
    }
  } else {
    assert first == K3;
    if second == K0 {
      assert Rank(first) == 3;
      assert Rank(second) == 0;
      assert false;
    } else if second == K1 {
      assert Rank(first) == 3;
      assert Rank(second) == 1;
      assert false;
    } else if second == K2 {
      assert Rank(first) == 3;
      assert Rank(second) == 2;
      assert false;
    } else {
      assert second == K3;
      assert first == second;
      assert AllowedPair(first, second);
    }
  }
}

method Transform(items: seq<Kind>) returns (result: seq<Kind>)
  requires 0 < |items|
  ensures |result| == |items|
  ensures ValidArrangement(result)
  ensures multiset(items) == multiset(result)
{
  SortProperties(items);
  result := Sort(items);

  forall j, k | 0 <= j < k < |result|
    ensures AllowedPair(result[j], result[k])
  {
    SortedIndexPair(result, j, k);
    RankAllows(result[j], result[k]);
  }

  assert ValidArrangement(result);
}
