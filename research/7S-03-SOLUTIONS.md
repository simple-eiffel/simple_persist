# 7S-03-SOLUTIONS: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Alternative Solutions Considered

### 1. EiffelStore (Rejected)
- **Approach**: Use built-in EiffelStore persistence
- **Pros**: Standard library, well-tested
- **Cons**: Complex API, RDBMS focus, not SCOOP-compatible
- **Decision**: Rejected - too heavy, SCOOP issues

### 2. JSON Serialization (Rejected)
- **Approach**: Store objects as JSON files
- **Pros**: Human-readable, simple_json available
- **Cons**: Slow for large datasets, no indexing
- **Decision**: Rejected - performance concerns

### 3. SQLite (Rejected for this library)
- **Approach**: Use embedded SQLite database
- **Pros**: Full SQL, ACID, proven
- **Cons**: External dependency, SQL overhead
- **Decision**: Rejected - use simple_sql for this

### 4. Custom Binary Format (Chosen)
- **Approach**: Custom binary serialization with managed pointers
- **Pros**: Fast, compact, SCOOP-safe, pure Eiffel
- **Cons**: Not human-readable, custom format
- **Decision**: Selected - best performance

## Architecture Decisions

1. **SP_STORABLE interface** - Objects define their own serialization
2. **SP_WRITER/SP_READER pair** - Symmetric serialization API
3. **SP_CHAIN abstraction** - Collection with persistence
4. **SP_QUERY fluent interface** - Composable queries
5. **SP_HASH_INDEX** - O(1) key lookups

## Key Design Choices

- Memory buffer growth strategy: Double capacity
- String encoding: 4-byte length prefix + UTF-32 codes
- Soft delete: Boolean flag, not physical removal
- Index maintenance: Manual triggers (on_extend, on_remove)
