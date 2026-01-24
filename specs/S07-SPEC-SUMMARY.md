# S07-SPEC-SUMMARY: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Executive Summary

simple_persist provides SCOOP-safe object persistence with binary serialization, in-memory chains, fluent queries, and hash indexing for Eiffel applications.

## Key Specifications

### Architecture
- **Pattern**: Template Method (SP_STORABLE) + Builder (SP_QUERY)
- **Facade**: SIMPLE_PERSIST
- **Serialization**: SP_WRITER/SP_READER pair
- **Storage**: SP_ARRAYED_CHAIN

### API Design
- **Template Interface**: SP_STORABLE defines serialization contract
- **Fluent Queries**: where/and_where/or_where/take/skip
- **Index Pattern**: Key function + manual maintenance

### Features
1. Binary serialization of all primitive types
2. String serialization (length-prefixed UTF-32)
3. In-memory chains with file persistence
4. Fluent query builder
5. Hash-based indexing
6. Soft delete support
7. Storage versioning

### Dependencies
- EiffelBase only (pure Eiffel)

### Platform Support
- Windows, Linux, macOS
- SCOOP compatible
- Void safe

## Contract Highlights

- Writer capacity must be positive
- Storable objects must implement interface
- Files are validated for existence before read
- Query predicates must be valid functions

## Performance Targets

| Operation | Target |
|-----------|--------|
| Write 1 item | <0.1ms |
| Read 1 item | <0.1ms |
| Hash lookup | <0.01ms |
| Query 1000 items | <5ms |
