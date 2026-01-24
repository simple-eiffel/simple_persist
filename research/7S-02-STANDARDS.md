# 7S-02-STANDARDS: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Applicable Standards

### Eiffel Standards
- **ECMA-367** - Eiffel language specification
- **Void Safety** - Full void-safe implementation
- **SCOOP** - Concurrency-ready design

### Serialization Conventions
- **Little-endian** - Binary byte order
- **Length-prefixed strings** - 4-byte length + content
- **Version headers** - Storage version for migration

## Data Type Representations

| Eiffel Type | Binary Size | Format |
|-------------|-------------|--------|
| INTEGER_8 | 1 byte | Signed |
| INTEGER_16 | 2 bytes | Signed, LE |
| INTEGER_32 | 4 bytes | Signed, LE |
| INTEGER_64 | 8 bytes | Signed, LE |
| NATURAL_8 | 1 byte | Unsigned |
| NATURAL_16 | 2 bytes | Unsigned, LE |
| NATURAL_32 | 4 bytes | Unsigned, LE |
| NATURAL_64 | 8 bytes | Unsigned, LE |
| REAL_32 | 4 bytes | IEEE 754 |
| REAL_64 | 8 bytes | IEEE 754 |
| BOOLEAN | 1 byte | 0/1 |
| STRING | 4 + n bytes | Length + UTF-32 codes |

## Design Patterns

1. **Command Pattern** - Writer/Reader operations
2. **Iterator Pattern** - Chain cursor navigation
3. **Builder Pattern** - Fluent query construction
4. **Template Method** - SP_STORABLE interface
