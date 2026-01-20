# simple_persist Specification

## 1. Executive Summary

**simple_persist** is an Eiffel library for object persistence that provides SCOOP-safe, contract-driven storage of object collections to binary files.

### What it does
- Stores collections of Eiffel objects to binary files
- Supports save/load roundtrip with version tracking
- Provides fluent query API for filtering collections
- Enables fast lookup through hash-based indexing

### Who it's for
- Eiffel developers needing simple object persistence
- Applications requiring local data storage without database dependencies
- SCOOP-based concurrent applications requiring thread-safe storage

### Key capabilities
- **Chains**: Ordered collections with cursor-based access
- **Serialization**: Binary encoding of primitives and strings
- **Queries**: Fluent API for filtering with AND/OR conditions
- **Indexes**: Hash-based lookup by extracted keys
- **Soft delete**: Mark items deleted without immediate removal

### Design principles
- Design by Contract: Preconditions, postconditions, invariants
- Void safety: All code is void-safe
- SCOOP compatibility: ECF configured for SCOOP concurrency
- Separation of concerns: Distinct classes for chain, serialization, query, index

### Quality guarantees
- Serialization roundtrip preserves data integrity
- Invariants prevent invalid internal states
- Preconditions guard against misuse
- Soft delete enables non-destructive removal

---

## 2. Scope and Purpose

### Purpose
**simple_persist** provides binary file persistence for Eiffel object collections by serializing storable objects through writer/reader buffers.

### Scope

**IN SCOPE:**
- Binary serialization of primitive types (integers, naturals, reals, booleans, characters)
- String serialization with UTF-32 code point encoding
- Ordered collection (chain) management
- File-based persistence with version headers
- Fluent query builder for filtering
- Hash-based indexing by extracted keys
- Soft delete with compaction
- Cursor-based collection traversal

**OUT OF SCOPE:**
- Database connectivity
- Network persistence
- Encryption
- Compression
- Transaction support
- Concurrent file access locking
- Schema migration

### Assumptions
- Single-process access to persistence files
- Adequate disk space for file operations
- Compatible software versions for load operations
- Items implement SP_STORABLE interface correctly
- Callers manage index synchronization manually

---

## 3. Domain Model

### Core Concepts

| Concept | Definition |
|---------|------------|
| Chain | Ordered collection of storable objects with file persistence |
| Storable | Object that can serialize/deserialize itself via writer/reader |
| Writer | Memory buffer accumulating serialized bytes |
| Reader | Memory buffer providing deserialized values |
| Index | Lookup structure mapping keys to chain items |
| Query | Fluent builder for filtering chain items |

### Relationships

```
                    ┌───────────────────┐
                    │  SIMPLE_PERSIST   │
                    │     (Facade)      │
                    └─────────┬─────────┘
                              │
                    ┌─────────┴─────────┐
                    │     SP_CHAIN      │
                    │  (Persistence)    │
                    └────┬────┬────┬────┘
                         │    │    │
              ┌──────────┘    │    └──────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │SP_WRITER │   │SP_READER │   │SP_STORABLE│
        │(Serialize)│   │(Deserial)│   │ (Items)  │
        └──────────┘   └──────────┘   └─────┬────┘
                                            │
                              ┌─────────────┼─────────────┐
                              ▼             ▼             ▼
                        ┌──────────┐ ┌──────────┐ ┌──────────┐
                        │SP_QUERY  │ │SP_INDEX  │ │User Items│
                        │(Filter)  │ │(Lookup)  │ │          │
                        └──────────┘ └──────────┘ └──────────┘
```

---

