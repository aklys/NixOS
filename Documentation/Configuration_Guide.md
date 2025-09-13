# NixOS Configuration Development Guide

## Overview

This guide establishes a structured approach to developing NixOS configurations that provides declarative system reproduction while maintaining modularity and LLM-friendly extensibility. The system uses traditional NixOS (no flakes) with clear organizational patterns for consistent, maintainable configurations.

## Core Architecture

### Entry Point Hierarchy
```
configuration.nix (SINGLE ENTRY POINT)
├── system/*.nix (system-wide configurations)
├── applications/NIX__*.nix (system-called application configs)
└── home__bluser.nix (user configuration)
    └── applications/HM__*.nix (user-called application configs)
```

**Flow:** `configuration.nix` is the single system entry point that imports all system modules and calls `home__bluser.nix` for user configuration via home-manager integration.

### Directory Structure
```
nixos-config/
├── configuration.nix           # System entry point - imports everything
├── hardware-configuration.nix  # Auto-generated hardware config
├── home__bluser.nix            # User config entry point (called by configuration.nix)
├── system/                     # System-wide configurations
│   ├── boot.nix               # Boot loader, kernel modules
│   ├── nfs.nix                # Network filesystem mounts
│   └── cleanup.nix            # Garbage collection, optimization
└── applications/              # All application configurations
    ├── HM__sway.nix           # User window manager config
    ├── HM__firefox.nix        # User browser config
    ├── NIX__greetd.nix        # System login manager config
    └── NIX__thunar.nix        # System file manager config
```

## Decision Framework

### 1. Where Does Configuration Go?

**System Folder (`system/`):**
- System-wide effects that apply to all users
- Core OS functionality (boot, networking, drivers, services)
- Hardware configuration
- Infrastructure that applications require to function

**Applications Folder (`applications/`):**
- User-specific applications and their configurations
- Application-specific settings and policies
- Both system-level and user-level application configs

**Decision Rule:** Ask "Does this affect the system as a whole or is it application-specific?" System-wide infrastructure goes in `system/`, everything else goes in `applications/`.

### 2. Naming Conventions

**System Folder:**
- `filename.nix` (no prefix - always called by configuration.nix)
- Examples: `boot.nix`, `nfs.nix`, `cleanup.nix`

**Applications Folder:**
- `HM__application-name.nix` - called by home-manager (user config)
- `NIX__application-name.nix` - called by configuration.nix (system config)
- Prefix indicates the **caller**, not the content

**File Naming Pattern:**
- Use `__` (double underscore) to separate categories
- Use `-` (hyphen) for spaces in names
- Format: `[PREFIX__]application-name[__subcategory].nix`

### 3. File Granularity

**One Application = One File:**
- Each application gets its own configuration file
- Promotes modularity and easier maintenance
- Makes configs easier to locate and modify
- Prevents grouping unless there's a compelling reason

**When to Create vs Edit:**
- **Create new file:** Complex configurations, reusable configs, application-specific settings
- **Edit main files:** Simple one-line additions, basic system settings

## Home Manager Integration

### Setup Pattern
```nix
# In configuration.nix
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
  home-manager.users.bluser = import ./home__bluser.nix;
}
```

### User Configuration Structure
```nix
# home__bluser.nix
{ config, pkgs, ...}:
{
  home.stateVersion = "24.05";
  imports = [
    ./applications/HM__sway.nix
    ./applications/HM__firefox.nix
    # ... other user applications
  ];
  home.packages = with pkgs; [
    # Direct package installations
  ];
}
```

## LLM Integration Benefits

### Modular Development
- **Focused Work:** LLMs work on single application configs in isolation
- **Reduced Context:** No need to understand entire system configuration
- **Clear Integration:** Simple import line addition to integrate new configs
- **Risk Mitigation:** New configs don't affect existing functionality

### Integration Workflow
1. **LLM Task:** Create focused config file following naming convention
2. **Human Integration:** Add single import line to appropriate root file
3. **System Rebuild:** New functionality integrates automatically
4. **Iteration:** Modify individual files without affecting others

### Example Integration
```nix
# LLM creates: applications/HM__new-app.nix
# Human adds to home__username.nix:
imports = [
  ./applications/HM__new-app.nix  # <-- Single line addition
  # ... existing imports
];
```

## Multi-Device Strategy

### Centralized Storage
- Store complete configurations in central location (NAS, USB)
- One folder per device type/purpose
- Copy and modify approach rather than complex conditionals
- Version control individual device configurations

### Device-Specific Variations
- Each device gets its own complete configuration set
- Share common patterns but maintain device independence
- Hardware-specific configs remain in `hardware-configuration.nix`
- Application variations handled through separate config files

## Configuration Standards

### File Structure
- Each `.nix` file should be self-contained
- Use clear, descriptive variable names
- Include comments explaining non-obvious configurations
- Follow consistent formatting and indentation

### Import Patterns
- List imports at the top of files
- Group related imports together
- Use relative paths for local modules
- Maintain alphabetical order when practical

### Error Prevention
- Validate configurations before deployment
- Use `nixos-rebuild dry-run` to test changes
- Maintain backup configurations for critical systems
- Document device-specific requirements

## Examples

### System Configuration
```nix
# system/NIX__nfs.nix (imported by configuration.nix)
{ pkgs, config, ... }:
{
  fileSystems = {
    "/mnt/InProgress" = {
      device = "172.17.13.110:/mnt/HD/HD_a2/DW_InProgress";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto"];
    };
  };
}
```

### Hardware Configuration
```nix
# system/HC__gpu.nix (imported by hardware-configuration.nix)
{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
}
```

### Example with Header Template
```nix
# Purpose: Configure Firefox browser with extensions and security policies
# Dependencies: Display server (X11/Wayland), desktop environment
# Referenced by: home__username.nix
# Last updated: 2024-09-05
# Contributors: bluser

# applications/HM__firefox.nix
{ config, pkgs, inputs, ...}:
{
  programs.firefox = {
    enable = true;
    profiles.bluser = {
      # Complete user profile configuration
    };
    policies = {
      # Application policies and extensions
    };
  };
}
```

### System Application Configuration
```nix
# applications/NIX__greetd.nix
{ config, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      # System-wide login manager configuration
    };
  };
}
```

This framework provides consistent, maintainable, and LLM-friendly NixOS configuration management while avoiding experimental features and maintaining traditional NixOS compatibility.
