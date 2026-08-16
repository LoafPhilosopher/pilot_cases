datatype Structure = Blank | Piece(int, Structure, Structure)

function ValuesOf(shape: Structure): set<int>
{
  ValuesIn(Layout(shape))
}

function ValuesIn(values: seq<int>): set<int>
{
  set value | value in values
}

predicate Structured(shape: Structure)
{
  StrictlyIncreasing(Layout(shape))
}

function Layout(shape: Structure): seq<int>
{
  match shape {
    case Blank => []
    case Piece(value, first, second) => Layout(first) + [value] + Layout(second)
  }
}

predicate StrictlyIncreasing(values: seq<int>)
{
  forall i, j :: 0 <= i < j < |values| ==> values[i] < values[j]
}

lemma ValuesInConcat(first: seq<int>, second: seq<int>)
  ensures ValuesIn(first + second) == ValuesIn(first) + ValuesIn(second)
{
  forall x
    ensures x in ValuesIn(first + second) <==>
            x in ValuesIn(first) + ValuesIn(second)
  {
    if x in ValuesIn(first + second) {
      assert x in first + second;
      var k :| 0 <= k < |first + second| && (first + second)[k] == x;
      if k < |first| {
        assert first[k] == x;
        assert x in first;
        assert x in ValuesIn(first);
      } else {
        assert 0 <= k - |first| < |second|;
        assert second[k - |first|] == x;
        assert x in second;
        assert x in ValuesIn(second);
      }
      assert x in ValuesIn(first) + ValuesIn(second);
    }

    if x in ValuesIn(first) + ValuesIn(second) {
      if x in ValuesIn(first) {
        assert x in first;
        var k :| 0 <= k < |first| && first[k] == x;
        assert 0 <= k < |first + second|;
        assert (first + second)[k] == x;
      } else {
        assert x in ValuesIn(second);
        assert x in second;
        var k :| 0 <= k < |second| && second[k] == x;
        assert 0 <= |first| + k < |first + second|;
        assert (first + second)[|first| + k] == x;
      }
      assert x in first + second;
      assert x in ValuesIn(first + second);
    }
  }
  assert ValuesIn(first + second) == ValuesIn(first) + ValuesIn(second);
}

lemma ValuesInSingleton(value: int)
  ensures ValuesIn([value]) == {value}
{
  forall x
    ensures x in ValuesIn([value]) <==> x in {value}
  {
    if x in ValuesIn([value]) {
      assert x in [value];
      var k :| 0 <= k < |[value]| && [value][k] == x;
      assert k == 0;
      assert x == value;
    }
    if x in {value} {
      assert x == value;
      assert x in [value];
      assert x in ValuesIn([value]);
    }
  }
  assert ValuesIn([value]) == {value};
}

lemma BlankFacts()
  ensures Structured(Blank)
  ensures ValuesOf(Blank) == {}
{
  assert Layout(Blank) == [];
  assert StrictlyIncreasing([]);
  assert forall x: int :: x !in ValuesIn([]);
  assert ValuesIn([]) == {};
}

lemma ValuesOfPiece(value: int, first: Structure, second: Structure)
  ensures ValuesOf(Piece(value, first, second)) ==
          ValuesOf(first) + {value} + ValuesOf(second)
{
  var left := Layout(first);
  var right := Layout(second);
  assert Layout(Piece(value, first, second)) == left + [value] + right;
  ValuesInConcat(left + [value], right);
  ValuesInConcat(left, [value]);
  ValuesInSingleton(value);
  assert ValuesIn(left + [value] + right) ==
         (ValuesIn(left) + {value}) + ValuesIn(right);
  assert ValuesOf(Piece(value, first, second)) ==
         ValuesOf(first) + {value} + ValuesOf(second);
}

lemma StructureFacts(value: int, first: Structure, second: Structure)
  requires Structured(Piece(value, first, second))
  ensures Structured(first)
  ensures Structured(second)
  ensures forall x :: x in ValuesOf(first) ==> x < value
  ensures forall x :: x in ValuesOf(second) ==> value < x
{
  var left := Layout(first);
  var right := Layout(second);
  var all := Layout(Piece(value, first, second));
  assert all == left + [value] + right;
  assert StrictlyIncreasing(all);

  forall i, j | 0 <= i < j < |left|
    ensures left[i] < left[j]
  {
    assert 0 <= i < j < |all|;
    assert all[i] == left[i];
    assert all[j] == left[j];
    assert all[i] < all[j];
  }
  assert StrictlyIncreasing(left);
  assert Structured(first);

  forall i, j | 0 <= i < j < |right|
    ensures right[i] < right[j]
  {
    var ii := |left| + 1 + i;
    var jj := |left| + 1 + j;
    assert 0 <= ii < jj < |all|;
    assert all[ii] == right[i];
    assert all[jj] == right[j];
    assert all[ii] < all[jj];
  }
  assert StrictlyIncreasing(right);
  assert Structured(second);

  forall x | x in ValuesOf(first)
    ensures x < value
  {
    assert x in ValuesIn(left);
    assert x in left;
    var i :| 0 <= i < |left| && left[i] == x;
    assert 0 <= i < |left| < |all|;
    assert all[i] == x;
    assert all[|left|] == value;
    assert all[i] < all[|left|];
  }

  forall x | x in ValuesOf(second)
    ensures value < x
  {
    assert x in ValuesIn(right);
    assert x in right;
    var i :| 0 <= i < |right| && right[i] == x;
    var ii := |left| + 1 + i;
    assert 0 <= |left| < ii < |all|;
    assert all[|left|] == value;
    assert all[ii] == x;
    assert all[|left|] < all[ii];
  }
}

