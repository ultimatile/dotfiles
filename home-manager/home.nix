{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # -- Homebrew からの移行候補 --
    # pkgs.github-copilot-cli
    # pkgs.atuin # old 
    pkgs.cargo-make
    pkgs.choose            # brew: choose-rust
    pkgs.clang-tools        # brew: clang-format
    pkgs.colima
    # pkgs.direnv
    pkgs.docker
    pkgs.dust
    pkgs.doxygen
    pkgs.eza
    # pkgs.fancy-cat # broken
    pkgs.fastfetch
    pkgs.fd
    pkgs.fdupes
    pkgs.fzf
    pkgs.gh
    pkgs.ghq
    pkgs.gibo
    pkgs.gifsicle
    pkgs.delta              # brew: git-delta
    pkgs.glow
    pkgs.gnused             # brew: gnu-sed
    pkgs.gnuplot
    pkgs.go
    pkgs.graphviz
    # pkgs.python313Packages.grip
    pkgs.hugo
    pkgs.hyperfine
    pkgs.imagemagick
    pkgs.jq
    pkgs.lazygit
    pkgs.less
    pkgs.gnumake            # brew: make
    pkgs.meson
    pkgs.mkdocs
    pkgs.neovim
    pkgs.ninja
    pkgs.nushell
    pkgs.pandoc
    pkgs.parallel
    pkgs.pdfgrep
    pkgs.pre-commit
    pkgs.pwgen
    pkgs.pyenv
    pkgs.rbenv
    pkgs.rsync
    pkgs.ruff
    pkgs.rustup
    pkgs.sd
    pkgs.starship
    pkgs.stylua
    # pkgs.terminal-notifier
    pkgs.tlrc
    pkgs.tmux
    pkgs.trash-cli
    pkgs.tree
    pkgs.tree-sitter        # brew: tree-sitter-cli
    pkgs.typos              # brew: typos-cli
    pkgs.typst
    pkgs.uv
    pkgs.vhs
    pkgs.watchexec
    pkgs.wget
    pkgs.yq-go              # brew: yq
    pkgs.zig
    pkgs.zoxide
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ultimatile/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
