# 7S-01-SCOPE: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Problem Statement

Eiffel applications need lightweight object persistence with binary serialization, in-memory collections, and queryable data access without requiring a full database.

## Target Users

1. **Application Developers** - Need simple object storage
2. **Embedded Systems** - Low-overhead persistence
3. **Caching Systems** - Fast binary serialization
4. **Configuration Storage** - Persistent application state

## Core Capabilities

1. **Binary Serialization** - Efficient binary format for all primitive types
2. **Object Chains** - In-memory collections with cursor navigation
3. **Fluent Queries** - Builder pattern query interface
4. **Hash Indexing** - Fast key-based lookups
5. **Soft Delete** - Mark items as deleted without removal
6. **SCOOP Safe** - Thread-safe design

## Out of Scope

- SQL database integration (use simple_sql)
- Network persistence (use simple_http + json)
- Complex queries (joins, aggregations)
- Transaction logging
- Encryption at rest

## Success Criteria

1. Serialize/deserialize objects in under 1ms per item
2. Support all Eiffel primitive types
3. Handle collections of 100,000+ items
4. Zero external dependencies (pure Eiffel)
5. Full Design by Contract coverage
