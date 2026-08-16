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
class Buffer<T(0)> {
  var first: Cell<T>
  var last: Cell<T>

  ghost var model: seq<T>
  ghost var owned: set<object>
  ghost var chain: set<Cell<T>>

  ghost predicate Consistent()
    reads this, owned
  {
    this in owned && chain <= owned &&
    first in chain &&
    last in chain &&
    last.successor == null &&
    (forall node ::
      node in chain ==>
        node.owned <= owned && this !in node.owned &&
        node.Consistent() &&
        (node.successor == null ==> node == last)) &&
    (forall node ::
      node in chain ==>
        node.successor != null ==> node.successor in chain) &&
    model == first.suffix
  }

  constructor Create()
    ensures Consistent() && fresh(owned - {this})
    ensures |model| == 0
  {
    var cell: Cell<T> := new Cell<T>.Create();
    first := cell;
    last := cell;
    model := cell.suffix;
    owned := {this} + cell.owned;
    chain := {cell};
  }

  method UpdateStructure(item: T)
    requires Consistent()
    modifies owned
    ensures Consistent() && fresh(owned - old(owned))
    ensures model == old(model) + [item]
  {
    // Target body omitted for generation.
  }
}

class Cell<T(0)> {
  var value: T
  var successor: Cell?<T>

  ghost var suffix: seq<T>
  ghost var owned: set<object>

  ghost predicate Consistent()
    reads this, owned
  {
    this in owned &&
    (successor != null ==>
      successor in owned && successor.owned <= owned) &&
    (successor == null ==> suffix == []) &&
    (successor != null ==> suffix == [successor.value] + successor.suffix)
  }

  constructor Create()
    ensures Consistent() && fresh(owned - {this})
    ensures successor == null
  {
    successor := null;
    suffix := [];
    owned := {this};
  }
}
```
