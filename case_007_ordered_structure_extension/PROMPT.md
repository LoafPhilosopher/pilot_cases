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
```
