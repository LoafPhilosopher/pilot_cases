# Exact generation prompt

The following prompt was given to one isolated Coding Agent. It was instructed
not to use Web, tools, the filesystem, or a hidden reference; the generation
log records zero such calls before the code response, and the reference was not
included in its context.

> You are the isolated Coding Agent for one experimental run. You must not call
> any tool, browse the web, inspect the filesystem, ask another agent, or access
> any reference implementation. Work only from the source below. Complete the
> omitted target method body in Dafny 4.3.0.
> Return one complete Dafny source file that verifies. Preserve all supplied
> declarations, signatures, preconditions, and postconditions exactly. You may
> add proof annotations or helper declarations, but do not use `assume`,
> `{:verify false}`, `{:axiom}`, `{:extern}`, `decreases *`, or any other
> verification bypass. Do not add printing or other externally observable side
> effects. Output Dafny code only, without Markdown fences.

```dafny
ghost predicate HasWitnessBefore(values: array<int>, end: int, value: int)
  requires 0 <= end <= values.Length
  reads values
{
  exists i, j :: 0 <= i < j < end && values[i] == values[j] == value
}

ghost predicate HasWitness(values: array<int>, value: int)
  reads values
{
  HasWitnessBefore(values, values.Length, value)
}

method ChooseWitnesses(values: array<int>) returns (x: int, y: int)
  requires 4 <= values.Length
  requires exists x, y ::
    x != y && HasWitness(values, x) && HasWitness(values, y)
  requires forall i ::
    0 <= i < values.Length ==> 0 <= values[i] < values.Length - 2
  ensures x != y && HasWitness(values, x) && HasWitness(values, y)
{
  // Target body omitted for generation.
}
```
