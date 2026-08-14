include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafny-rope_tmp_tmpl4v_njmy_Rope.dfy"
include "generated_attempt_01.dfy"

method ImplementationsAgree(
    reference: Rope.Rope,
    generated: StructuredStore.NodeStore,
    start: nat,
    stop: nat)
  returns (referenceOut: string, generatedOut: string)
  requires reference.Valid()
  requires generated.WellFormed()
  requires reference.Contents == generated.Model
  requires 0 <= start <= stop <= |reference.Contents|
  ensures referenceOut == generatedOut
{
  referenceOut := reference.report(start, stop);
  generatedOut := generated.ExtractWindow(start, stop);

  assert referenceOut == reference.Contents[start..stop];
  assert generatedOut == generated.Model[start..stop];
  assert referenceOut == generatedOut;
}
