--
-- Escape characters (to use it with code blocks)
local function html_escape(text)
  text = string.gsub(text, '<', '&lt;')
  text = string.gsub(text, '>', '&gt;')
  return text
end

-- Check if array contains specific value
local function contains(arr, val)
  for _, v in pairs(arr) do
    if v == val then
      return true
    end
  end
  return false
end

return {
  {
    -- Format Code Blocks for LaTeX.css style.
    CodeBlock = function(c)
      return pandoc.RawBlock('html', '<pre><code class="language-' .. c.attributes[1][2] .. '">' .. html_escape(c.text) .. '</code></pre>')
    end,
  },
  {
    Pandoc = function(p)
      return pandoc.Pandoc(p.blocks, p.meta)
    end,
  },
  {
    -- Adjudst header levels
    Header = function(h)
      if not contains(h.classes, 'title') then
        h.level = h.level + 1
      end
      return h
    end,
  },
  { -- Clean proof environment
    Div = function(d)
      local str_list = {}
      local div_proof_clean = {}
      if contains(d.classes, 'proof') then
        pandoc.walk_block(d, {
          Str = function(s)
            table.insert(str_list, s)
            return s
          end,
        })
        if #str_list > 0 then
          if str_list[#str_list].text == ' ◻' then
            local str_pos = 0
            div_proof_clean = pandoc.walk_block(d, {
              Str = function(s)
                str_pos = str_pos + 1
                if str_pos == #str_list then
                  return {}
                else
                  return s
                end
              end,
            })
          end
          if str_list[1].text == 'Proof.' then
            local str_pos = 0
            div_proof_clean = pandoc.walk_block(div_proof_clean, {
              Str = function(s)
                str_pos = str_pos + 1
                if str_pos == 1 then
                  return {}
                else
                  return s
                end
              end,
            })
          end
        end
        return div_proof_clean
      else
        return d
      end
    end,
  },
}
