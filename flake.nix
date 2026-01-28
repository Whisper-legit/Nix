{
  description = "NixOS Flake Configuration - Minimal Desktop with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./hardware-configuration.nix

        ({ pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
          };

          networking.hostName = "nixos";
          networking.networkmanager.enable = true;
          networking.firewall.enable = true;

          i18n.defaultLocale = "en_US.UTF-8";
	  i18n.consoleKeyMap = "br-abnt2";
          i18n.extraLocaleSettings = {
            LC_TIME = "pt_BR.UTF-8";
            LC_MONETARY = "pt_BR.UTF-8";
          };

          time.timeZone = "UTC";
	  services.xserver.xkb = {
	  	layout = "br";
	  	variant = "abnt2";

	        };

          security.sudo.enable = true;

          users.users.whisper = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "audio" "vboxsf" ];
            shell = pkgs.zsh;
            hashedPassword = "$6$lIu3x2zxsbRh8uXC$tCs.auPpaCnl6jNbql3AZFjx8hqGVKolLLTMo/y4eBCcJ2bZW37RggQ7NQdIKDxHVc5Hq63ZjsYR2hwU0UzGj/";
          };

          programs.zsh.enable = true;
          programs.hyprland.enable = true;

          services.xserver.videoDrivers = [ "amdgpu" ];
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };

          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          environment.sessionVariables = {
            NIXOS_OZONE_WL = "1";
          };

          environment.systemPackages = with pkgs; [
            coreutils
            util-linux
            gnugrep
            gnused
            gawk
            gcc
            gnumake
            pkg-config
            git
            neovim
            pamixer
            wl-clipboard
            grim
            slurp
            alacritty
	        wofi
	        waybar
	        hyprpaper
          ];

          system.stateVersion = "24.11";
        })
      ];
    };
  };
}
