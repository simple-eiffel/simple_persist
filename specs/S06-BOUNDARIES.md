# S06: Boundary Specifications - simple_persist

## Test Case Analysis

### test_create_chain
- **Tests:** SP_ARRAYED_CHAIN.make
- **Input:** None (default construction)
- **Expected:** Empty chain, count = 0
- **Boundary aspect:** Empty collection state

### test_facade_creation
- **Tests:** SIMPLE_PERSIST.make
- **Input:** None (default construction)
- **Expected:** has_error = False
- **Boundary aspect:** Initial error state

### test_writer_reader_roundtrip
- **Tests:** SP_WRITER.put_*, SP_READER.read_*
- **Input:** INTEGER_32 (42), STRING ("Hello"), BOOLEAN (True)
- **Expected:** Values match after roundtrip
- **Boundary aspect:** Basic type serialization

### test_chain_extend
- **Tests:** SP_ARRAYED_CHAIN.extend
- **Input:** Two items with names and values
- **Expected:** count = 2, first/last correct
- **Boundary aspect:** Multi-item insertion

### test_chain_cursor
- **Tests:** SP_ARRAYED_CHAIN.start/forth/finish/back
- **Input:** Three items
- **Expected:** Cursor navigation works correctly
- **Boundary aspect:** Cursor movement at boundaries

### test_chain_remove
- **Tests:** SP_ARRAYED_CHAIN.remove
- **Input:** Two items, remove second
- **Expected:** count = 1, first item remains
- **Boundary aspect:** Removal with cursor positioning

### test_query_basic
- **Tests:** SP_QUERY.where().results
- **Input:** Three items with values 10, 20, 30; filter > 15
- **Expected:** Two results
- **Boundary aspect:** Filtering with value threshold

### test_index_basic
- **Tests:** SP_HASH_INDEX.on_extend, items_for_key
- **Input:** Three items, two with same key "Alpha"
- **Expected:** key_count = 2, item_count = 3
- **Boundary aspect:** Multiple items per key

---

## Edge Cases

### Empty Input Cases

| Edge Case | Valid | Expected Behavior | Tested | Contract |
|-----------|-------|-------------------|--------|----------|
| Empty chain save | YES | Writes header with count=0 | NO | None |
| Empty chain load | YES | Chain remains empty | NO | None |
| Empty query results | YES | Returns empty list | NO | None |
| Empty string serialize | YES | Writes 4 bytes (length=0) | NO | None |
| Empty index | YES | is_empty = True | NO | None |

### Single Element Cases

| Edge Case | Valid | Expected Behavior | Tested | Contract |
|-----------|-------|-------------------|--------|----------|
| Single item chain | YES | count = 1, first = last | NO | None |
| Single condition query | YES | Evaluates that condition | YES | None |
| Single key in index | YES | key_count = 1 | NO | None |
| Single byte write/read | YES | Works correctly | NO | has_more(1) |
| Single char string | YES | 8 bytes total | NO | None |

### Boundary Value Cases

| Edge Case | Valid | Expected Behavior | Tested | Contract |
|-----------|-------|-------------------|--------|----------|
| capacity = 1 writer | YES | Works but grows often | NO | capacity > 0 |
| position = count reader | YES | is_end_of_buffer = True | NO | position <= count |
| skip_count = result_count | YES | Empty result | NO | skip_count >= 0 |
| max_results = 0 | YES | Unlimited (special case) | NO | max_results >= 0 |
| cursor at before | YES | Cannot access item | NO | not before |
| cursor at after | YES | Cannot access item | NO | not after |

---

## Limits

### Numeric Limits

| Parameter | Min | Max | Typical | Enforced By |
|-----------|-----|-----|---------|-------------|
| SP_WRITER.capacity | 1 | INTEGER_32.max | 4096 | precondition > 0 |
| SP_READER.position | 0 | count | varies | invariant |
| SP_QUERY.max_results | 0 (unlimited) | INTEGER.max | 10-100 | precondition >= 0 |
| SP_QUERY.skip_count | 0 | INTEGER.max | 0-100 | precondition >= 0 |
| SP_CHAIN.deleted_count | 0 | count | low | invariant >= 0 |
| SP_HASH_INDEX initial table | 100 | unlimited | 100 | hardcoded |

