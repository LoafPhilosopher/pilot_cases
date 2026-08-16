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
