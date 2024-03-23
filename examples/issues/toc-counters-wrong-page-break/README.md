Problem: Paged.js makes the page break in some element inside the list spliting
this list element and losing the numeration for that entry. It seems the ToC
processing to add the page numbers is promoting this issue.

Solution: Make Paged.js do page breaks in list elements only (using Paged.js
handlers).
