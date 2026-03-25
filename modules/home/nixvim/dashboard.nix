{ ... }:
{
  enable = true;
  theme = "dashboard";
  settings.layout = [
    {
      type = "text";
      val = [
        " ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗"
        " ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝"
        " ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗"
        " ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║"
        " ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║"
        " ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
      ];
      opts = {
        position = "center";
        hl = "Type";
      };
    }
    { type = "padding"; val = 2; }
    {
      type = "group";
      val = [
        {
          type = "button";
          val = "  Find File";
          on_press.__raw = "function() require('telescope.builtin').find_files() end";
          opts = { shortcut = "f"; keymap = [ "n" "f" "<cmd>Telescope find_files<CR>" { silent = true; } ]; };
        }
        {
          type = "button";
          val = "󰈚  Recent Files";
          on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
          opts = { shortcut = "r"; keymap = [ "n" "r" "<cmd>Telescope oldfiles<CR>" { silent = true; } ]; };
        }
        {
          type = "button";
          val = "󱔗  Open Dotfiles";
          on_press.__raw = "function() vim.cmd('cd ~/dotfiles | Neotree') end";
          opts = { shortcut = "d"; keymap = [ "n" "d" "<cmd>cd ~/dotfiles | Neotree<CR>" { silent = true; } ]; };
        }
        {
          type = "button";
          val = "󰊢  LazyGit";
          on_press.__raw = "function() vim.cmd('LazyGit') end";
          opts = { shortcut = "g"; keymap = [ "n" "g" "<cmd>LazyGit<CR>" { silent = true; } ]; };
        }
        {
          type = "button";
          val = "󰒲  Quit Neovim";
          on_press.__raw = "function() vim.cmd('qa') end";
          opts = { shortcut = "q"; keymap = [ "n" "q" "<cmd>qa<CR>" { silent = true; } ]; };
        }
      ];
    }
  ];
}
