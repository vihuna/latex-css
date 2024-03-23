Problem: It seems Paged.js miscalculates a little the dimensions, and the last
element doesn't fit well on the page. It seems the `float: left` CSS style for
list elements amplifies this issue.

Solution: Remove the `float: left` list counter, move the counter to the link; use
manual CSS `break-before: page;` style if the issue remains.
