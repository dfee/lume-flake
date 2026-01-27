{
  description = "Lume (trycua) packaged for Nix + optional nix-darwin LaunchAgent";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" ];
      mkPkgs = system: import nixpkgs { inherit system; };
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = mkPkgs system;
          version = "0.2.52"; # pin to a lume release version
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "lume";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://github.com/trycua/cua/releases/download/lume-v${version}/lume.tar.gz";
              sha256 = "sha256-wfFAAiHpa+XFixgIjbTYqdpGxOJHG7bbB4VYYO9ILXk=";
            };

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin $out/share

              tar -xzf $src -C ./
              install -m755 lume $out/bin/lume

              # Optional resource bundle
              if [ -d ./lume_lume.bundle ]; then
                mkdir -p $out/share/lume
                cp -R ./lume_lume.bundle $out/share/lume/
              fi

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Lume: macOS VM CLI and server (trycua)";
              homepage = "https://cua.ai/docs/lume/";
              license = licenses.mit;
              platforms = [ "aarch64-darwin" ];
              mainProgram = "lume";
            };
          };
        }
      );

      # Handy for `nix run`
      apps = eachSystem (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/lume";
        };
      });

      # Dev shell with lume available
      devShells = eachSystem (system: {
        default = (mkPkgs system).mkShell {
          packages = [ self.packages.${system}.default ];
        };
      });

      # nix-darwin module for the LaunchAgent
      darwinModules.lume =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.lume;
        in
        {
          options.services.lume = {
            enable = lib.mkEnableOption "Lume daemon (launchd agent running `lume serve`)";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.system}.default;
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 7777;
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];

            launchd.user.agents.lume-daemon = {
              serviceConfig = {
                Label = "com.trycua.lume_daemon";
                ProgramArguments = [
                  "${cfg.package}/bin/lume"
                  "serve"
                  "--port"
                  (toString cfg.port)
                ];
                RunAtLoad = true;
                KeepAlive = true;
                StandardOutPath = "/tmp/lume_daemon.log";
                StandardErrorPath = "/tmp/lume_daemon.error.log";
              };
            };
          };
        };
    };
}
