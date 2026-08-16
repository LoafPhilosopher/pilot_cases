include "../third_party/DafnyBench/DafnyBench/dataset/ground_truth/dafleet_tmp_tmpa2e4kb9v_0001-0050_0003-longest-substring-without-repeating-characters.dfy"
include "generated_attempt_01.dfy"

ghost function ToGeneratedSpan(iv: interval): Span
{
  (iv.0, iv.1)
}

ghost function ToReferenceInterval(span: Span): interval
{
  (span.0, span.1)
}

lemma ReferenceValidityIsGeneratedValidity(text: string, iv: interval)
  ensures valid_interval(text, iv) == IsAdmissible(text, ToGeneratedSpan(iv))
  ensures length(iv) == SpanSize(ToGeneratedSpan(iv))
{
}

lemma GeneratedValidityIsReferenceValidity(text: string, span: Span)
  ensures IsAdmissible(text, span) == valid_interval(text, ToReferenceInterval(span))
  ensures SpanSize(span) == length(ToReferenceInterval(span))
{
}

// Primary observational theorem.  It uses only the two public contracts, so
// it is independent of the algorithms chosen in their bodies.
method ImplementationsAgreeOnSize(text: string)
    returns (referenceSize: int, generatedSize: int,
             ghost referenceSpan: interval, ghost generatedSpan: Span)
  ensures referenceSize == generatedSize
  ensures valid_interval(text, referenceSpan)
  ensures IsAdmissible(text, generatedSpan)
  ensures length(referenceSpan) == referenceSize
  ensures SpanSize(generatedSpan) == generatedSize
  // Full ghost-endpoint equality follows when the maximum has a unique span.
  ensures (forall other: interval |
             valid_interval(text, other) && length(other) == referenceSize
             :: other == referenceSpan)
          ==> (referenceSpan.0 == generatedSpan.0 &&
               referenceSpan.1 == generatedSpan.1)
{
  referenceSize, referenceSpan := lengthOfLongestSubstring(text);
  generatedSize, generatedSpan := SelectDistinctWindow(text);

  ghost var generatedAsReference := ToReferenceInterval(generatedSpan);
  GeneratedValidityIsReferenceValidity(text, generatedSpan);
  assert valid_interval(text, generatedAsReference);
  assert length(generatedAsReference) == generatedSize;
  assert generatedSize <= referenceSize;

  ghost var referenceAsGenerated := ToGeneratedSpan(referenceSpan);
  ReferenceValidityIsGeneratedValidity(text, referenceSpan);
  assert IsAdmissible(text, referenceAsGenerated);
  assert SpanSize(referenceAsGenerated) == referenceSize;
  assert referenceSize <= generatedSize;
  assert referenceSize == generatedSize;

  if forall other: interval |
       valid_interval(text, other) && length(other) == referenceSize
       :: other == referenceSpan
  {
    assert generatedAsReference == referenceSpan;
    assert referenceSpan.0 == generatedSpan.0;
    assert referenceSpan.1 == generatedSpan.1;
  }
}
