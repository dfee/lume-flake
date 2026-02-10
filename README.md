# lume-flake

> **Source Build with Path to nixpkgs**
>
> This flake builds Lume from source using your system's Xcode Swift toolchain.
> It is structured to be convertible to a pure nixpkgs package once Swift 6
> becomes available in nixpkgs.
>
> Current limitations for nixpkgs submission:
> - Requires system Xcode (Swift 6+) — nixpkgs only has Swift 5.10
> - Uses `--impure` flag for build
>
> When Swift 6 lands in nixpkgs, this package can be made fully pure and
> submitted upstream.

A Nix flake packaging **Lume**, the macOS VM CLI from trycua, with an optional
nix-darwin LaunchAgent module.

This flake builds Lume from source code rather than downloading pre-built
binaries, providing better auditability and a clear path to nixpkgs inclusion.

- Builds from source (Swift)
- All 17 Swift dependencies pinned with hashes
- No mutable state during install
- No auto-updaters
- Optional background service, expressed declaratively

---

## What this provides

### 1. Source-built Nix package (default)

- Builds `lume` from the official trycua/cua repository
- Requires Xcode with Swift 6+ on the build machine
- Darwin-only (`aarch64-darwin`, Apple Silicon)
- Must be built with `--impure` flag

### 2. Binary package (fallback)

- Installs from official GitHub release artifacts
- No Xcode required
- Use with `.#binary`

### 3. A nix-darwin module (optional)

- Recreates the upstream `lume serve` LaunchAgent
- Declarative, idempotent, and removable
- Disabled by default

---

## Requirements

- macOS on Apple Silicon (M1/M2/M3/M4)
- Nix with flakes enabled
- **Xcode 15+ with Swift 6+** (for source build)
- Optional: nix-darwin (for the LaunchAgent)

---

## Usage

### Build from source (requires Xcode)

```bash
nix build github:dfee/lume-flake --impure
./result/bin/lume --version
```

### Use pre-built binary (no Xcode needed)

```bash
nix build github:dfee/lume-flake#binary
./result/bin/lume --version
```

### Run without installing

```bash
# Source build
nix run github:dfee/lume-flake --impure -- --help

# Binary
nix run github:dfee/lume-flake#binary -- --help
```

### Install into your profile

```bash
# Source build
nix profile install github:dfee/lume-flake --impure

# Binary
nix profile install github:dfee/lume-flake#binary
```

### Use in a dev shell

```bash
nix develop github:dfee/lume-flake --impure
lume --version
```

### Using as a flake input

Add to your `flake.nix`:

```nix
inputs = {
  lume.url = "github:dfee/lume-flake";
};
```

Your `flake.lock` will pin the exact commit used.

#### Updating to a new version

When lume-flake is updated, pull in the changes with:

```bash
nix flake update lume
```

Then rebuild your system (`darwin-rebuild switch`, etc.).

#### Pinning to a specific commit

If you need a specific version:

```nix
inputs = {
  lume.url = "github:dfee/lume-flake/<commit-sha>";
};
```

#### Local development

For iterating locally:

```nix
inputs = {
  lume.url = "path:../lume-flake";
};
```

### nix-darwin integration (optional)

```nix
{
  imports = [
    inputs.lume.darwinModules.lume
  ];

  services.lume = {
    enable = true;
    port = 7777;
    # package = inputs.lume.packages.${pkgs.system}.default; # optional override
    # package = inputs.lume.packages.${pkgs.system}.binary;  # use binary instead
  };
}
```

Apply with:

```
darwin-rebuild switch --flake .#your-hostname --impure
```

Logs (matching upstream behavior):
 * `/tmp/lume_daemon.log`
 * `/tmp/lume_daemon.error.log`


---

## Design notes

This flake does not implement:
- auto-updating
- cron jobs
- background services by default

Those behaviors are intentionally excluded in favor of explicit configuration.

### Source build architecture

The source build:
1. Fetches the cua monorepo at a pinned revision
2. Pre-fetches all 17 Swift package dependencies with pinned hashes
3. Uses system Xcode's Swift toolchain to compile
4. Produces a native ARM64 binary

### Path to nixpkgs

For full nixpkgs eligibility, the package needs:
- [ ] Swift 6 in nixpkgs (currently only 5.10.1)
- [ ] Pure build without system Xcode
- [ ] Proper SwiftPM integration with swiftpm2nix

Once Swift 6 is available in nixpkgs, this package can be converted to a
pure derivation by replacing the system xcrun calls with nixpkgs Swift.

---

## Platform support

| Platform | Supported |
| -------- | --------- |
| aarch64-darwin | Source + Binary |
| x86_64-darwin | Not supported |
| Linux | Not supported |

Upstream Lume relies on macOS Virtualization.framework and Apple Silicon.

---

## License

This flake is MIT-licensed.
Lume itself is distributed under MIT license.

---

## Status

This is a community packaging layer building Lume from source.
It exists to make Lume usable in Nix-based macOS systems with full
source auditability and a clear path to upstream nixpkgs inclusion.
