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

            # The installer pulls: https://github.com/trycua/cua/releases/download/<tag>/lume.tar.gz   [oai_citation:3‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
            src = pkgs.fetchurl {
              # Tags look like lume-vX.Y.Z (script matches "lume-...")  [oai_citation:4‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
              url = "https://github.com/trycua/cua/releases/download/lume-v${version}/lume.tar.gz";
              sha256 = "sha256-wfFAAiHpa+XFixgIjbTYqdpGxOJHG7bbB4VYYO9ILXk=";
            };

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin $out/share

              tar -xzf $src -C ./
              install -m755 lume $out/bin/lume

              # Optional resource bundle (the script installs it if present)  [oai_citation:5‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
              if [ -d ./lume_lume.bundle ]; then
                mkdir -p $out/share/lume
                cp -R ./lume_lume.bundle $out/share/lume/
              fi

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Lume: macOS VM CLI and server (trycua)";
              homepage = "https://cua.ai/docs/lume/";
              license = licenses.mit; # verify if they state otherwise; script itself doesn't declare it
              platforms = [ "aarch64-darwin" ]; # script hard-rejects non-darwin and non-arm64  [oai_citation:6‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
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

      # nix-darwin module to recreate the LaunchAgent part of the installer  [oai_citation:7‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
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
              default = 7777; # installer default  [oai_citation:8‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];

            # Mirrors the intent of their LaunchAgent: RunAtLoad + KeepAlive + logs  [oai_citation:9‡GitHub](https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)
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
