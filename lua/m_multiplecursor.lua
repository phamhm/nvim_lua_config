local F = require("utils.functions")

return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    local set = F.map
    -- Add or skip cursor above/below the main cursor.
    set({"n", "x"}, "<C-k>", function() mc.lineAddCursor(-1) end)
    set({"n", "x"}, "<C-j>", function() mc.lineAddCursor(1) end)
    set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
    set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)
    -- Add or skip adding a new cursor by matching word/selection
    set({"n", "x"}, F.format_os_altkey("<%s-n>"),function() mc.matchAddCursor(1) end)
    set({"n", "x"}, F.format_os_altkey("<%s-p>"),function() mc.matchAddCursor(-1) end)
    set({"n", "x"}, F.format_os_altkey("<%s-s>"),function() mc.matchSkipCursor(1) end)
    set({"n", "x"}, F.format_os_altkey("<%s-S>"),function() mc.matchSkipCursor(-2) end)
    -- Add and remove cursors with control + left click.
    set("n", "<c-leftmouse>", mc.handleMouse)
    set("n", "<c-leftdrag>", mc.handleMouseDrag)
    set("n", "<c-leftrelease>", mc.handleMouseRelease)
    -- Disable and enable cursors.
    set({"n", "x"}, "<c-t>", mc.toggleCursor) -- this will toggle the cursor, then use tab to start editor
    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({"n", "x"}, "<C-p>", mc.prevCursor)
      layerSet({"n", "x"}, "<C-n>", mc.nextCursor)
      -- Delete the main cursor.
      layerSet({"n", "x"}, "<C-x>", mc.deleteCursor)
      layerSet({"n", "x"}, "<C-c>", mc.clearCursors)
      -- Enable and clear cursors using escape.
      layerSet("n", "<Tab>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn"})
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
  end
}
