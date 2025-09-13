# NixOS Multi-Device Configuration Project - Progress Tracker

## Project Overview
Create a single, modular NixOS configuration that identifies devices via MAC address and applies appropriate configurations. Goal: Clone repo → run scripts → get standardized system.

## Current Working Directory Structure
**Purpose:** Reference material for functionality knowledge when building new config

```
nixos-config/
├── configuration.nix
├── hardware-configuration.nix
├── device-macs.nix
├── home__bluser.nix
├── system/
│   ├── boot.nix
│   ├── cleanup.nix
│   └── nfs.nix
├── application/
│   ├── bash.nix
│   ├── conky.nix
│   ├── exodus.nix
│   ├── firefox.nix
│   ├── greetd.nix
│   ├── greetd.nix.bak
│   ├── greetd.nix.save
│   ├── kitty.nix
│   ├── lightdm.nix
│   ├── nfs.nix
│   ├── obs-studio.nix
│   ├── rofi.nix
│   ├── sddm.nix
│   ├── sway.nix
│   ├── swaylock.nix
│   ├── swaync.nix
│   ├── thunar.nix
│   ├── thunar__home.nix
│   ├── thunar__main.nix
│   ├── virtual.nix
│   ├── vscode.nix
│   └── waybar.nix
└── Preparation/
    ├── Install.sh
    ├── Partition_Preparation.sh
    └── Collect__Device_MACs.sh
```

## Target Working Directory Structure
**Purpose:** Clean design we're building from scratch following the guide

```
nixos-config/
├── Documentation/
│   ├── Configuration_Guide.md
│   └── Progress_Tracker.md
├── configuration.nix
├── hardware-configuration.nix
├── device-macs.nix
├── home__bluser.nix
├── system/
│   └── [system modules as needed]
├── application/
│   └── [NIX__ and HM__ modules as needed]
└── Preparation/
    ├── Install.sh
    ├── Partition_Preparation.sh
    ├── Collect__Device_MACs.sh
    └── [future automation scripts]
```

## High-Level Project Phases

### Phase 1: Baseline System Configuration
**Goal:** Create foundational config that works for all devices using multi-device template
- Build line-by-line starting with minimal working system
- Device detection via MAC addresses
- Essential system components that every device needs
- Test on TestVM to validate baseline functionality
- Features to be determined as we build

### Phase 2: TestVM LLM Development System Configuration  
**Goal:** Add VM-specific system configurations needed for LLM development
- VM-specific hardware optimizations
- System-level requirements for LLM tools
- Performance and resource management for development workloads
- Integration with baseline from Phase 1

### Phase 3: TestVM LLM Development Applications
**Goal:** Configure applications for LLM development workflow
- OpenWebUI (web interface for LLMs)
- Ollama (local LLM runtime)  
- Python development environment
- Jupyter Notebooks (interactive development)
- Additional tools identified as needed during development

### Phase 4: Additional Device Configurations
**Goal:** Build out configurations for remaining 3 devices with defined purposes
- **Main Computer:** Full-capability system (everything possible)
- **Surface 3:** Communication-focused device (+ additional features TBD)
- **Surface Go:** Purpose to be clarified and fleshed out
- At least 2 clear device purposes expected
- Each device builds on baseline from Phase 1

## Strategic Decisions Needed

### Decision Points for Phase 1
- [ ] **Display Manager Choice:** greetd vs lightdm vs sddm (currently have all three)
- [ ] **Essential vs Optional Applications:** What's needed for baseline vs specialized configs?
- [ ] **Device Detection Strategy:** Confirm MAC-based approach for all conditional logic
- [ ] **Migration vs Rebuild:** Clean rebuild vs gradual migration of existing configs
- [ ] **Testing Strategy:** TestVM requirements for validation

### Current Approach Decisions
- ✓ Folder structure: singular names (`system/`, `application/`)  
- ✓ Device detection: MAC address via `configuration.nix` 
- ✓ Conditional activation: `lib.mkIf` within modules
- ✓ File organization: `HM__` prefix for user, `NIX__` prefix for system
- ✓ Documentation location: `Documentation/` folder

## Current Status: Planning Phase

**Current Focus:** Phase 1.1 - Repository Restructure

**Next Immediate Actions:**
1. Create `Documentation/` folder and move guide
2. Decide on essential applications for baseline
3. Start clean rebuild of `configuration.nix`

## Questions for Next Steps
1. **Baseline Desktop Environment:** What's the minimal desktop needed? (Sway + essential apps?)
2. **Display Manager:** Which one should we standardize on?
3. **Application Migration Order:** Should we rebuild applications incrementally or all at once?
4. **TestVM Specification:** What hardware/software requirements for testing?

## Instructions for Next Conversation

**To continue this document, start the next conversation with:**
"Please continue working on the Progress_Tracker.md document for the NixOS multi-device configuration project. We need to expand the sections listed in the 'Instructions for Next Conversation' section, focusing on making Phase 1 detailed and actionable."

**Context:** We are building a comprehensive Progress_Tracker.md document for the NixOS multi-device configuration project. This document tracks the complete project scope and progress across conversations.

**What we've established so far:**
- Two directory structures: Current (for reference) and Target (clean build following guide)
- Four project phases from foundation to production readiness
- Documentation/ folder with Configuration_Guide.md and Progress_Tracker.md
- Strategic decisions needed for Phase 1 planning

**What still needs to be completed in this document:**
1. **Expand Phase 1 breakdown** - Detailed steps for baseline system creation
2. **Define essential vs optional applications** - What goes in baseline vs specialized configs  
3. **TestVM specifications** - Hardware/software requirements for validation
4. **Decision framework** - How to make choices about display managers, applications, etc.
5. **Testing milestones** - Clear checkpoints for each phase
6. **Implementation workflow** - Step-by-step process for building new config files
7. **Reference guide** - How to use current files as functionality knowledge source
8. **Error handling** - What to do when things don't work during rebuild
9. **Rollback procedures** - How to recover if new config fails

**Current status:** Planning Phase - need to flesh out Phase 1 details before starting actual implementation.

**Next conversation should:** Continue expanding this Progress_Tracker.md document with the missing sections above, focusing on making Phase 1 actionable and detailed enough to start implementation.
