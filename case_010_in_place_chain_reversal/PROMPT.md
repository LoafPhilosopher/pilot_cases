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
class Link<T> {
  ghost var View: seq<T>
  ghost var Owned: set<Link<T>>

  var value: T
  var successor: Link?<T>

  ghost predicate Consistent()
    reads this, Owned
  {
    this in Owned &&
    (successor == null ==> View == [value]) &&
    (successor != null ==>
      successor in Owned && successor.Owned <= Owned &&
      this !in successor.Owned &&
      View == [value] + successor.View &&
      successor.Consistent())
  }

  constructor Create(initial: T)
    ensures Consistent() && fresh(Owned)
    ensures View == [initial]
  {
    value, successor := initial, null;
    View, Owned := [initial], {this};
  }

  method Rewire() returns (result: Link<T>)
    requires Consistent()
    modifies Owned
    ensures result.Consistent() && result.Owned <= old(Owned)
    ensures |result.View| == |old(View)|
    ensures forall i ::
      0 <= i < |result.View| ==>
        result.View[i] == old(View)[|old(View)| - 1 - i]
  {
    // Target body omitted for generation.
  }
}
```
