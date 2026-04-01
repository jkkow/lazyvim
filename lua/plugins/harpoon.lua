return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      settings = {
        save_on_toggle = true,
      },
    },
    -- Overriding the LazyVim default keymap specifically for the quick menu
    -- to pass custom window size arguments to Harpoon 2
    keys = {
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list(), {
            ui_width_ratio = 1.0, -- Try to take up 100% of the window...
            ui_max_width = 70, -- ...but limit the absolute max width to 70 columns
          })
        end,
        desc = "Harpoon Quick Menu",
      },
    },
  },
}
