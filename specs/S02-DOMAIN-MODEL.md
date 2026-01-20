# S02: Domain Model - simple_persist

## PROBLEM DOMAIN

This library addresses **object persistence** in Eiffel applications. It provides a mechanism to store collections of objects to files and retrieve them later, with support for querying and indexing. The design emphasizes SCOOP-safety for concurrent applications and follows Design by Contract principles for reliable operation.

## CORE CONCEPTS

| Concept | Definition |
|---------|------------|
| **Chain** | An ordered collection of storable objects that can be persisted to a file and retrieved |
| **Storable** | An object that can serialize its state to bytes and reconstruct itself from bytes |
| **Writer** | A memory buffer that accumulates serialized bytes for eventual file output |
| **Reader** | A memory buffer that provides deserialized values from file input |
| **Index** | A lookup structure mapping keys to chain items for fast retrieval |
| **Query** | A fluent builder for filtering chain items based on conditions |
| **Persistence** | The act of saving chain state to a file and loading it back |

## RELATIONSHIPS

```
                    ┌───────────────────┐
                    │  SIMPLE_PERSIST   │
                    │     (Facade)      │
                    └─────────┬─────────┘
                              │
                              │ uses
                              ▼
    ┌──────────────────────────────────────────────────┐
    │                   SP_CHAIN [G]                    │
    │              (Collection + Persistence)           │
    └──────────┬────────────────────────────┬──────────┘
               │                            │
          extends                      uses │
               │                            │
               ▼                            ▼
    ┌─────────────────────┐       ┌────────────────────┐
    │  SP_ARRAYED_CHAIN   │       │ SP_WRITER/SP_READER│
    │   (Array Storage)   │       │  (Serialization)   │
    └─────────────────────┘       └────────────────────┘
               │
          contains
               │
               ▼
    ┌─────────────────────┐
    │    SP_STORABLE      │◄─────────────────────────────┐
    │   (Persistable)     │                              │
    └─────────────────────┘                              │
               │                                         │
          referenced by                            indexed by
               │                                         │
               ▼                                         │
    ┌─────────────────────┐       ┌─────────────────────┐
    │     SP_QUERY        │       │    SP_HASH_INDEX    │
    │   (Filtering)       │       │    (Fast Lookup)    │
    └─────────────────────┘       └─────────────────────┘
```

### Relationship Details

| From | Relationship | To | Description |
|------|--------------|-----|-------------|
| SP_ARRAYED_CHAIN | is-a | SP_CHAIN | Concrete array-backed implementation |
| SP_HASH_INDEX | is-a | SP_INDEX | Concrete hash-based implementation |
| SP_CHAIN | contains | SP_STORABLE | Items in the chain |
| SP_CHAIN | uses | SP_WRITER | For serialization |
| SP_CHAIN | uses | SP_READER | For deserialization |
| SP_QUERY | filters | SP_CHAIN | Queries operate on chains |
| SP_INDEX | references | SP_STORABLE | Index entries point to items |
| SP_STORABLE | writes-to | SP_WRITER | Serializes its state |
| SP_STORABLE | reads-from | SP_READER | Deserializes its state |

## VOCABULARY

| Term | Source | Definition |
|------|--------|------------|
| chain | SP_CHAIN | Ordered collection with persistence capabilities |
| storable | SP_STORABLE | Object that can serialize/deserialize itself |
| buffer | SP_WRITER, SP_READER | Memory area holding serialized bytes |
| capacity | SP_WRITER | Maximum bytes buffer can hold before growing |
| position | SP_READER | Current read location in buffer |
| count | SP_WRITER, SP_READER, SP_CHAIN | Number of bytes or items |
| cursor | SP_CHAIN | Current iteration position in chain |
| index | SP_CHAIN, SP_INDEX | Position (chain) or lookup structure (index) |
| key | SP_INDEX, SP_HASH_INDEX | Value used to locate items |
| key_extractor | SP_HASH_INDEX | Agent that derives key from item |
| condition | SP_QUERY | Predicate function for filtering |
| combiner | SP_QUERY | AND/OR logical operator between conditions |
| deleted | SP_STORABLE | Soft-delete marker, item still in chain but excluded |
| active | SP_CHAIN | Items not marked as deleted |
| version | SP_CHAIN, SP_STORABLE | Schema version for migration support |
| compact | SP_CHAIN | Remove physically all soft-deleted items |

## RESPONSIBILITIES

### SIMPLE_PERSIST (Facade)
- **Primary:** Provide simplified access to persistence operations
- **State:** default_path, error state
- **Behavior:** File existence check, file deletion, error reporting
- **Collaborators:** Uses RAW_FILE directly

### SP_CHAIN (Engine - Abstract)
- **Primary:** Manage ordered collection with file persistence
- **State:** file_path, reader, writer, deleted_count, stored_version
- **Behavior:** CRUD operations, cursor movement, save/load, iteration
- **Collaborators:** SP_WRITER, SP_READER, SP_STORABLE (items)

