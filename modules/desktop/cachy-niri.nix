# CachyOS Niri + Noctalia configuration module
{ config, pkgs, inputs, ... }:

{
  # 1. Compositor & Shell
  programs.niri.enable = true;

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.system}.default;
    recommendedServices.enable = true; # Enables upower, networkmanager, bluetooth, and power profiles
  };

  # 2. System Backbones
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Power profiles daemon
  services.power-profiles-daemon.enable = true;

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # 3. Environment Packages
  environment.systemPackages = with pkgs; [
    # Compositor & Shell
    xwayland-satellite

    # Theming Base
    adw-gtk3
    capitaine-cursors

    # System Backbones
    wl-clipboard

    # Noctalia Dependencies
    cliphist
    wlsunset
    ddcutil
  ];

  # 4. Map the CachyOS default configurations for Niri cleanly
  # home-manager.users.voidlotus = {
  #   xdg.configFile."niri".source = "${inputs.cachyos-niri-noctalia}/etc/skel/.config/niri";
  # };
}
