{ config, lib, ... }:
let
  cfg = config.local.nixvim;

in
{
  globals.mapleader = ";";
  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
    tabstop = 2;
    expandtab = true;
    undofile = true;
    undolevels = 10000;
    termguicolors = true;
  };
  extraConfigLua = lib.mkIf cfg.smartUndo ''
    local function setup_smart_undo()
      local dot_git = vim.fn.finddir(".git", ".;")
      if dot_git ~= "" then
        local repo_root = vim.fn.fnamemodify(dot_git, ":h")
        local marker = repo_root .. "/.undo"
        if vim.fn.filereadable(marker) == 1 or vim.fn.isdirectory(marker) == 1 then
          local undo_path = repo_root .. "/.undo_dir"
          if vim.fn.isdirectory(undo_path) == 0 then vim.fn.mkdir(undo_path, "p") end
          vim.opt.undodir = undo_path
          return
        end
      end
      local permanent_path = vim.fn.expand("~/.cache/nvim/undo-permanent")
      if vim.fn.isdirectory(permanent_path) == 0 then vim.fn.mkdir(permanent_path, "p") end
      vim.opt.undodir = permanent_path
    end
    setup_smart_undo()
  '';
}
