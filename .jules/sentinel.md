# Sentinel Journal

## 2025-05-15 - Hardcoded CBC Cipher and Weak Password Generation
**Vulnerability:** The container entrypoint script explicitly configured a CBC-mode cipher (`DHE-RSA-AES256-SHA`) and generated default passwords using only digits (`0-9`).
**Learning:** Hardcoding specific cipher suites in scripts can lead to outdated security practices persisting even when the underlying software supports better options. Also, password generation scripts should maximize entropy within usability constraints.
**Prevention:** Use stronger defaults (GCM) and ensure random generation uses a larger character set (`A-Za-z0-9`).