## 4. System Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     FACADE LAYER                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              SIMPLE_PERSIST                            │  │
│  │   - file_exists, delete_file, error handling          │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     ENGINE LAYER                             │
│  ┌─────────────────────────┐  ┌─────────────────────────┐  │
│  │      SP_CHAIN           │  │    SP_ARRAYED_CHAIN     │  │
│  │  (abstract chain)       │  │  (array implementation) │  │
│  │  - save/load            │  │  - cursor operations    │  │
│  │  - mark_deleted/compact │  │  - CRUD operations      │  │
│  └─────────────────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     HELPER LAYER                             │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────────┐  │
│  │  SP_WRITER    │ │   SP_READER   │ │    SP_QUERY       │  │
│  │  (serialize)  │ │ (deserialize) │ │ (fluent filter)   │  │
│  └───────────────┘ └───────────────┘ └───────────────────┘  │
│  ┌───────────────┐ ┌───────────────────────────────────┐   │
│  │   SP_INDEX    │ │        SP_HASH_INDEX              │   │
│  │  (abstract)   │ │  (hash-based implementation)      │   │
│  └───────────────┘ └───────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   SP_STORABLE                          │  │
│  │   (interface for persistable objects)                 │  │
│  │   - write_to, read_from, is_deleted, storage_version  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility |
|-----------|----------------|
| SIMPLE_PERSIST | Entry point, file operations, error state |
| SP_CHAIN | Collection abstraction, persistence protocol |
| SP_ARRAYED_CHAIN | Array-backed storage, cursor management |
| SP_WRITER | Primitive-to-bytes encoding, buffer management |
| SP_READER | Bytes-to-primitive decoding, position tracking |
| SP_STORABLE | Item serialization interface |
| SP_QUERY | Condition accumulation, filtering execution |
| SP_INDEX | Index interface for key-based lookup |
| SP_HASH_INDEX | Hash table index implementation |

---

## 5. Class Specifications

### SIMPLE_PERSIST (Facade)

**Purpose:** Simplified access to persistence operations

**Invariants:**
```eiffel
invariant
  -- (none defined - gap)
  -- recommended: default_path /= Void
```

| Feature | Type | Purpose | Preconditions | Postconditions |
|---------|------|---------|---------------|----------------|
| make | creation | Initialize facade | - | - |
| file_exists | query | Check file at path | path /= Void | - |
| delete_file | command | Remove file | path /= Void | - |
| set_default_path | command | Configure path | path /= Void | - |
| clear_error | command | Reset error state | - | - |

### SP_CHAIN (Engine - Abstract)

**Purpose:** Manage ordered collection with file persistence

**Invariants:**
```eiffel
invariant
  reader_attached: reader /= Void
  writer_attached: writer /= Void
  deleted_count_non_negative: deleted_count >= 0
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| make | creation | Empty chain | ensure: deleted_count = 0 |
| make_from_file | creation | Load from file | require: path /= Void |
| save_as | command | Persist to file | require: path /= Void; ensure: file_path = path |
| load | command | Restore from file | - |
| mark_deleted | command | Soft delete | require: not empty, valid cursor |
| compact | command | Remove deleted | ensure: deleted_count = 0 |

### SP_ARRAYED_CHAIN (Engine - Concrete)

**Purpose:** Array-backed chain implementation

**Invariants:**
```eiffel
invariant
  items_attached: items /= Void
  -- plus inherited from SP_CHAIN
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| item | query | Current item | require: not empty, valid cursor |
| first, last | query | Boundary access | require: not empty |
| extend | command | Add item | ensure: count increased |
| remove | command | Remove current | require: valid cursor; ensure: count decreased |
| start, forth, back, finish | command | Cursor movement | ensure: index changed |

### SP_WRITER (Helper)

**Purpose:** Serialize primitives to memory buffer

**Invariants:**
```eiffel
invariant
  buffer_attached: buffer /= Void
  count_non_negative: count >= 0
  count_within_capacity: count <= capacity
  capacity_positive: capacity > 0
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| make | creation | Initial capacity | require: capacity > 0 |
| put_integer_* | command | Write integers | ensure: count increased |
| put_string | command | Write string | - |
| reset | command | Clear buffer | ensure: count = 0 |
| grow | command | Expand capacity | ensure: capacity >= requested |

### SP_READER (Helper)

**Purpose:** Deserialize primitives from memory buffer

**Invariants:**
```eiffel
invariant
  buffer_attached: buffer /= Void
  position_non_negative: position >= 0
  position_within_bounds: position <= count
  count_non_negative: count >= 0
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| make | creation | Initial buffer | require: capacity > 0 |
| make_from_buffer | creation | Wrap existing | require: buffer /= Void, count valid |
| read_integer_* | query | Read integers | require: has_more(n); ensure: position advanced |
| read_string | query | Read string | require: has_more(4) |
| reset | command | Restart reading | ensure: position = 0 |

