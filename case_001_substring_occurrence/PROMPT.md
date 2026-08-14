# Exact generation prompt

The Coding Agent was isolated from the ground-truth implementation and was
instructed not to use Web search, tools, or the filesystem. The generation log
records zero such calls before the code response.

## System/task instruction

You are the isolated Coding Agent for one experiment. Do not use web search, do
not call any tools, do not read any files, and do not rely on external context.
Use only the Dafny prompt below. Return only one complete Dafny program, with no
Markdown fences or prose. Target Dafny 4.3.0. You must keep the supplied
declarations, signature, and specification unchanged. Implement the method body
and add proof annotations or helper lemmas only if needed. Do not use `assume`,
`{:verify false}`, `{:axiom}`, `{:extern}`, `decreases *`, or any
verification/trust bypass.

## Program supplied to the agent

```dafny
ghost predicate ContainsAtLeastOnce(source: string, pattern: string) {
  exists position :: 0 <= position <= |source| && pattern <= source[position..]
}

ghost predicate ResultCondition(source: string, pattern: string, ok: bool, index: nat) {
  (ok <==> ContainsAtLeastOnce(source, pattern)) &&
  (ok ==> index + |pattern| <= |source| && pattern <= source[index..])
}

method ComputeWitness(source: string, pattern: string) returns (ok: bool, index: nat)
  ensures ResultCondition(source, pattern, ok, index)
{
  // Implement this body.
}
```
