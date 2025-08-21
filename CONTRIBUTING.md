# Contributing to Emporium Anti Cheat

Thank you for your interest in contributing to EmporiumRP’s anti cheat module. This system is designed to be spawnless, modular, and lore-conscious. All contributions must respect RP immersion, contributor safety, and ethical governance.

## Code Style Guidelines

- **Spawnless architecture** only: no entities, timers, or hooks unless explicitly validated.
- **Modular logic**: each detection vector should be isolated and extensible.
- **Defensive coding**: use fallback logging, startup diagnostics, and metatable locking.
- **Lore integration**: detection events should route through Tribunal verdicts or immersive feedback systems when applicable.

## Detection Vectors

If proposing a new detection vector, include:

- A brief description of the exploit
- The logic used to detect it
- Any edge cases or false positives
- Optional lore phrasing for Tribunal verdicts

## Licensing

All contributions must comply with the MIT License or RP safe licensing standards. Include a licensing header in any new file.

## Contributor Safety

Do not include obfuscated code, external dependencies, or logic that could compromise contributor workflows. All modules must be transparent, documented, and safe to extend.

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`feature/new-detection-vector`)
3. Commit with clear messages
4. Submit a pull request with a summary of changes and rationale

## Legacy Preservation

This project is part of Emporium’s long term governance suite. All contributions should be future-proof, documented, and respectful of contributor legacy.

