# S02-CLASS-CATALOG: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Class Hierarchy

```
ANY
├── SIMPLE_PERSIST              # Facade for common operations
├── SP_STORABLE                 # Deferred storable interface
├── SP_WRITER                   # Binary serialization writer
├── SP_READER                   # Binary deserialization reader
├── SP_CHAIN [G -> SP_STORABLE] # Deferred chain base
│   └── SP_ARRAYED_CHAIN [G]    # Array-backed implementation
├── SP_QUERY [G -> SP_STORABLE] # Fluent query builder
├── SP_INDEX [G, K]             # Deferred index base
│   └── SP_HASH_INDEX [G, K]    # Hash-based implementation
```

## Class Descriptions

### SIMPLE_PERSIST (Facade)
Common operations facade for file management.
- **Creation**: `make`
- **Purpose**: File existence, deletion, path management

### SP_STORABLE (Deferred)
Interface for persistable objects.
- **Purpose**: Define serialization contract
- **Features**: `write_to`, `read_from`, `storage_version`

### SP_WRITER
Binary serialization writer using MANAGED_POINTER.
- **Creation**: `make (capacity)`
- **Purpose**: Serialize primitive types to binary

### SP_READER
Binary deserialization reader.
- **Creation**: `make (buffer)`
- **Purpose**: Deserialize binary to primitive types

### SP_CHAIN [G -> SP_STORABLE]
Deferred base for object collections.
- **Purpose**: Define chain contract with persistence

### SP_ARRAYED_CHAIN [G -> SP_STORABLE]
Array-backed chain implementation.
- **Creation**: `make`
- **Purpose**: In-memory collection with file persistence

### SP_QUERY [G -> SP_STORABLE]
Fluent query builder.
- **Creation**: `make (chain)`
- **Purpose**: Where/take/skip query composition

### SP_HASH_INDEX [G -> SP_STORABLE, K -> HASHABLE]
Hash-based index for fast lookups.
- **Creation**: `make (name, key_function)`
- **Purpose**: O(1) key-based item lookup
