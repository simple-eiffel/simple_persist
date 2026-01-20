# S01: Project Inventory - simple_persist

## PROJECT IDENTITY

| Field | Value |
|-------|-------|
| Library name | simple_persist |
| Library UUID | A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D |
| Stated purpose | Simple Eiffel object persistence library with SCOOP-safe chains |
| Version | 1.0.0 (build 1) |

## DEPENDENCIES: 2

| Dependency | Location | Why needed |
|------------|----------|------------|
| base | $ISE_LIBRARY\library\base\base.ecf | Core Eiffel types: ARRAYED_LIST, HASH_TABLE, MANAGED_POINTER, PATH, RAW_FILE |
| time | $ISE_LIBRARY\library\time\time.ecf | (Currently unused, potentially for timestamps) |

### Dependency Categories
- **Core (EiffelBase):** base, time
- **Simple ecosystem:** None
- **External (third-party):** None

## CLUSTERS: 2

| Cluster | Location | Classes | Purpose |
|---------|----------|---------|---------|
| src | .\src\ | 9 | Main implementation - chains, serialization, indexing, queries |
| tests | .\testing\ | 2 | Test classes |

## CLASSES: 11

### By Role

**FACADE (1):**
- `SIMPLE_PERSIST` - Main entry point providing simplified access to persistence operations

**ENGINE (6):**
- `SP_CHAIN` - Deferred generic chain base class with file persistence
- `SP_ARRAYED_CHAIN` - Array-backed chain implementation
- `SP_WRITER` - Memory buffer writer for serialization
- `SP_READER` - Memory buffer reader for deserialization
- `SP_QUERY` - Fluent query builder for filtering chain items
- `SP_HASH_INDEX` - Hash-based index with agent key extraction

**DATA (1):**
- `SP_STORABLE` - Deferred base class for objects that can be stored/retrieved

**HELPER (1):**
- `SP_INDEX` - Deferred base class for chain indexes

**TEST (2):**
- `SP_TEST_APP` - Test application runner
- `SP_TEST_ITEM` - Test storable item implementation

### Class Details

| Class | File | Has Note | Creation | Public Features | Has Invariant | Inherits From |
|-------|------|----------|----------|-----------------|---------------|---------------|
| SIMPLE_PERSIST | src\simple_persist.e | YES | make | 9 | NO | — |
| SP_CHAIN | src\sp_chain.e | YES | make, make_from_file | 31 | YES | — |
| SP_ARRAYED_CHAIN | src\sp_arrayed_chain.e | YES | make, make_from_file, make_with_capacity | 21 | YES | SP_CHAIN |
| SP_WRITER | src\sp_writer.e | YES | make | 18 | YES | — |
| SP_READER | src\sp_reader.e | YES | make, make_from_buffer | 20 | YES | — |
| SP_STORABLE | src\sp_storable.e | YES | make_default | 9 | NO | — |
| SP_INDEX | src\sp_index.e | YES | — (deferred) | 11 | NO | — |
| SP_HASH_INDEX | src\sp_hash_index.e | YES | make | 13 | YES | SP_INDEX |
| SP_QUERY | src\sp_query.e | YES | make | 15 | YES | — |
| SP_TEST_APP | testing\sp_test_app.e | YES | make | 8 | NO | — |
| SP_TEST_ITEM | testing\sp_test_item.e | YES | make_default, make_with_name | 10 | NO | SP_STORABLE |

## FACADE IDENTIFICATION

**Primary Facade:** `SIMPLE_PERSIST`

**Evidence:**
1. Named following `SIMPLE_{X}` convention
2. Note clause: "Facade class providing simplified access to persistence operations"
3. Creation procedure `make` - simple initialization
4. Provides high-level operations: `file_exists`, `delete_file`, error handling
5. Version query for library identification

## TEST INVENTORY

| Test Class | Test Count | Tests |
|------------|------------|-------|
| SP_TEST_APP | 8 | test_create_chain, test_facade_creation, test_writer_reader_roundtrip, test_chain_extend, test_chain_cursor, test_chain_remove, test_query_basic, test_index_basic |

**Total Tests:** 8

**Features Tested:**
- Chain creation (SP_ARRAYED_CHAIN.make)
- Facade creation (SIMPLE_PERSIST.make)
- Serialization roundtrip (SP_WRITER/SP_READER)
- Chain extend/cursor/remove operations
- Query filtering (SP_QUERY.where)
- Index operations (SP_HASH_INDEX.on_extend, items_for_key)

## CONFIGURATION

| Setting | Value |
|---------|-------|
| Void safety | all |
| Concurrency | SCOOP |
| Assertions | precondition, postcondition, check, invariant, loop, supplier_precondition |
| Console application | true |
| Dead code removal | feature |
| Syntax | provisional |

## DOCUMENTATION STATUS

| Item | Status |
|------|--------|
| README | ABSENT |
| Note clauses | 100% of classes (11/11) |
| Header comments | ~90% of features |
| Contracts | All public features have preconditions/postconditions |
| Invariants | 6 classes have invariants |

## INHERITANCE HIERARCHY

```
SP_STORABLE (deferred)
  └── SP_TEST_ITEM

SP_CHAIN [G -> SP_STORABLE] (deferred)
  └── SP_ARRAYED_CHAIN [G -> SP_STORABLE]

SP_INDEX [G, K] (deferred)
  └── SP_HASH_INDEX [G, K]
```

## GENERIC CONSTRAINTS

| Class | Type Parameter | Constraint |
|-------|----------------|------------|
| SP_CHAIN | G | SP_STORABLE create make_default end |
| SP_ARRAYED_CHAIN | G | SP_STORABLE create make_default end |
| SP_INDEX | G | SP_STORABLE |
| SP_INDEX | K | HASHABLE |
| SP_HASH_INDEX | G | SP_STORABLE |
| SP_HASH_INDEX | K | HASHABLE |
| SP_QUERY | G | SP_STORABLE |

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S01-INVENTORY-PROJECT
