# Changelog

All notable changes to simple_persist will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-20

### Added
- Initial release
- `SIMPLE_PERSIST` facade class for common operations
- `SP_WRITER` for binary serialization
- `SP_READER` for binary deserialization
- `SP_CHAIN` abstract base class for object chains
- `SP_ARRAYED_CHAIN` array-backed chain implementation
- `SP_STORABLE` base class for persistable objects
- `SP_QUERY` fluent query builder with where/take/skip/order_by
- `SP_INDEX` abstract base class for indexes
- `SP_HASH_INDEX` hash-based index implementation
- Soft delete support with `is_deleted` flag
- File persistence with save/load operations
- Design by Contract with full preconditions and postconditions
- SCOOP-compatible design
- 11 unit tests with 100% pass rate

### Hardening (Workflow 07)
- Added precondition to `SP_WRITER.put_string` for void safety
- Added postcondition to `SP_QUERY.results` guaranteeing non-void result
- Added precondition to `SP_WRITER.to_file` for file state validation
- Added defensive check in `SP_READER.read_string` for negative lengths
- Added 3 adversarial tests for edge cases

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-01-20 | Initial release with hardening |