### SP_ARRAYED_CHAIN (Engine - Concrete)
- **Primary:** Array-backed storage implementation of chain
- **State:** items (ARRAYED_LIST), cursor_index
- **Behavior:** Implements all deferred features from SP_CHAIN
- **Collaborators:** ARRAYED_LIST, parent SP_CHAIN

### SP_WRITER (Helper)
- **Primary:** Serialize primitive values to memory buffer
- **State:** buffer (MANAGED_POINTER), count, capacity
- **Behavior:** Put operations for all primitive types, auto-grow
- **Collaborators:** MANAGED_POINTER, RAW_FILE

### SP_READER (Helper)
- **Primary:** Deserialize primitive values from memory buffer
- **State:** buffer (MANAGED_POINTER), position, count, data_version
- **Behavior:** Read operations for all primitive types
- **Collaborators:** MANAGED_POINTER, RAW_FILE

### SP_STORABLE (Data - Abstract)
- **Primary:** Define interface for persistable objects
- **State:** is_deleted
- **Behavior:** write_to, read_from, deletion markers
- **Collaborators:** SP_WRITER, SP_READER

### SP_INDEX (Helper - Abstract)
- **Primary:** Define interface for chain indexing
- **State:** (none in base)
- **Behavior:** Key lookup, item tracking events
- **Collaborators:** SP_STORABLE (items)

### SP_HASH_INDEX (Helper - Concrete)
- **Primary:** Hash-based index with agent key extraction
- **State:** name, key_extractor, index_table (HASH_TABLE)
- **Behavior:** Add/remove items, lookup by key
- **Collaborators:** HASH_TABLE, FUNCTION (key extractor agent)

### SP_QUERY (Helper)
- **Primary:** Fluent query builder for filtering chains
- **State:** chain, conditions, max_results, skip_count, comparator, is_descending
- **Behavior:** Build conditions, execute query, return results
- **Collaborators:** SP_CHAIN, FUNCTION (conditions)

## DOMAIN RULES (from Invariants)

### SP_WRITER
| Invariant | Domain Meaning |
|-----------|----------------|
| buffer_attached | Writer must always have a valid buffer |
| count_non_negative | Cannot have negative bytes written |
| count_within_capacity | Cannot exceed allocated memory |
| capacity_positive | Must have room to write at least 1 byte |

### SP_READER
| Invariant | Domain Meaning |
|-----------|----------------|
| buffer_attached | Reader must always have a valid buffer |
| position_non_negative | Cannot read from negative offset |
| position_within_bounds | Cannot read past end of data |
| count_non_negative | Cannot have negative bytes in buffer |

### SP_CHAIN
| Invariant | Domain Meaning |
|-----------|----------------|
| reader_attached | Chain must always have deserialization capability |
| writer_attached | Chain must always have serialization capability |
| deleted_count_non_negative | Deleted count cannot go negative |

### SP_ARRAYED_CHAIN
| Invariant | Domain Meaning |
|-----------|----------------|
| items_attached | Storage array must exist |

### SP_HASH_INDEX
| Invariant | Domain Meaning |
|-----------|----------------|
| index_table_attached | Hash table must exist |
| key_extractor_attached | Must have way to derive keys |
| name_attached | Index must be identifiable |

### SP_QUERY
| Invariant | Domain Meaning |
|-----------|----------------|
| chain_attached | Query must target a chain |
| conditions_attached | Condition list must exist |
| max_results_non_negative | Cannot limit to negative count |
| skip_count_non_negative | Cannot skip negative items |

## DESIGN PATTERNS USED

| Pattern | Implementation | Purpose |
|---------|----------------|---------|
| Facade | SIMPLE_PERSIST | Simplified API entry point |
| Template Method | SP_CHAIN (deferred) → SP_ARRAYED_CHAIN | Storage abstraction |
| Strategy | key_extractor agent | Customizable key extraction |
| Builder/Fluent | SP_QUERY.where().take().results | Query construction |
| Observer | SP_INDEX.on_extend/on_remove | Index maintenance |
| Soft Delete | SP_STORABLE.is_deleted | Non-destructive removal |

## OPEN QUESTIONS

1. **Index-Chain Integration:** The index event handlers (on_extend, on_remove) exist but there's no automatic integration - the chain doesn't call index methods. Is this intentional for flexibility, or should there be an `add_index` feature on SP_CHAIN?

2. **Version Migration:** `stored_version` and `software_version` exist but no migration logic is implemented. How should version mismatches be handled?

3. **Concurrency:** ECF specifies SCOOP but there are no `separate` keywords in the code. Is SCOOP compatibility achieved through design (no shared mutable state) or should explicit SCOOP annotations be added?

4. **Error Handling:** The facade has error state but the chain operations don't propagate errors. Should there be exception handling or error callbacks?

5. **Query Sorting:** `order_by` exists but `comparator` is never used in `results`. Is sorting implemented?

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S02-EXTRACT-DOMAIN-MODEL