### Collection Limits

| Collection | Min Size | Max Practical | Empty Allowed |
|------------|----------|---------------|---------------|
| SP_ARRAYED_CHAIN items | 0 | memory limit | YES |
| SP_QUERY conditions | 0 | ~20 reasonable | YES (returns all) |
| SP_HASH_INDEX entries | 0 | memory limit | YES |
| SP_WRITER buffer | 1 byte | memory limit | NO (capacity > 0) |
| SP_READER buffer | 0 bytes | memory limit | YES (count = 0) |

### String Limits

| String Parameter | Min Length | Max Length | Empty Allowed | Notes |
|------------------|------------|------------|---------------|-------|
| SP_HASH_INDEX.name | 1 | unlimited | NO | precondition |
| SP_WRITER.put_string input | 0 | memory limit | YES | 4 bytes/char |
| SP_READER.read_string result | 0 | memory limit | YES | 4 bytes/char |

---

## Error Conditions

### File Operations

| Error | Trigger | Handling | User Notification | Recovery |
|-------|---------|----------|-------------------|----------|
| File not found | SP_CHAIN.load on missing file | Silent skip | None | Chain stays empty |
| Permission denied | SP_CHAIN.save_as to protected path | RAW_FILE exception | Stack trace | Catch exception |
| Disk full | SP_CHAIN.save_as | RAW_FILE exception | Stack trace | Free space |
| Path invalid | Invalid path characters | OS exception | Stack trace | Fix path |

### Memory Operations

| Error | Trigger | Handling | User Notification | Recovery |
|-------|---------|----------|-------------------|----------|
| Out of memory | Large buffer allocation | Eiffel OOM exception | Stack trace | Reduce size |
| Buffer overflow | Bug in ensure_capacity | Prevented by invariant | N/A | N/A |

### Data Corruption

| Error | Trigger | Handling | User Notification | Recovery |
|-------|---------|----------|-------------------|----------|
| Truncated file | File cut short | Partial load (EOF check) | Silent | Delete/recreate |
| Corrupt header | Invalid version/count | Undefined behavior | None | Delete file |
| Negative string length | Corrupt data | Huge allocation attempt | OOM or crash | Delete file |

### Precondition Violations

| Error | Trigger | Handling | User Notification | Recovery |
|-------|---------|----------|-------------------|----------|
| Void argument | Passing Void to attached param | Precondition exception | Stack trace | Fix caller |
| Invalid index | Access out of bounds | Precondition exception | Stack trace | Fix caller |
| Buffer underflow | read_* without enough bytes | Precondition exception | Stack trace | Fix caller |

---

## Failure Modes

### FAILURE: Cursor in invalid position
- **Cause:** Calling item/put/remove without valid cursor
- **Symptoms:** Precondition violation exception
- **State after:** Unchanged
- **Recovery:** Call start/go_i_th to valid position
- **Contract:** `not before and not after`

### FAILURE: Reader buffer exhausted
- **Cause:** Reading more bytes than available
- **Symptoms:** Precondition violation (has_more fails)
- **State after:** Position unchanged at failed read
- **Recovery:** Reset position, or provide more data
- **Contract:** `has_more(n)` for each read

### FAILURE: Index out of sync with chain
- **Cause:** Modifying chain without calling index handlers
- **Symptoms:** Stale index returns wrong items
- **State after:** Index inconsistent with chain
- **Recovery:** Rebuild index or call correct handlers
- **Contract:** None (design gap)

### FAILURE: Version mismatch on load
- **Cause:** Loading file from different software version
- **Symptoms:** Unknown - no migration logic
- **State after:** Possibly corrupted items
- **Recovery:** Manual migration or delete file
- **Contract:** None (has_version_mismatch query exists but unused)

