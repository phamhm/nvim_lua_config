local F = require("utils.functions")
local alt_key = F.alt_key
local map = F.map

local function opts(desc_text, bufnr)
  return {desc="Markdown "..desc_text, buffer = bufnr or true, noremap = false, silent = true}
end

return {
  { -- https://github.com/hakonharnes/img-clip.nvim
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      filetypes = {
        markdown = {
          dir_path = string.format("%s/%s",vim.g.m_notes_path, "assets/images/"),
          use_absolute_path = true,
          template = "![$LABEL]($FILE_PATH)\n\n$CURSOR",
        },
      },
    },
    keys = { },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  -- Plugin spec
  {
    'jedi-knights/yaml.nvim',
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false,
      anti_conceal = {enabled = false},
    }
  },
  { -- https://github.com/jakewvincent/mkdnflow.nvim#statusline-components
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('mkdnflow').setup({
        modules = {
          links    = true,
          yaml     = true,
          conceal  = true,
          folds    = false,
          foldtext = false,
        },
        cursor = {
          jump_patterns = { "%[%[" },
        },
        mappings = {
          MkdnToggleToDo = {{'n', 'v'}, '<leader>tt'} -- Remaps to <leader>tt
        },
        on_attach = function(bufnr)
          map({"n", "i" }, alt_key("<%s-t>"), "<cmd>MkdnTableFormat<CR>", opts("format table", bufnr))
          map("n", alt_key("<%s-f>"), "gwap", opts("format pagraph", bufnr))
          map("n", alt_key("<%s-m>"), "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle", bufnr))

          map({'n', 'i'}, '>>', "<cmd>MkdnIndentListItem<CR>" , opts("Markdown indent list", bufnr))
          map({'n', 'i'}, '<<', "<cmd>MkdnDedentListItem<CR>", opts("Markdown deindent list", bufnr))
          map({'n'}, '<leader>fl',
            function()
              local path = vim.fn.expand("%:p")
              F.snacks_grep_markdown(path)
            end, opts("markdown headers", bufnr))

          map("n", "<leader>mq", function()
            local reg = string.format("```text\n%s\n```",vim.fn.getreg("+"))
            local lines = vim.split(reg, "\n")

            vim.api.nvim_put(lines, "l", true, false)
          end, opts("markdown quote from register @+", bufnr))

          map("n", "gF", function()
            local line = vim.api.nvim_get_current_line()
            -- Match markdown link syntax: [text](path_or_url)
            local link = line:match("%[.-%]%((.-)%)")

            if link then
              local md_link_item = {text = line, link = link}
              F.open_md_link(md_link_item)
            else
              -- Fallback to default gF behavior if no markdown link is under cursor
              vim.cmd("normal! gF")
            end
          end, opts("Open markdown link or fallback to gF"))

          map("n", "<leader>mA",
            function()
              local line = vim.api.nvim_get_current_line()
              local hashes = line:match("^#*") 
              local levels = #hashes

              local fn = function(heading)
                vim.ui.input({prompt = "Enter a new heading: ", default = string.rep("#", levels) .. " "}, function(new_header)
                  if new_header and new_header ~= "" then
                    vim.api.nvim_buf_set_lines(0, heading.end_line, heading.end_line, false, {new_header, ""})
                    vim.api.nvim_win_set_cursor(0, {heading.end_line+1, 0})
                  end
                end)
              end

              F.append_to_heading(line, fn)
            end,
            opts("markdown add child header"))

          map("n", "<leader>ma",
            function() 
              local line = vim.api.nvim_get_current_line()
              local hashes = line:match("^#*") 
              local levels = #hashes

              local fn = function(heading)
                vim.ui.input({prompt = "Enter a new heading: ", default = string.rep("#", levels+1) .. " "}, function(new_header)
                  if new_header and new_header ~= "" then
                    vim.api.nvim_buf_set_lines(0, heading.end_line, heading.end_line, false, {new_header, ""})
                    vim.api.nvim_win_set_cursor(0, {heading.end_line+1, 0})
                  end
                end)
              end

              F.append_to_heading(line, fn)
            end,
            opts("markdown add sibling header"))

          map("n", "<leader>mn",
            function() 
              local line = vim.api.nvim_get_current_line()

              local fn = function(heading)
                local new_header = string.format("* %s", os.date("%Y-%m-%d %I:%M%p: "))
                vim.api.nvim_buf_set_lines(0, heading.end_line, heading.end_line, false, {new_header, ""})
                vim.api.nvim_win_set_cursor(0, {heading.end_line+1, 0})
                vim.api.nvim_feedkeys('A', 'n', false)
              end

              F.append_to_heading(line, fn)
            end,
            opts("markdown append dated * to heading"))

          vim.opt_local.wrap           = true
          vim.opt_local.linebreak      = true
          vim.opt_local.breakindent    = true
          vim.opt_local.breakindentopt = "list:-1"
          vim.opt_local.number         = false
          vim.opt_local.relativenumber = false
          vim.opt_local.colorcolumn    = ""
          vim.opt_local.conceallevel   = 0
          vim.opt_local.number         = true
          vim.opt_local.relativenumber = true
        end,
      })
    end,
  }
}
