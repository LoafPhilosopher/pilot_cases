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
class CountRepresentation {
  function AbstractView(counts: map<int, nat>): multiset<int>
    ensures (forall key | key in counts :: counts[key] == AbstractView(counts)[key]) &&
      (counts == map[] <==> AbstractView(counts) == multiset{}) &&
      (forall key :: key in counts <==> key in AbstractView(counts))

  lemma RepresentationAgreement(counts: map<int, nat>, values: seq<int>)
    requires (forall key | key in counts :: counts[key] == multiset(values)[key]) &&
      (counts == map[] <==> multiset(values) == multiset{})
    ensures AbstractView(counts) == multiset(values)

  method ExpandRepresentation(counts: map<int, nat>) returns (values: seq<int>)
    requires forall key | key in counts.Keys :: key in counts.Keys <==> counts[key] > 0
    ensures forall key | key in counts.Keys :: multiset(values)[key] == counts[key]
    ensures forall key | key in counts.Keys :: key in values
    ensures AbstractView(counts) == multiset(values)
    ensures (forall key | key in counts :: counts[key] == multiset(values)[key]) &&
      (counts == map[] <==> multiset(values) == multiset{})
  {
    // Target body omitted for generation.
  }
}
```
