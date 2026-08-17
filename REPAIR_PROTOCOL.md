# Repair protocol for the four failed first attempts

## Scope

Repair is applied only to Cases 002, 009, 010, and 013. Their original
`generated_attempt_01.dfy` files and historical logs remain unchanged. The
eleven first attempts that already passed Dafny are not repaired.

Each failed case has a budget of at most three repair rounds. The researcher
selected this limit and froze it before repair. Jocelyn agreed that the repair
budget should be fixed but did not select this specific number. A round consists
of one model response followed by one Dafny 4.3.0 verification. Repair stops at
the first verifier-passing response, so a case cannot receive extra rounds
after it passes.

## Information given to the repair model

The repair model receives only these task-specific materials:

1. the complete program from the previous attempt; and
2. the complete Dafny feedback from verifying that program.

For Round 01, the previous attempt is the preserved first-generation program.
For later rounds, it is the preceding round's saved output. The hidden
DafnyBench implementation, comparison harnesses, reports, and results from
other cases are not included. The model is instructed not to browse, call
tools, inspect the filesystem, or contact another agent. Platform instructions
and exposed tool interfaces still exist, so the record concerns actual use
rather than technical removal of those capabilities.

The repair model is `gpt-5.6-sol` at `ultra` reasoning effort. It must return
one complete Dafny source file and no commentary. No human edit is made to the
returned source before verification.

Every repair response is requested in a fresh context with no earlier
conversation turns. Round 01 feedback is produced by re-verifying only the
copied first-attempt candidate with the fixed Dafny version. The historical
case-level `verification.txt` is preserved but is not supplied, because it also
contains reference paths and unrelated experiment metadata.

For every later round, `input_program.dfy` must be byte-for-byte identical to
the preceding `output_program.dfy`, and `verifier_feedback.txt` must be copied
from that preceding round's saved verifier output. Feedback is neither
summarized nor regenerated between rounds.

## Files saved for every round

Each `repair/round_NN/` directory contains:

- `input_program.dfy`: the program supplied for repair;
- `verifier_feedback.txt`: the Dafny output supplied with that program;
- `repair_prompt.md`: the complete task-specific repair instruction;
- `generation_record.txt`: model, reasoning effort, fresh-context identifier,
  and any tool or inter-agent events before the response (or an explicit zero);
- `raw_response.txt`: the model's response exactly as received;
- `output_program.dfy`: the source submitted to Dafny, identical to the raw
  response when the model follows the code-only instruction; and
- `verification.txt`: the complete Dafny output and exit status for the saved
  output program.

If the response is not a code-only Dafny file, it is still preserved verbatim.
Mechanical removal of Markdown fences, commentary, or other text is not
allowed. Such a response is verified as saved and may consume a round.
If the agent makes a prohibited tool or inter-agent call, the event is recorded
as a protocol deviation and the round still counts. If it returns no complete
text program, `verification.txt` records that Dafny could not be run; this also
counts as a failed round.

## Stopping and comparison

- If a round passes Dafny, its output is the final repaired program for that
  case. Only that program is compared with the hidden reference.
- Failed intermediate rounds are never used for an equivalence claim.
- If all three rounds fail, the case is marked `repair-exhausted`. This is a
  repair outcome, not evidence that the program is behaviorally different
  from the reference.
- A verifier-passing repair is not automatically called equivalent. The case
  report must state whether the comparison gives equality under the current
  relation, a concrete counterexample, equality only under an additional
  condition, or no conclusion.

The repair study reports both the original first-attempt result and the repair
result. Repair success does not change the original count of 11 verifier-pass
first attempts out of 15.
