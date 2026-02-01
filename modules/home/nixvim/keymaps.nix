{ ... }: [
  # Navigation & Explorer
  { mode = "n"; key = "<C-n>"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle Neo-tree"; }
  { mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<CR>"; options.desc = "Open Lazygit"; }

  # Formatting & Source Control
  { mode = "n"; key = "gg=G"; action = "<cmd>lua vim.lsp.buf.format()<CR>"; options = { silent = true; desc = "format whole file"; }; }

  # Terminal & Development
  { mode = "n"; key = "<C-t>"; action = "<cmd>ToggleTerm<CR>"; options.desc = "Toggle Floating Terminal"; }
  { mode = "n"; key = "rp"; action = "<cmd>split | term cargo run<CR>i"; options.desc = "Cargo Run Project"; }
  { mode = "n"; key = "rb"; action = "<cmd>split | term cargo build<CR>i"; options.desc = "Cargo Build Project"; }
  { mode = "n"; key = "qqq:"; action = "<nop>"; options.desc = "Disable command-lin window"; }
]

