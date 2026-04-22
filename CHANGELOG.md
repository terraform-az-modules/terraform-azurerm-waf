# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2026-04-22
### :bug: Bug Fixes
- [`18963cd`](https://github.com/terraform-az-modules/terraform-azurerm-waf/commit/18963cd67932b9340475f389613f06c323d31635) - consolidate versions.tf, remove provider_meta, upgrade to azurerm >= 4.0 *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`95368f9`](https://github.com/terraform-az-modules/terraform-azurerm-waf/commit/95368f921da7f6bbce61b418cf16e1aa3889ff97) - replace version placeholder in example versions.tf with >= 4.0 *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*

### :wrench: Chores
- [`cb3c389`](https://github.com/terraform-az-modules/terraform-azurerm-waf/commit/cb3c38954cac4aeb52f9c7b355841090d60a227f) - add provider_meta for API usage tracking *(PR [#11](https://github.com/terraform-az-modules/terraform-azurerm-waf/pull/11) by [@clouddrove-ci](https://github.com/clouddrove-ci))*
- [`5b790b2`](https://github.com/terraform-az-modules/terraform-azurerm-waf/commit/5b790b29fb3740a410990cfc951daca6b4249042) - polish module with basic example, changelog, and version fixes *(PR [#12](https://github.com/terraform-az-modules/terraform-azurerm-waf/pull/12) by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.0.1] - 2026-03-20

### Changes
- Add provider_meta for API usage tracking
- Add terraform tests and pre-commit CI workflow
- Add SECURITY.md, CONTRIBUTING.md, .releaserc.json
- Standardize pre-commit to antonbabenko v1.105.0
- Set provider: none in tf-checks for validate-only CI
- Bump required_version to >= 1.10.0
[v2.0.0]: https://github.com/terraform-az-modules/terraform-azurerm-waf/compare/v1.0.1...v2.0.0
