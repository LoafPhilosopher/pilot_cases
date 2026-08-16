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

method ExtendStructure(base: Structure, item: int) returns (result: Structure)
  requires Structured(base) && item !in ValuesOf(base)
  ensures Structured(result) && ValuesOf(result) == ValuesOf(base) + {item}
{
  // Target body omitted for generation.
}
