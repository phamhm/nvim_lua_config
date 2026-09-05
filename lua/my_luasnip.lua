local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local markdown_snippets = {
    -- Link: [Title](url)
    s("link", fmt("[{}]({})", {
        i(1, "Text"),
        i(2, "url")
    })),

    -- Code Block: ```lang ... ```
    s("code", fmt("```{}\n{}\n```\n{}", {
        i(1, "lang"),
        i(2, "code"),
        i(0)
    })),

    -- Inline Code: `code`
    s("ic", fmt("`{}`{}", {
        i(1, "code"),
        i(0)
    })),

    -- Bold: **text**
    s("bold", fmt("**{}**{}", {
        i(1, "text"),
        i(0)
    })),

    -- Checkbox Task
    s("todo", fmt("- [ ] {} ", {
        i(1, "description")
    })),

    -- Image: ![Alt](path)
    s("img", fmt("![{}]({}){}", {
        i(1, "alt text"),
        i(2, "path/to/image"),
        i(0)
    })),

    -- Simple 2x2 Table
    s("table", fmt([[
| {} | {} |
| --- | --- |
| {} | {} |
{}
    ]], {
        i(1, "Header 1"), i(2, "Header 2"),
        i(3, "Cell 1"), i(4, "Cell 2"),
        i(0)
    })),

}

ls.add_snippets("markdown", markdown_snippets)
ls.add_snippets("vimwiki", markdown_snippets)


-- Expand snippet or jump forward
vim.keymap.set({"i", "s"}, "<C-1>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, {silent = true})

-- Jump backward
vim.keymap.set({"i", "s"}, "<C-0>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, {silent = true})
