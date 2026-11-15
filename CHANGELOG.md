# Changelog

All notable changes to the AlgoPanel project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.9] - 2026-11-14

### Added
- Bilingual (English / Persian) documentation in `README.md` with RTL support and Vazirmatn font styling.
- Comprehensive `CHANGELOG.md` file for GitHub repository and web documentation.
- ChangeLog link and dedicated webpage (`changelog.html`) on official website [algopanel.ir](https://algopanel.ir).

### Changed
- Upgraded software license from BSD 3-Clause to **Apache License 2.0**.
- Redesigned standard web server error pages (400, 401, 403, 404, 500, 502, 503) across 20+ languages with modern AlgoPanel UI.
- Improved WordPress Nginx directives snippet for enhanced performance and compatibility with caching plugins.
- Optimized default database and system user prefixes during installation.

### Fixed
- Fixed documentation sidebar responsive display in desktop view (`display: block` for `>= 1024px`).
- Streamlined mobile navigation drawer behavior across all documentation pages.

---

## [1.0.8] - 2026-11-12

### Added
- Smart VirtualHost auto-configuration plugins for Apache2 and Nginx.
- Default AlgoPanel landing and placeholder pages for new virtual hosts.

### Changed
- Enhanced primary IP auto-detection mechanism during initial server configuration.

---

## [1.0.7] - 2026-11-11

### Added
- Anti-sanction domestic mirror resolution based on server IP geolocation.
- Full installation CLI parameters and switches guide on documentation site.
- Comprehensive 9-pillar Features page (`features.html`).

### Fixed
- Confirmed full compatibility and service reliability on Ubuntu 24.04 LTS (Noble Numbat).

---

## [1.0.6] - 2026-11-09

### Fixed
- Removed redundant secondary ASCII banner during CLI terminal installation.
- Unified dark and light mode font rendering across custom themes.

---

## [1.0.5] - 2026-11-08

### Fixed
- Used secure `mktemp` temporary files for Whiptail dialog inputs to prevent standard I/O collision.

---

## [1.0.4] - 2026-11-08

### Changed
- Separated web panel port and FQDN hostname inputs into two distinct interactive dialogs.

---

## [1.0.0] - 2026-11-08

### Added
- Initial stable release of AlgoPanel.
- Forked ISPConfig stable base and implemented smart installer engine `algopanel-ai`.
- Modern, clean, responsive UI theme with dark/light mode toggle.
- Automated package builder and distribution deployment to `get.algopanel.ir`.
