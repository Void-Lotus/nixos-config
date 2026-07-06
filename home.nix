# User Home Manager Configuration
{ config, pkgs, ... }:

{
  home.username = "voidlotus";
  home.homeDirectory = "/home/voidlotus";
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    fastfetch
    btop
    acpi
    lsd
    cava
    ghostty
    kitty
    rofi
    wallust
    grim
    slurp
    swappy
    pamixer
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    spicetify-cli
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    joplin
    google-chrome
    gh
  ];

  # XDG Config File Mappings
  xdg.configFile = {
    "alacritty/alacritty.toml".source = ./configs/alacritty/alacritty.toml;
    "btop" = { source = ./configs/btop; recursive = true; };
    "cava" = { source = ./configs/cava; recursive = true; };
    "fastfetch".source = ./configs/fastfetch;
    "ghostty" = { source = ./configs/ghostty; recursive = true; };
    "kitty" = { source = ./configs/kitty; recursive = true; };
    "niri/config.kdl".source = ./configs/niri/config.kdl;
    "niri/cfg" = { source = ./configs/niri/cfg; recursive = true; };
    "noctalia" = { source = ./configs/noctalia; recursive = true; };
    "qt5ct" = { source = ./configs/qt5ct; recursive = true; };
    "qt6ct" = { source = ./configs/qt6ct; recursive = true; };
    "rofi" = { source = ./configs/rofi; recursive = true; };
    "spicetify" = { source = ./configs/spicetify; recursive = true; };
    "wallust" = { source = ./configs/wallust; recursive = true; };
  };

  # Custom Oh-My-Zsh Theme mapping
  home.file.".oh-my-zsh/custom/themes/agnosterzak.zsh-theme".source = ./configs/zsh-themes/agnosterzak.zsh-theme;

  # Configure GTK and Icon Themes
  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Blue-Dark";
    };
    iconTheme = {
      package = pkgs.flat-remix-icon-theme;
      name = "Flat-Remix-Blue-Dark";
    };
  };

  # Configure Cursor Theme
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Shell configurations to ensure agy path is exported and Oh-My-Zsh is set up
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "lsd";
      l = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      lt = "ls --tree";
      rs = "sudo nixos-rebuild switch --flake /home/voidlotus/nixos-config#nixlotus";
    };

    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      theme = "agnosterzak";
    };

    initContent = ''
      # Antigravity CLI PATH
      export PATH="$HOME/.local/bin:$PATH"

      # Fastfetch config
      if [ -f "$HOME/.config/fastfetch/config-compact.jsonc" ]; then
        fastfetch -c "$HOME/.config/fastfetch/config-compact.jsonc"
      fi
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # Antigravity CLI PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
