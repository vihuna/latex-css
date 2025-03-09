---
-- HTML to LaTeX Pandoc filter for HTML documents using LaTeX.css style (https://latex.vercel.app)

-- Table whith those characters used inside the HTML document that are not supported by your LaTeX
-- distribution (to be filled with meta["chars"] from the command line or the "defaults" file).
local chars_to_replace = {}

-- Save frontmatter document info
local frontmatter = {
  ['title'] = nil,
  ['author'] = nil,
  ['abstract'] = nil,
}

-- Replace characters in a string, using the table `chars_to_replace`
local function replace_chars(t)
  for _, r in ipairs(chars_to_replace) do
    t = string.gsub(t, r[1], r[2])
  end
  return t
end

-- Check if array contains specific value
local function contains(arr, val)
  for _, v in ipairs(arr) do
    if v == val then
      return true
    end
  end
  return false
end

-- Get the array length
local function get_array_length(arr)
  local array_length = 0
  for _, _ in ipairs(arr) do
    array_length = array_length + 1
  end
  return array_length
end

-- Avoid "not nil" verification with `pandoc.utils.stringify`
local function pandoc_tostring(element)
  if element == nil then
    return nil
  else
    return pandoc.utils.stringify(element)
  end
end

-- Split into chunks a string separated by delimiters
local function split(string, sep_char)
  local chunks = {}
  string = string .. sep_char
  for match in string.gmatch(string, '[^' .. sep_char .. ']+' .. sep_char) do
    chunks[#chunks + 1] = string.sub(match, 1, #match - 1)
  end
  return chunks
end

-- Build the table containing the chars replacements
local function build_replacement_table(meta)
  local with_chars = false
  if meta['chars'] then
    with_chars = true
    for _, replacement in ipairs(meta['chars']) do
      chars_to_replace[#chars_to_replace + 1] = split(string.gsub(replacement, ' ', ''), '/')
    end
  end
  return with_chars
end

-- Filters
return {
  {
    -- Fill Pandoc LaTeX template variables
    -- NOTE: It's better to set the template variables with the meta function (instead of in the
    --       "defauls" file or the command-line), so the author can also modify them in the
    --       document metadata (values from command-line and "defaults" file have always
    --       preference). `listings` variable can't be set in the same way (it seems it has a special
    --       treatment, when is set to `true` loads the package, but also replaces `verbatim`
    --       environment), so a new variable `use_listings` should be created to "replace"
    --       `listings` role (TODO). And then,`Code` and `CodeBlock` functions must be customized
    --       (it must be done after the character replacement).
    Meta = function(m)
      -- chars_to_replace = build_replacement_table(m)
      build_replacement_table(m)
      -- Default A4 paper size unless otherwise specified (moved to "defaults" file)
      if m['papersize'] == nil then
        m['papersize'] = 'a4'
      end
      -- Default margins using `geometry` package
      if m['geometry'] == nil then
        m['geometry'] = { 'margin=3cm', 'marginparwidth=2cm' }
      end
      -- Default "11pt" font size
      if m['fontsize'] == nil then
        m['fontsize'] = '11pt'
      end
      -- `numbersections` true by default, unless otherwise specified
      -- NOTE: It has to be take into acount that any string different from `"false"` will be
      -- considered as `true`
      if m['numbersections'] == nil then
        m['numbersections'] = true
      elseif pandoc.utils.stringify(m['numbersections']) == 'false' then
        m['numbersections'] = false
      end
      -- `sectnumdepth = 3` by default, unless otherwise specified
      if m['secnumdepth'] == nil then
        m['secnumdepth'] = 3
      end
      -- Display ToC by default unless otherwise specified (moved to "defaults" file)
      if m['toc'] == nil then
        m['toc'] = true
      elseif pandoc.utils.stringify(m['toc']) == 'false' then
        m['toc'] = false
      end
      -- Show boxlinks by default
      if m['boxlinks'] == nil then
        m['boxlinks'] = true
      elseif pandoc.utils.stringify(m['boxlinks']) == 'false' then
        m['boxlinks'] = false
      end
      -- if m["use_listings"] == nil then m["use_listings"] = true end
      -- Use always `longtable` and `multirow` LaTeX packages
      -- NOTE: This is needed because due to our custom table processing, Pandoc writer no longer
      --       processes tables, so it doesn't determine which LaTeX "table" packages are
      --       necessary
      m['tables'] = true
      m['multirow'] = true
      -- Default English language for LaTeX.css math environments headings
      m['dfn_heading'] = 'Definition'
      m['lem_heading'] = 'Lemma'
      m['thm_heading'] = 'Theorem'
      -- Language localization for LaTeX.css math environments headings
      if m['lang'][1]['text'] == 'da' then
        m['dfn_heading'] = 'Definition'
        m['lem_heading'] = 'Lemma'
        m['thm_heading'] = 'Læresætning'
      end
      if m['lang'][1]['text'] == 'de' then
        m['dfn_heading'] = 'Definition'
        m['lem_heading'] = 'Lemma'
        m['thm_heading'] = 'Satz'
      end
      if m['lang'][1]['text'] == 'es' then
        m['dfn_heading'] = 'Definición'
        m['lem_heading'] = 'Lema'
        m['thm_heading'] = 'Teorema'
      end
      if m['lang'][1]['text'] == 'fr' then
        m['dfn_heading'] = 'Définition'
        m['lem_heading'] = 'Lemme'
        m['thm_heading'] = 'Théorème'
      end
      if m['lang'][1]['text'] == 'it' then
        m['dfn_heading'] = 'Definizione'
        m['lem_heading'] = 'Lemma'
        m['thm_heading'] = 'Teorema'
      end
      return m
    end,
  },
  {
    -- Process document "topmatter" template variables:
    -- get the topmatter content from LaTeX.css document
    Div = function(d)
      if contains(d.classes, 'abstract') and d.content[1].tag == 'Header' then
        table.remove(d.content, 1)
        frontmatter['abstract'] = d.content
      end
      if d.attributes['lcss-from'] == 'header' then
        if d.content[1].tag == 'Header' and d.content[1].level == 1 then
          frontmatter['title'] = d.content[1].content
        end
      end
      if d.attributes['lcss-from'] == 'p-author' then
        frontmatter['author'] = d.content
      end
      return d
    end,
  },
  {
    -- Process document "topmatter" template variables:
    -- pass the topmatter data to Pandoc metadata
    Meta = function(m)
      if m['use_doc_meta'] == nil or (m['use_doc_meta'] and pandoc.utils.stringify(m['use_doc_meta']) ~= 'true') then
        m['title'] = frontmatter['title']
        m['author'] = frontmatter['author']
        m['abstract'] = frontmatter['abstract']
      end
      return m
    end,
    -- Process document "topmatter" template variables:
    -- clean topmatter (avoid duplicated content)
    Div = function(d)
      local d1 = d
      if contains(d.classes, 'abstract') then
        d1 = {}
      end
      if d.attributes['lcss-from'] == 'header' then
        d1 = {}
      end
      if d.attributes['lcss-from'] == 'nav' then
        d1 = {}
      end
      return d1
    end,
  },
  {
    -- Replace unsupported characters. These seem all the possible final most internal objects
    -- inside Pandoc AST structure: `Str`, `Code`, `CodeBlock` and `Math`.
    Str = function(s)
      s.text = replace_chars(s.text)
      return s
    end,
    Code = function(c)
      c.text = replace_chars(c.text)
      return c
    end,
    Math = function(cb)
      cb.text = replace_chars(cb.text)
      return cb
    end,
    CodeBlock = function(m)
      m.text = replace_chars(m.text)
      return m
    end,
  },
  {
    -- Remove remote images (avoid LaTeX compilation error)
    Image = function(img)
      if string.match(img.src, 'https') then
        return pandoc.Str('[[Insert here the remote image:' .. img.src .. ']]')
      else
        return img
      end
    end,
    -- Format the footnotes
    Div = function(d)
      if contains(d.classes, 'footnotes') then
        return {
          pandoc.RawInline('latex', '\\vspace{5pt}\\rule{0.5\\linewidth}{0.5pt}'),
          -- pandoc.HorizontalRule(),
          d,
        }
      else
        return d
      end
    end,
    -- Transform LaTeX.css sidenotes into LaTeX margin notes
    Span = function(s)
      if contains(s.classes, 'sidenote') then
        local s1 = pandoc.RawInline('latex', '\\marginpar{\\small ')
        local s2 = pandoc.RawInline('latex', '}')
        return { s1, s, s2 }
      else
        return s
      end
    end,
  },
  {
    -- Fix "multirow" tables
    -- NOTE: It's better to "move" this function to the writer? By making the work here, Pandoc
    --       writer no longer processes tables and does not determine the needed LaTeX packages.
    --       Also, this is quite rough for the moment, it can be improved using Lpeg library.
    Table = function(t)
      local t1 = pandoc.write(pandoc.Pandoc(t), 'latex')
      t1 = string.gsub(t1, 'multirow{(%d-)}{=}{(%a)}', 'multirow{%1}{*}{%2}')
      return pandoc.RawBlock('latex', t1)
    end,
    -- Modify default LaTeX figure options
    -- NOTE: Like tables, it could be better to make this modifications while post-processing,
    -- and in a more precise way.
    Figure = function(f)
      local f1 = pandoc.write(pandoc.Pandoc(f), 'latex')
      f1 = string.gsub(f1, '\\begin{figure}%[?.-%]?', '\\begin{figure}[!htp]')
      return pandoc.RawBlock('latex', f1)
    end,
  },
  {
    -- Adjunst header levels
    Header = function(h)
      if h.level >= 2 then
        h.level = h.level - 1
      end
      return h
    end,
  },
  {
    -- Process LaTeX.css math environments
    Div = function(d)
      local d1 = d
      if contains(d.classes, 'definition') then
        d1 = {
          pandoc.RawBlock('latex', '\\begin{dfn}'),
          d,
          pandoc.RawBlock('latex', '\\end{dfn}'),
        }
      end
      if contains(d.classes, 'lemma') then
        d1 = {
          pandoc.RawBlock('latex', '\\begin{lem}'),
          d,
          pandoc.RawBlock('latex', '\\end{lem}'),
        }
      end
      if contains(d.classes, 'theorem') then
        d1 = {
          pandoc.RawBlock('latex', '\\begin{thm}'),
          d,
          pandoc.RawBlock('latex', '\\end{thm}'),
        }
      end
      if contains(d.classes, 'proof') then
        d1 = {
          pandoc.RawBlock('latex', '\\begin{proof}'),
          d,
          pandoc.RawBlock('latex', '\\end{proof}'),
        }
      end
      return d1
    end,
  },
  {
    -- Ignore DIV content when exporting to LaTeX
    Div = function(d)
      local d1 = d
      if contains(d.classes, 'latex-ignore') then
        d1 = {}
      end
      return d1
    end,
  },
}
