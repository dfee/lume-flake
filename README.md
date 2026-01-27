# lume-flake

> ⚠️ **Experimental / Transitional Packaging**
>
> This flake is an unofficial, experimental packaging of Lume for Nix-based
> macOS systems.
>
> It exists to fill a gap until Lume is packaged and maintained in the
> official `nixpkgs` repository (ideally as a source-based derivation).
>
> Expect possible breaking changes, limited guarantees around long-term
> maintenance, and eventual deprecation in favor of an upstream-supported
> nixpkgs package.
>
> If and when an official nixpkgs implementation becomes available, users
> should prefer that over this flake.

A Nix flake packaging **Lume**, the macOS VM CLI from trycua, with an optional
nix-darwin LaunchAgent module.

This flake exists to replace the upstream imperative install script with a
declarative, reproducible Nix-based workflow.

- No installer scripts
- No mutable state during install
- No auto-updaters
- Optional background service, expressed declaratively

---

## What this provides

### 1. A Nix package

- Installs the `lume` CLI from official GitHub releases
- Darwin-only (`aarch64-darwin`, Apple Silicon)
- No side effects

### 2. A nix-darwin module (optional)

- Recreates the upstream `lume serve` LaunchAgent
- Declarative, idempotent, and removable
- Disabled by default

---

## Requirements

- macOS on Apple Silicon (M1/M2/M3/M4)
- Nix with flakes enabled
- Optional: nix-darwin (for the LaunchAgent)

---

## Usage

### Run without installing

```bash
nix run github:dfee/lume-flake -- --help
```

### Install into your profile

```bash
nix profile install github:dfee/lume-flake
```

### Use in a dev shell

```bash
nix develop github:dfee/lume-flake
lume --version
```

### Using as a flake input (local development)

```nix
inputs = {
  lume.url = "path:../lume-flake";
};
```

Relative paths are supported and recommended for local iteration.


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
  };
}
```

Apply with:

```
darwin-rebuild switch --flake .#your-hostname
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

Packaging is currently binary-based (official release artifacts).
A future nixpkgs submission would likely require a source build.

---

## Platform support

| Platform | Supported |
| -------- | --------- |
| aarch64-darwin | ✅ |
| x86_64-darwin | ❌ |
| Linux | ❌ |

Upstream Lume relies on macOS Virtualization.framework and Apple Silicon.

---

## License

This flake is MIT-licensed.
Lume itself is distributed under its upstream license.

---

## Status

This is a pragmatic packaging layer, not an official upstream artifact.
It exists to make Lume usable in Nix-based macOS systems without violating
Nix’s model of purity and reproducibility.
