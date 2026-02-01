{
  description = "NixOS Flake Configuration - Minimal Desktop with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    swww.url = "github:LGFae/swww";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./hardware-configuration.nix

        ({ pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs.config.allowUnfree = true;

          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = false;
            gfxmodeEfi = "1920x1080";
            gfxpayloadEfi= "keep";
            font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";
            fontSize = 28;
          };

          services.fstrim.enable = true;

          zramSwap.enable = true;
          zramSwap.memoryPercent = 25;

          boot.kernelParams = [
            "snd_hda_intel.enable_msi=0"
            "usbcore.autosuspend=-1"
            "amdgpu.audio=1"
          ];

          boot.kernel.sysctl = {
              "vm.swappiness" = 60;
              "vm.dirty_ratio" = 20;
              "vm.dirty_background_ratio" = 10;
              "kernel.sched_autogroup_enabled" = 1;
          };

          networking.hostName = "nixos";
          networking.networkmanager.enable = true;
          networking.firewall.enable = true;

          i18n.defaultLocale = "en_US.UTF-8";
          console.keyMap = "br-abnt2";
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
          security.rtkit.enable = true;

          users.mutableUsers = false;

          users.users.whisper = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "audio" "vboxsf" ];
            shell = pkgs.zsh;
            hashedPasswordFile = "/etc/nixos/secrets/whisper.passwd";
          };

          services.getty.autologinUser = "whisper";

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

            # Configuração de Clock Estrita
            extraConfig.pipewire."92-low-latency" = {
              "context.properties" = {
                "default.clock.rate" = 48000;
                "default.clock.allowed-rates" = [ 48000 ]; # Impede a troca de taxa de amostragem
                "default.clock.quantum" = 1024;
                "default.clock.min-quantum" = 1024;
                "default.clock.max-quantum" = 2048;
              };
            };
          };

          environment.etc."wireplumber/main.lua.d/51-microphone.lua".text = ''
            alsa.monitor.rules = {
              {
                matches = {
                  {
                    { "node.name", "matches", "alsa_input.usb-Kingston_HyperX_Cloud_Revolver_000000000001" }
                  }
                },
                apply_properties = {
                  ["audio.rate"] = 48000,
                  ["audio.allowed-rates"] = "48000",
                  ["audio.channels"] = 1,
                  ["node.latency"] = "2048/48000",
                  ["api.alsa.period-size"] = 1024,
                  ["api.alsa.period-num"] = 4,
                  ["resample.disable"] = true
                }
              }
            }
          '';

          environment.sessionVariables = {
            NIXOS_OZONE_WL = "1";
          };

          environment.systemPackages = with pkgs; [
            coreutils
            pulseaudio
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
            kdePackages.gwenview
            wofi
            waybar
            hyprpaper
            firefox
            swww
            whatsapp-electron
            discord
            obs-studio
            vlc
            libreoffice-qt-fresh
            mesa
            kitty
            ranger
            file
            ffmpegthumbnailer
            imagemagick
            mediainfo
            poppler
            atool
            bat
            p7zip

          ];

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
            corefonts
            texlivePackages.tex-gyre
          ];

          system.stateVersion = "24.11";
        })
      ];
    };
  };
}
