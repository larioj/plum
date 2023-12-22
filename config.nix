{
  packageOverrides = pkgs: {
    neovim = pkgs.neovim.override {
      configure = with pkgs.vimPlugins; {
        customRC = "source ~/.config/nvim/init.vim";
        packages.myVimPackage.start = [
          YouCompleteMe
          fugitive
          auto-save-nvim
          gruvbox
          ale
          fzf-vim
          rhubarb
          vim-table-mode
          vim-automkdir
          /*
          (pkgs.vimUtils.buildVimPlugin {
            name = "plum";
            src = pkgs.fetchFromGitHub {
              owner = "larioj";
              repo = "plum";
              rev = "experimental";
              sha256 = "sha256-jYEeCycEQCBpdF8VU6r/tTYITNMzRXaHNgyEctndaIs=";
            };
          }) */
          (pkgs.vimUtils.buildVimPlugin {
            name = "LariojDiffGoFile";
            src = pkgs.fetchFromGitHub {
              owner = "larioj";
              repo = "DiffGoFile";
              rev = "master";
              sha256 = "sha256-8ZNo4Afo0w47onzYSkpVgE7rN08Oe1jJYPUELNuIqsE=";

            };
          })
        ];
      };
    };
  };
}