lemma ComposeStructure(value: int, first: Structure, second: Structure)
  requires Structured(first)
  requires Structured(second)
  requires forall x :: x in ValuesOf(first) ==> x < value
  requires forall x :: x in ValuesOf(second) ==> value < x
  ensures Structured(Piece(value, first, second))
{
  var left := Layout(first);
  var right := Layout(second);
  var all := Layout(Piece(value, first, second));
  assert all == left + [value] + right;
  assert StrictlyIncreasing(left);
  assert StrictlyIncreasing(right);

  forall i, j | 0 <= i < j < |all|
    ensures all[i] < all[j]
  {
    if j < |left| {
      assert 0 <= i < j < |left|;
      assert left[i] < left[j];
      assert all[i] == left[i];
      assert all[j] == left[j];
    } else if j == |left| {
      assert 0 <= i < |left|;
      assert left[i] in left;
      assert left[i] in ValuesIn(left);
      assert left[i] in ValuesOf(first);
      assert left[i] < value;
      assert all[i] == left[i];
      assert all[j] == value;
    } else {
      var rj := j - |left| - 1;
      assert 0 <= rj < |right|;
      assert all[j] == right[rj];
      assert right[rj] in right;
      assert right[rj] in ValuesIn(right);
      assert right[rj] in ValuesOf(second);
      assert value < right[rj];

      if i < |left| {
        assert left[i] in left;
        assert left[i] in ValuesIn(left);
        assert left[i] in ValuesOf(first);
        assert left[i] < value;
        assert all[i] == left[i];
        assert left[i] < right[rj];
      } else if i == |left| {
        assert all[i] == value;
      } else {
        var ri := i - |left| - 1;
        assert 0 <= ri < rj < |right|;
        assert right[ri] < right[rj];
        assert all[i] == right[ri];
      }
    }
  }
  assert StrictlyIncreasing(all);
  assert Structured(Piece(value, first, second));
}

lemma InsertOnLeftSets(left: set<int>, right: set<int>, value: int, item: int)
  ensures (left + {item}) + {value} + right ==
          (left + {value} + right) + {item}
{
  forall x
    ensures x in (left + {item}) + {value} + right <==>
            x in (left + {value} + right) + {item}
  {
  }
  assert (left + {item}) + {value} + right ==
         (left + {value} + right) + {item};
}

lemma InsertOnRightSets(left: set<int>, right: set<int>, value: int, item: int)
  ensures left + {value} + (right + {item}) ==
          (left + {value} + right) + {item}
{
  forall x
    ensures x in left + {value} + (right + {item}) <==>
            x in (left + {value} + right) + {item}
  {
  }
  assert left + {value} + (right + {item}) ==
         (left + {value} + right) + {item};
}

method ExtendStructure(base: Structure, item: int) returns (result: Structure)
  requires Structured(base) && item !in ValuesOf(base)
  ensures Structured(result) && ValuesOf(result) == ValuesOf(base) + {item}
{
  match base
  case Blank =>
    assert base == Blank;
    result := Piece(item, Blank, Blank);
    BlankFacts();
    ComposeStructure(item, Blank, Blank);
    ValuesOfPiece(item, Blank, Blank);
    assert ValuesOf(result) == {item};
    assert ValuesOf(base) == {};
    assert ValuesOf(result) == ValuesOf(base) + {item};

  case Piece(value, first, second) =>
    assert base == Piece(value, first, second);
    StructureFacts(value, first, second);
    ValuesOfPiece(value, first, second);
    assert value in ValuesOf(base);
    assert item != value;

    if item < value {
      assert item !in ValuesOf(first);
      var extended := ExtendStructure(first, item);

      forall x | x in ValuesOf(extended)
        ensures x < value
      {
        assert x in ValuesOf(first) + {item};
        if x in ValuesOf(first) {
          assert x < value;
        } else {
          assert x == item;
          assert item < value;
        }
      }

      result := Piece(value, extended, second);
      ComposeStructure(value, extended, second);
      ValuesOfPiece(value, extended, second);
      InsertOnLeftSets(ValuesOf(first), ValuesOf(second), value, item);
      assert ValuesOf(result) ==
             (ValuesOf(first) + {item}) + {value} + ValuesOf(second);
      assert ValuesOf(result) == ValuesOf(base) + {item};
    } else {
      assert value < item;
      assert item !in ValuesOf(second);
      var extended := ExtendStructure(second, item);

      forall x | x in ValuesOf(extended)
        ensures value < x
      {
        assert x in ValuesOf(second) + {item};
        if x in ValuesOf(second) {
          assert value < x;
        } else {
          assert x == item;
          assert value < item;
        }
      }

      result := Piece(value, first, extended);
      ComposeStructure(value, first, extended);
      ValuesOfPiece(value, first, extended);
      InsertOnRightSets(ValuesOf(first), ValuesOf(second), value, item);
      assert ValuesOf(result) ==
             ValuesOf(first) + {value} + (ValuesOf(second) + {item});
      assert ValuesOf(result) == ValuesOf(base) + {item};
    }
}
