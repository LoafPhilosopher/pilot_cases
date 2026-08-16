include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/Dafny-Practice_tmp_tmphnmt4ovh_BST.dfy"
include "generated_attempt_01.dfy"

function EncodeTree(tree: Tree): Structure
{
  match tree
    case Empty => Blank
    case Node(value, left, right) =>
      Piece(value, EncodeTree(left), EncodeTree(right))
}

lemma LayoutEncoding(tree: Tree)
  ensures Layout(EncodeTree(tree)) == Inorder(tree)
{
  match tree {
    case Empty =>
    case Node(value, left, right) =>
      LayoutEncoding(left);
      LayoutEncoding(right);
  }
}

lemma OrderingNamesAgree(values: seq<int>)
  ensures StrictlyIncreasing(values) <==> Ascending(values)
{
}

lemma ValueSetNamesAgree(values: seq<int>)
  ensures ValuesIn(values) == NumbersInSequence(values)
{
}

lemma AbstractionEncoding(tree: Tree)
  ensures ValuesOf(EncodeTree(tree)) == NumbersInTree(tree)
  ensures Structured(EncodeTree(tree)) <==> BST(tree)
{
  LayoutEncoding(tree);
  OrderingNamesAgree(Inorder(tree));
  ValueSetNamesAgree(Inorder(tree));
}

// This comparison calls the two retained implementations and proves their
// frozen abstract observations equal.  It uses only their public contracts
// plus the alpha-renaming lemmas above.
method ActualImplementationsAgreeAbstractly(tree: Tree, item: int)
  returns (referenceResult: Tree, generatedResult: Structure)
  requires BST(tree)
  requires item !in NumbersInTree(tree)
  ensures Structured(generatedResult)
  ensures Structured(EncodeTree(referenceResult))
  ensures ValuesOf(generatedResult) ==
    ValuesOf(EncodeTree(referenceResult))
{
  AbstractionEncoding(tree);
  referenceResult := InsertBST(tree, item);
  generatedResult := ExtendStructure(EncodeTree(tree), item);
  AbstractionEncoding(referenceResult);
  assert ValuesOf(generatedResult) ==
    ValuesOf(EncodeTree(tree)) + {item};
  assert NumbersInTree(referenceResult) ==
    NumbersInTree(tree) + {item};
}

// Pure equations obtained by deleting only proof-only statements from each
// target body.  They retain every executable branch, recursive call, and
// constructor assignment.
function ReferenceExecutable(tree: Tree, item: int): Tree
{
  match tree
    case Empty => Node(item, Empty, Empty)
    case Node(value, left, right) =>
      if item < value then
        Node(value, ReferenceExecutable(left, item), right)
      else
        Node(value, left, ReferenceExecutable(right, item))
}

function GeneratedExecutable(base: Structure, item: int): Structure
{
  match base
    case Blank => Piece(item, Blank, Blank)
    case Piece(value, first, second) =>
      if item < value then
        Piece(value, GeneratedExecutable(first, item), second)
      else
        Piece(value, first, GeneratedExecutable(second, item))
}

// Executable-body clones make the projection correspondence machine checked.
// Their bodies are the executable statements of the respective targets; all
// omitted source statements are lemmas, assertions, or ghost declarations.
method ReferenceExecutableClone(tree: Tree, item: int)
    returns (result: Tree)
  ensures result == ReferenceExecutable(tree, item)
  decreases tree
{
  match tree {
    case Empty =>
      result := Node(item, Empty, Empty);
    case Node(value, left, right) =>
      var extended: Tree := Empty;
      if item < value {
        extended := ReferenceExecutableClone(left, item);
        result := Node(value, extended, right);
      } else {
        extended := ReferenceExecutableClone(right, item);
        result := Node(value, left, extended);
      }
  }
}

method GeneratedExecutableClone(base: Structure, item: int)
    returns (result: Structure)
  ensures result == GeneratedExecutable(base, item)
  decreases base
{
  match base {
    case Blank =>
      result := Piece(item, Blank, Blank);
    case Piece(value, first, second) =>
      if item < value {
        var extended := GeneratedExecutableClone(first, item);
        result := Piece(value, extended, second);
      } else {
        var extended := GeneratedExecutableClone(second, item);
        result := Piece(value, first, extended);
      }
  }
}

lemma ExecutableProjectionAgreement(tree: Tree, item: int)
  ensures EncodeTree(ReferenceExecutable(tree, item)) ==
    GeneratedExecutable(EncodeTree(tree), item)
{
  match tree {
    case Empty =>
    case Node(value, left, right) =>
      if item < value {
        ExecutableProjectionAgreement(left, item);
      } else {
        ExecutableProjectionAgreement(right, item);
      }
  }
}

method ExecutableClonesAgree(tree: Tree, item: int)
    returns (referenceResult: Tree, generatedResult: Structure)
  ensures EncodeTree(referenceResult) == generatedResult
{
  referenceResult := ReferenceExecutableClone(tree, item);
  generatedResult := GeneratedExecutableClone(EncodeTree(tree), item);
  ExecutableProjectionAgreement(tree, item);
}

// The public contract alone does not determine raw shape.  These are two
// different valid shapes with the same value set.
lemma ContractShapeWitness()
  ensures Structured(Piece(1, Blank, Piece(2, Blank, Blank)))
  ensures Structured(Piece(2, Piece(1, Blank, Blank), Blank))
  ensures ValuesOf(Piece(1, Blank, Piece(2, Blank, Blank))) == {1, 2}
  ensures ValuesOf(Piece(2, Piece(1, Blank, Blank), Blank)) == {1, 2}
  ensures Piece(1, Blank, Piece(2, Blank, Blank)) !=
    Piece(2, Piece(1, Blank, Blank), Blank)
{
}
