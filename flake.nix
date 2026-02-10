{
  description = "Lume (trycua) - macOS VM CLI built from source";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" ];
      mkPkgs = system: import nixpkgs { inherit system; };

      # Lume version and source info
      version = "0.2.76";
      srcRev = "35eb0252aa4b9dc9f880b6574cc2b6463b073de3"; # lume-v0.2.76

      # Swift package dependencies from Package.resolved
      # These are pre-fetched for reproducibility
      swiftDeps = {
        dynamic = {
          url = "https://github.com/mhdhejazi/Dynamic";
          rev = "772883073d044bc754d401cabb6574624eb3778f";
          hash = "sha256-CYmYCRP89nfiwPKb06IrAlzNHmKqmry/uIOwKrXFXrg=";
        };
        eventsource = {
          url = "https://github.com/mattt/eventsource.git";
          rev = "ca2a9d90cbe49e09b92f4b6ebd922c03ebea51d0";
          hash = "sha256-C2yzDTTTtcHdRvjuc1wkI3pMJNvfNipWYSvyI9ygyEU=";
        };
        swift-argument-parser = {
          url = "https://github.com/apple/swift-argument-parser";
          rev = "41982a3656a71c768319979febd796c6fd111d5c";
          hash = "sha256-TRaJG8ikzuQQjH3ERfuYNKPty3qI3ziC/9v96pvlvRs=";
        };
        swift-asn1 = {
          url = "https://github.com/apple/swift-asn1.git";
          rev = "810496cf121e525d660cd0ea89a758740476b85f";
          hash = "sha256-K9w13dGuw05eNIznbuWB+De067ZotX3yALc5Fit7geQ=";
        };
        swift-atomics = {
          url = "https://github.com/apple/swift-atomics.git";
          rev = "cd142fd2f64be2100422d658e7411e39489da985";
          hash = "sha256-Ho3/BDUwAVGG26u8Jz2j1mwqFRcLc+DTlqTyGelM+Gc=";
        };
        swift-cmark = {
          url = "https://github.com/apple/swift-cmark.git";
          rev = "3ccff77b2dc5b96b77db3da0d68d28068593fa53";
          hash = "sha256-b/igbZbHFXK/SqS84UGWsUoVjChNFBb0t0w4HoPTguE=";
        };
        swift-collections = {
          url = "https://github.com/apple/swift-collections.git";
          rev = "7b847a3b7008b2dc2f47ca3110d8c782fb2e5c7e";
          hash = "sha256-Bhfmf02JbmEdM1TFdM8UGxlouR8kr61WlU1uI2v67v8=";
        };
        swift-crypto = {
          url = "https://github.com/apple/swift-crypto.git";
          rev = "95ba0316a9b733e92bb6b071255ff46263bbe7dc";
          hash = "sha256-RzoUBx4l12v0ZamSIAEpHHCRQXxJkXJCwVBEj7Qwg9I=";
        };
        swift-format = {
          url = "https://github.com/apple/swift-format.git";
          rev = "3191b8f3109730af449c6332d0b1ca6653b857a0";
          hash = "sha256-oYf9Qt0b/6G3+uQaoExQRKzgpi1RPYSSpZLfwhuRmF8=";
        };
        swift-log = {
          url = "https://github.com/apple/swift-log.git";
          rev = "7ee16e465622412764b0ff0c1301801dc71b8f61";
          hash = "sha256-ziPNhg9dUkzPArKss6GMgE1xT5w3Ckp8W+G8H7BYUbI=";
        };
        swift-markdown = {
          url = "https://github.com/apple/swift-markdown.git";
          rev = "8f79cb175981458a0a27e76cb42fee8e17b1a993";
          hash = "sha256-DAr7DuNG3zDI4jDR1esKcGGdxuMJx38wTrxk3gm83D0=";
        };
        swift-nio = {
          url = "https://github.com/apple/swift-nio.git";
          rev = "233f61bc2cfbb22d0edeb2594da27a20d2ce514e";
          hash = "sha256-/YAIMX+S4u9KB5O5UAp6O2cC3D/2lsfg3QQnJM8AdQo=";
        };
        swift-nio-ssh = {
          url = "https://github.com/apple/swift-nio-ssh.git";
          rev = "8f33cac67309a13aecc0a4d95044543549b20ffb";
          hash = "sha256-TFt6a9/6XNZxnAdfzrnV3BKc0HYGcGOdiQt83TnC8ZM=";
        };
        swift-sdk = {
          url = "https://github.com/modelcontextprotocol/swift-sdk.git";
          rev = "c0407a0b52677cb395d824cac2879b963075ba8c";
          hash = "sha256-Ahpgr5I4QUFIoBX7Sz9geP+nGmj+rLx0ktmqfdwwqz4=";
        };
        swift-syntax = {
          url = "https://github.com/apple/swift-syntax.git";
          rev = "cdd571f366a4298bb863a9dcfe1295bb595041d5";
          hash = "sha256-8XV2dlB3Vio5O+wFnS5EQeHyPCIgFyCjEYFGCWzOPwE=";
        };
        swift-system = {
          url = "https://github.com/apple/swift-system.git";
          rev = "7c6ad0fc39d0763e0b699210e4124afd5041c5df";
          hash = "sha256-bfxm2WS+4qcgSzheWTvRloDAIIIHzPZ8SaAZq9bWmSc=";
        };
        yams = {
          url = "https://github.com/jpsim/Yams.git";
          rev = "3d6871d5b4a5cd519adf233fbb576e0a2af71c17";
          hash = "sha256-5uxD2eAJpMVHMStfWUzHcgjlp0d/EYcr1l+Qq2xlMxU=";
        };
      };
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = mkPkgs system;

          # Fetch the main source from cua monorepo
          lumeSrc = pkgs.fetchgit {
            url = "https://github.com/trycua/cua.git";
            rev = srcRev;
            hash = "sha256-TH3SXETgBu+zgJsB0jr8ykAWV5SDyCkje89I+jTyvFI=";
            fetchSubmodules = false;
          };

          # Note: swiftDeps above documents the required dependencies with pinned hashes.
          # Currently unused since the build uses system Xcode with network access.
          # These will be needed when Swift 6 lands in nixpkgs for a pure build.
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "lume";
            inherit version;

            src = "${lumeSrc}/libs/lume";

            # We need Xcode's Swift 6 toolchain (not available in nixpkgs yet)
            # This derivation uses the system Swift via xcrun
            # We intentionally don't use nixpkgs SDK to avoid version mismatches
            nativeBuildInputs = [ ];
            buildInputs = [ ];

            # Required for accessing system Xcode (impure build)
            __noChroot = true;

            buildPhase = ''
              runHook preBuild

              # Build using system Swift (requires Xcode with Swift 6+)
              # Clear Nix SDK variables to avoid conflicts with system SDK
              unset NIX_CFLAGS_COMPILE
              unset NIX_LDFLAGS
              unset NIX_CC
              unset NIX_CXX

              export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
              export SDKROOT=$(/usr/bin/xcrun --sdk macosx --show-sdk-path)
              export DEVELOPER_DIR=$(/usr/bin/xcode-select -p)
              export TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault

              # Create writable cache directory for SwiftPM
              export HOME=$TMPDIR

              # Build in release mode
              /usr/bin/xcrun swift build \
                --configuration release \
                --disable-sandbox \
                --skip-update \
                -Xswiftc -suppress-warnings

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin $out/share/lume

              # Install the binary
              install -m755 .build/release/lume $out/bin/lume

              # Install resources if present
              if [ -d src/Resources ]; then
                cp -R src/Resources $out/share/lume/
              fi

              runHook postInstall
            '';

            # Skip fixup phases that don't apply to Swift binaries
            dontStrip = true;
            dontPatchShebangs = true;
            dontPatchELF = true;
            dontFixup = true;

            meta = with pkgs.lib; {
              description = "Lume: macOS/Linux VM CLI using Apple Virtualization Framework";
              longDescription = ''
                Lume is a hardware-accelerated VM runtime for macOS and Linux VMs
                on Apple Silicon. It provides a CLI and HTTP API for creating,
                managing, and running virtual machines.

                Note: This package requires Xcode with Swift 6+ installed on the
                host system, as nixpkgs does not yet include Swift 6. Once Swift 6
                is available in nixpkgs, this package can be made fully pure.
              '';
              homepage = "https://github.com/trycua/cua";
              license = licenses.mit;
              platforms = [ "aarch64-darwin" ];
              mainProgram = "lume";
              # Mark as broken until we verify Swift 6 requirement is met
              # broken = true; # Uncomment if you want to prevent accidental builds
            };
          };

          # Binary-based package (fallback, for when source build isn't possible)
          binary = pkgs.stdenvNoCC.mkDerivation {
            pname = "lume-bin";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://github.com/trycua/cua/releases/download/lume-v${version}/lume.tar.gz";
              sha256 = "sha256-4OdvaSF7TimwZIMG54Ev/F9G2iCCdNkxymHqqkKvjsM=";
            };

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin $out/share

              tar -xzf $src -C ./
              install -m755 lume $out/bin/lume

              if [ -d ./lume_lume.bundle ]; then
                mkdir -p $out/share/lume
                cp -R ./lume_lume.bundle $out/share/lume/
              fi

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Lume: macOS VM CLI (pre-built binary)";
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
          meta.description = "Run the Lume CLI (source build)";
        };
        binary = {
          type = "app";
          program = "${self.packages.${system}.binary}/bin/lume";
          meta.description = "Run the Lume CLI (binary)";
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
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              description = "The Lume package to use";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 7777;
              description = "Port for the Lume HTTP API";
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
