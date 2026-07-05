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
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