### FAILURE: Partial file write
- **Cause:** Crash/power loss during save_as
- **Symptoms:** Truncated file
- **State after:** Corrupted file on disk
- **Recovery:** Load fails gracefully, use backup
- **Contract:** None (no atomic write)

---

## Precondition Boundary Analysis

| Precondition | Feature | Boundary Implied | Just-Valid | Just-Invalid |
|--------------|---------|------------------|------------|--------------|
| `a_capacity > 0` | SP_WRITER.make | capacity minimum | 1 | 0 |
| `n >= 0` | SP_QUERY.take/skip | non-negative limit | 0 | -1 |
| `not a_name.is_empty` | SP_HASH_INDEX.make | non-empty name | "x" | "" |
| `has_more(1)` | SP_READER.read_integer_8 | 1 byte available | pos+1 <= count | pos >= count |
| `has_more(4)` | SP_READER.read_integer_32 | 4 bytes available | pos+4 <= count | pos+3 >= count |
| `not before and not after` | SP_ARRAYED_CHAIN.item | valid cursor | 1..count | 0 or count+1 |
| `valid_index(i)` | SP_ARRAYED_CHAIN.i_th | i in 1..count | 1 or count | 0 or count+1 |
| `not is_empty` | SP_ARRAYED_CHAIN.first | at least one item | count >= 1 | count = 0 |

---

## Test Coverage Gaps

### High Priority (Need Tests)

| Missing Test | Should Test | Why Risky | Priority |
|--------------|-------------|-----------|----------|
| Empty chain save/load | File format with 0 items | Silent data loss | HIGH |
| Corrupt file load | Handling of malformed data | Crash or undefined behavior | HIGH |
| Concurrent access | SCOOP safety | Data races | HIGH |
| Very large file | Performance and memory | OOM or slowness | HIGH |

### Medium Priority (Should Test)

| Missing Test | Should Test | Why Risky | Priority |
|--------------|-------------|-----------|----------|
| Unicode strings | Non-ASCII serialization | Encoding bugs | MEDIUM |
| Skip + take combination | Pagination behavior | Wrong results | MEDIUM |
| OR conditions in query | Condition combination | Logic bugs | MEDIUM |
| Index remove | Index maintenance | Stale entries | MEDIUM |
| Version mismatch | Migration/error handling | Silent corruption | MEDIUM |

### Low Priority (Nice to Test)

| Missing Test | Should Test | Why Risky | Priority |
|--------------|-------------|-----------|----------|
| order_descending | Result reversal | Minor feature | LOW |
| not_where | Negated conditions | Logic edge case | LOW |
| Multiple indexes | Index coordination | Feature not used yet | LOW |
| Boundary cursor positions | before/after states | Covered by preconditions | LOW |

---

## Defensive Programming Analysis

### Buffer Auto-Growth (SP_WRITER.ensure_capacity)
- **Location:** SP_WRITER:237-243
- **Protects against:** Buffer overflow
- **Necessary:** YES - critical safety mechanism
- **Assessment:** Well implemented

### EOF Check in Load (SP_CHAIN.load)
- **Location:** SP_CHAIN:275
- **Protects against:** Reading past file end
- **Necessary:** YES - handles truncated files
- **Assessment:** Partial - doesn't validate header

### Empty List Return (SP_HASH_INDEX.items_for_key)
- **Location:** SP_HASH_INDEX:42-47
- **Protects against:** Key not found returning Void
- **Necessary:** YES - void safety
- **Assessment:** Good - returns empty list not Void

### Deleted Item Skip (SP_CHAIN.save_as, SP_QUERY.results)
- **Location:** Multiple places
- **Protects against:** Persisting/returning soft-deleted items
- **Necessary:** YES - soft delete semantics
- **Assessment:** Consistent implementation

### Empty Key List Removal (SP_HASH_INDEX.remove_item)
- **Location:** SP_HASH_INDEX:171-173
- **Protects against:** Memory leak from empty lists
- **Necessary:** YES - prevents table bloat
- **Assessment:** Good cleanup

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S06-EXTRACT-BOUNDARIES
