# Archived pilot material

This directory contains disclosed runs that are not part of the active
five-case pilot.

`id771_segmented_weighted_sum/` was generated and verified before the active
set was finalized. It was later judged too direct because an executable
specification function computed the target's segment values. Replacing it
after observing that result is a post-generation selection decision, so the
active five must not be described as preregistered or used to estimate a pass
rate.

The archived response and results remain available for audit. They are excluded
from the default `./reproduce.sh` run and can be checked with:

```bash
./reproduce.sh --case archive-771
```
