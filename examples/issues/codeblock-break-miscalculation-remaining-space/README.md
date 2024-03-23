Problem: Paged.js miscalculates a little the remaining height of the page when
the breaktoken is inside a code block; as a consequence, a few lines are not
displayed.

Fix: Cheat Paged.js before the breaktoken is added, so it thinks there is less
space available and the breaktoken is added "earlier"; then remove this extra
space, after the page has been created, so the code block fragment is raised up
and there is an extra safety margin.

Note: In this example also occurs the issue with the newline character missing.
