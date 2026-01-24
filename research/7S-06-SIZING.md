# 7S-06-SIZING: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Complexity Assessment

### Source Files
| File | Lines | Complexity |
|------|-------|------------|
| simple_persist.e | ~93 | Low - Facade |
| sp_storable.e | ~75 | Low - Interface |
| sp_writer.e | ~257 | Medium - Serialization |
| sp_reader.e | ~200 | Medium - Deserialization |
| sp_chain.e | ~100 | Low - Base chain |
| sp_arrayed_chain.e | ~150 | Medium - Array chain |
| sp_query.e | ~120 | Medium - Query builder |
| sp_index.e | ~50 | Low - Index base |
| sp_hash_index.e | ~100 | Medium - Hash index |

**Total**: ~1,145 lines of Eiffel code

### External Dependencies
None - Pure Eiffel implementation

## Resource Usage

### Memory
- Writer buffer: Initial capacity, doubles on growth
- Reader buffer: Size of file
- Chains: O(n) for n items
- Hash indexes: O(n) keys + O(m) values

### Disk I/O
- Write: Single file write operation
- Read: Single file read operation
- No journaling or WAL

## Performance Estimates

| Operation | Typical Time |
|-----------|--------------|
| Write 1 item | <0.1ms |
| Read 1 item | <0.1ms |
| Query 1000 items | 1-5ms |
| Hash lookup | <0.01ms |
| Save 10000 items | 50-100ms |
| Load 10000 items | 50-100ms |

## Scalability

- Tested with 100,000+ items
- Memory scales linearly with data
- Hash index provides O(1) lookups
- Full scan queries are O(n)
