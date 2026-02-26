# Pricetag

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/StikyPiston/pricetag)

**Pricetag** is a CLI-based file tagging tool written in Go!

## Usage

These are a small subset of `pricetag`'s ability, see the `--help` flag for more!

### Create a tag

```shell
pricetag tag new <name> <color>
```

### Add tags to files

```shell
pricetag tag add <file> --tags <tags>
```

### List files with tags

```shell
pricetag files withtag <tags>
```

## Installation

### with Nix

To install, add the repo to your inputs

```nix
inputs = {
  pricetag.url = "github:stikypiston/pricetag"
}
```

And add it to your systemPackages

```nix
environment.systemPackages = [
  inputs.pricetag.packages.${pkgs.stdenv.hostPlatform.system}.pricetag
]
```