### SP_QUERY (Helper)

**Purpose:** Fluent query builder for filtering

**Invariants:**
```eiffel
invariant
  chain_attached: chain /= Void
  conditions_attached: conditions /= Void
  max_results_non_negative: max_results >= 0
  skip_count_non_negative: skip_count >= 0
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| make | creation | Target chain | require: chain /= Void |
| where | command | Add condition | require: condition /= Void; returns Current |
| and_where, or_where | command | Add with combiner | require: condition /= Void |
| take | command | Limit results | require: n >= 0 |
| skip | command | Skip matches | require: n >= 0 |
| results | query | Execute query | returns ARRAYED_LIST |

### SP_HASH_INDEX (Helper)

**Purpose:** Hash-based index with key extraction

**Invariants:**
```eiffel
invariant
  index_table_attached: index_table /= Void
  key_extractor_attached: key_extractor /= Void
  name_attached: name /= Void
```

| Feature | Type | Purpose | Key Contracts |
|---------|------|---------|---------------|
| make | creation | Named index with extractor | require: name not empty, extractor /= Void |
| items_for_key | query | All items with key | require: key /= Void |
| on_extend | command | Handle item added | require: item /= Void |
| on_remove | command | Handle item removed | require: item /= Void |

---

## 6. Behavioral Specifications

### WORKFLOW: Save Chain to File

**Purpose:** Persist all non-deleted items to binary file

**Steps:**
1. Open file at path for writing
2. Write header: software_version (4 bytes), active_count (4 bytes)
3. For each non-deleted item:
   a. Reset writer
   b. Serialize item to writer
   c. Write item size (4 bytes) + data to file
4. Close file
5. Update chain's file_path

**Preconditions:**
- Path is valid and writable

**Postconditions:**
- File exists at path
- file_path = provided path
- File contains all non-deleted items

### WORKFLOW: Load Chain from File

**Purpose:** Restore chain contents from binary file

**Steps:**
1. Check if file exists (if not, do nothing)
2. Open file for reading
3. Read header: version, count
4. Wipe out existing items
5. For each item (count times or until EOF):
   a. Read item size
   b. Read bytes into reader
   c. Create item via make_default
   d. Deserialize item from reader
   e. Extend chain with item
6. Close file

**Preconditions:**
- file_path is set

**Postconditions:**
- stored_version set from file
- Chain contains loaded items

### WORKFLOW: Execute Query

**Purpose:** Filter chain items based on conditions

**Steps:**
1. Create empty result list
2. Iterate chain from start to end
3. For each non-deleted item:
   a. Evaluate all conditions
   b. If matches:
      - Skip if within skip_count
      - Otherwise add to results
      - Stop if max_results reached
4. Reverse if is_descending
5. Return results

**Preconditions:**
- Chain is set

**Postconditions:**
- Result contains only matching non-deleted items
- Result count <= max_results (if set)

---

## 7. Constraints

### Integrity Rules
- **I1:** Buffer always exists (SP_WRITER, SP_READER invariants)
- **I2:** Byte counts are non-negative (SP_WRITER, SP_READER invariants)
- **I3:** Storage array always exists (SP_ARRAYED_CHAIN invariant)
- **I4:** Index table always exists (SP_HASH_INDEX invariant)

### Validity Rules
- **V1:** Write count <= capacity (SP_WRITER invariant)
- **V2:** Read position <= count (SP_READER invariant)
- **V3:** Deleted count >= 0 (SP_CHAIN invariant)
- **V4:** Capacity > 0 (SP_WRITER invariant)

### Business Rules
- **B1:** Storable objects must implement write_to/read_from
- **B2:** Deleted items excluded from save and query results
- **B3:** Index must have key extractor to function
- **B4:** Query with empty conditions matches all items

### Cross-Class Rules
- **C1:** Writer-Reader symmetry: read(write(x)) = x
- **C2:** Storable serialization: write then read preserves object
- **C3:** Chain items must be SP_STORABLE with make_default

---

## 8. Boundary Conditions

### Collection Boundaries
| Boundary | Behavior |
|----------|----------|
| Empty chain save | Writes header with count=0 |
| Empty chain load | Chain remains empty |
| Single item | first = last, count = 1 |
| All deleted | save writes no items, query returns empty |

### Numeric Boundaries
| Parameter | Min | Max | Edge Behavior |
|-----------|-----|-----|---------------|
| capacity | 1 | MAX_INT | Works but grows often at min |
| max_results | 0 | MAX_INT | 0 = unlimited |
| skip_count | 0 | MAX_INT | skip >= matches = empty result |

### Cursor Boundaries
| Position | State | item Access |
|----------|-------|-------------|
| 0 | before | Invalid |
| 1..count | valid | OK |
| count+1 | after | Invalid |

---

## 9. Error Handling

### Handled Errors
| Error | Handling | Recovery |
|-------|----------|----------|
| File not found on load | Silent skip | Chain stays empty |
| Key not in index | Return empty list | Normal operation |
| EOF before count | Partial load | Data available |

### Unhandled Errors (Gaps)
| Error | Current Behavior | Recommended |
|-------|------------------|-------------|
| Invalid file path | RAW_FILE exception | Precondition or catch |
| Disk full | RAW_FILE exception | Error state on facade |
| Corrupt file | Undefined | Validation on load |
| Negative string length | Huge allocation | Bounds check |

### Precondition Violations
- Invalid cursor position: Exception
- Buffer exhausted: Exception
- Void arguments: Exception

---

## 10. Quality Attributes

### Void Safety
**Status:** FULL

All classes use attached types by default. Detachable types:
- `SP_QUERY.comparator` (optional ordering)
- `SP_INDEX.first_for_key` return (may not exist)
- `SIMPLE_PERSIST.last_error` (no error case)

### SCOOP Compatibility
**Status:** PARTIAL

ECF declares `concurrency=scoop` but code has no `separate` keywords. Compatibility achieved through:
- No shared mutable state between objects
- Value-based data passing
- Reader/writer are chain-local

Gap: No explicit SCOOP testing

### Testability
**Status:** MEDIUM

- 8 tests cover basic functionality
- All public features accessible
- Chain iteration allows inspection
- Missing: Mock support, isolation patterns

### Contract Coverage
**Status:** 45%

| Category | Coverage |
|----------|----------|
| Preconditions | 60% |
| Postconditions | 35% |
| Invariants | 70% (6/9 classes) |

---

## 11. Open Questions

1. **Index-Chain Integration:** Should chain automatically notify indexes, or is manual synchronization intentional?

2. **Version Migration:** What should happen when stored_version != software_version?

3. **Query Comparator:** order_by stores comparator but results doesn't sort. Bug or incomplete feature?

4. **Error Propagation:** Should chain errors update facade.has_error?

5. **Atomic Writes:** Should save use temporary file + rename for atomicity?

6. **Concurrent Access:** Should file locking be added for multi-process safety?

---

## Appendix A: Contract Gaps

### Missing Invariants
| Class | Suggested |
|-------|-----------|
| SIMPLE_PERSIST | `default_path /= Void` |
| SP_STORABLE | `byte_count >= 0` |

### Missing Preconditions
| Feature | Suggested |
|---------|-----------|
| SP_WRITER.put_string | `v /= Void` |
| SP_WRITER.to_file | `a_file.is_open_write` |
| SP_CHAIN.load | `not file_path.is_empty` |

### Missing Postconditions
| Feature | Suggested |
|---------|-----------|
| SIMPLE_PERSIST.set_default_path | `default_path = a_path` |
| SP_HASH_INDEX.on_extend | `has_item(a_item)` |
| SP_HASH_INDEX.wipe_out | `is_empty` |
| SP_QUERY.results | `Result /= Void` |

---

## Appendix B: Test Coverage Gaps

### High Priority
- Empty chain save/load
- Corrupt file handling
- Large file performance
- SCOOP concurrent access

### Medium Priority
- Unicode string serialization
- Query pagination (skip + take)
- OR conditions in queries
- Index removal operations

### Low Priority
- order_descending
- not_where negation
- Multiple indexes on chain

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S07-SYNTHESIZE-SPEC
