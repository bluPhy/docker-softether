## 2025-01-09 - Hardcoded Cipher Suite
**Vulnerability:** The `entrypoint.sh` script hardcoded `DHE-RSA-AES256-SHA` as the only allowed cipher suite using `ServerCipherSet`.
**Learning:** This restriction prevents users from utilizing modern, stronger ciphers like `AES256-GCM-SHA384` (TLS 1.2) unless they modify the entrypoint script. Hardcoding security configurations limits adaptability and improvements.
**Prevention:** Always expose security parameters (like cipher suites, protocols, key lengths) as configuration variables (env vars) with secure defaults.
