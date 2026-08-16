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
type Span = span: (int, int) | span.0 <= span.1 witness (0, 0)

ghost function SpanSize(span: Span): int
{
  span.1 - span.0
}

ghost predicate IsAdmissible(text: string, span: Span)
{
  0 <= span.0 <= span.1 <= |text| &&
  (forall i, j | span.0 <= i < j < span.1 :: text[i] != text[j])
}

method SelectDistinctWindow(text: string) returns (size: int, ghost chosen: Span)
  ensures IsAdmissible(text, chosen) && SpanSize(chosen) == size
  ensures forall candidate | IsAdmissible(text, candidate) :: SpanSize(candidate) <= size
{
  // Implement this body.
}
```
