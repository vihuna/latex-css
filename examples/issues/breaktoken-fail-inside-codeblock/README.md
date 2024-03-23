Problem: Paged.js fails to add the `breakToken` inside some code blocks.

Solution: Move down the code block element a little, so Paged.js has another
chance to find the `breakToken`.

Note: Other related problems still remains. The first line of the code in the new
page can lose the indentation, and also there are some missing newline characters.
