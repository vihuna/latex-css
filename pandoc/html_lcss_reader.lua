---
-- Allow `tex_math_dollars` extension
Extensions = {
  tex_math_dollars = true,
}

-- Use always `tex_math_dollars` extension
-- NOTE: I don't understand why this is needed because it has been set `tex_math_dollars = true`
-- in `Extensions`
local format = 'html+tex_math_dollars'

function Reader(input, opts)
  -- Different document input transformations for HTML elements "ignored" by Pandoc
  local input_str = tostring(input)

  -- This is a last minute issue: it seems in latest versions, Pandoc rules out the content outside
  -- `main` tag, when it's used in the document. And, what happens with `section` tags?
  input_str = string.gsub(input_str, '<%s-main([^>]-)>', '')
  input_str = string.gsub(input_str, '<%s-/main%s->', '')

  -- Transform `nav` section (ToC) to `div` block
  input_str = string.gsub(input_str, '<%s-nav([^>]-)>', '<div%1 data-lcss-from="nav">')
  input_str = string.gsub(input_str, '<%s-/nav%s->', '</div>')

  -- Transform `<p class="author">` into `<div class="author">`, because it seems Pandoc `Para`
  -- objects doesn't support attributes.
  input_str = string.gsub(
    input_str,
    '(<%s-header%s->.-)<%s-p%s-class%s-=%s-"author"%s->(.-)<%s-/p%s->(%s-<%s-/header%s->)',
    '%1<div data-lcss-from="p-author">%2</div>%3'
  )

  -- Transform `header` section to `div` block
  input_str = string.gsub(input_str, '<%s-header([^>]-)>', '<div%1 data-lcss-from="header">')
  input_str = string.gsub(input_str, '<%s-/header%s->', '</div>')

  -- Remove `label` and `input` elements from sidenotes construction, because Pandoc inserts a new
  -- paragraph instead of those elements
  input_str = string.gsub(input_str, '<%s-label%s[^>]-class%s-=%s-"[^"]-sidenote%-[^"]-"[^>]->[^<>]-<%s-/label%s->', '')
  input_str = string.gsub(input_str, '<%s-input%s[^>]-class%s-=%s-"[^"]-sidenote%-[^"]-"[^>]->', '')

  return pandoc.read(input_str, format, opts)
end
