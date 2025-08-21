# EmporiumRP Pure Anti-Cheat Module

A spawnless, lore-integrated anti-cheat system for EmporiumRP. Designed to detect and neutralize exploit vectors without compromising RP immersion or contributor safety. Built for resilience, modularity, and ethical governance.

---

## Installation

Place the script in: lua/autorun/server/

This ensures early execution during server startup, initializing diagnostics and fallback logging before any gameplay logic or client interaction.

---

## Detection Coverage

This module actively monitors and mitigates:

- Function tampering (`RunString`, `CompileString`, `debug.getinfo`)
- Hook hijacking and ghosting
- Net spoofing and malformed payloads
- Movement manipulation (silent aim, speed hacks, noclip abuse)
- ESP and entity visibility exploits
- Toolgun abuse and spawn bypasses
- File system tampering and global pollution
- Obfuscated cheat signatures and bytecode anomalies

---

## Architecture Highlights

- Spawnless: No entities, timers, or hooks unless explicitly validated
- Resilient: Startup diagnostics, fallback logging, metatable locking
- Modular: Easily extendable with new detection vectors or lore verdicts
- Secure: TTL enforcement, integrity chaining, audit scaffolds

---

## Lore Integration

Detection events can be routed through Tribunal verdicts or immersive feedback systems. This allows admins to enforce justice in-character, preserving RP immersion while maintaining server integrity.

---

## Contributor Notes

- Fully documented for onboarding and extension
- Licensing headers included (MIT or RP safe custom license)
- No external dependencies or Workshop assets required
- Compatible with EmporiumRP’s spawnless governance suite
- Designed for ethical deployment and contributor safety

---

## License

This module is released under the MIT License. See `LICENSE.md` for details. For RP-safe licensing adaptations, refer to the EmporiumRP contributor guide.

---

## Future Enhancements

- Bytecode fingerprinting and anomaly scoring
- Lore based admin dashboards with real time verdict routing
- Contributor-friendly config scaffolds and onboarding templates

---

Built for EmporiumRP. Powered by ethics, lore, and zero tolerance for exploiters.
