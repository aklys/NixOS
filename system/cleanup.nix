{ pkgs, config, ... }:

{
  # This is to garbage collect the nix store in relation to older generations
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
  };
  # This is to optimise the nix store, it will slow down the rebuild
  nix.settings.auto-optimise-store = true;
}