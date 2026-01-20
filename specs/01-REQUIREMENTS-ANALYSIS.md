# 01: Requirements Analysis - simple_persist

**Working Hat**: SPECIFICATION
**Layer Being Built**: SPECIFICATION LAYER
**Source**: Eiffel-Loop Eco-DB (26 classes → ~15 simple_* classes)

---

## INPUT: Requirements

### From Master Recommendations (00_MASTER_RECOMMENDATIONS.md)
- **Score**: 23/30 (HIGHEST priority BUILD)
- **What**: SCOOP-safe object persistence with recoverable chains
- **Why**: SCOOP-safe chains are unique; field indexing valuable

### From Eco-DB Inventory
- Chain-based storage/retrieval
- AES encryption for sensitive data
- Incremental change tracking (editions)
- Version migration support
- Automatic field indexing
- Query language (AND, OR, NOT)
- CSV/Pyxis export

### From EL_LIBRARY_ASSESSMENT.md
- CHAIN stored in single file
- Field indexing for search
- Auto-version management
- Import/export (CSV, Pyxis)
- SCOOP-ready architecture

---

## 1. DOMAIN MODEL

### Key Domain Concepts

| Concept | Definition | Relationships |
|---------|------------|---------------|
| **Persistable** | Any object that can be saved/loaded | Has serialization strategy |
| **Chain** | Ordered collection stored to file | Contains Persistables |
| **Edition** | Incremental change set | Belongs to Chain |
| **Index** | Fast lookup by field value | References Chain items |
| **Query** | Filter expression | Operates on Chain |
| **Store** | File-based persistence target | Contains one Chain |

### Domain Rules (ALWAYS hold)

1. A Chain always has zero or more items
2. A Chain can be written to exactly one Store at a time
3. An Index always reflects current Chain state
4. A saved Chain can always be restored (if not corrupted)
5. Editions are append-only (new changes appended, old preserved)

### Domain Rules (NEVER violated)

1. Never write to closed Store
2. Never read from non-existent Store
3. Never add item of wrong type to Chain
4. Never query with invalid field reference
5. Never corrupt existing data on save failure

---

## 2. ENTITIES

### PERSISTABLE
- **Domain meaning**: Any object that can be serialized and stored
- **Domain rules**:
  - Must be serializable to bytes
  - Must be reconstructable from bytes
  - Identity preserved across save/load cycles

### CHAIN [G -> PERSISTABLE]
- **Domain meaning**: Ordered, typed collection that can be persisted as a unit
- **Domain rules**:
  - Type-safe (only accepts G items)
  - Order preserved
  - Can be empty
  - Tracks modifications for incremental save

### STORE
- **Domain meaning**: File-based persistence target for a single Chain
- **Domain rules**:
  - One file = one Chain
  - Must be opened before use
  - Must be closed after use
  - Provides read/write operations

### EDITION
- **Domain meaning**: Set of changes since last full save
- **Domain rules**:
  - Records additions, modifications, deletions
  - Can be applied to recover Chain state
  - Ordered by creation time

### INDEX [G, K -> HASHABLE]
- **Domain meaning**: Fast lookup from key value to Chain items
- **Domain rules**:
  - Key must be derivable from item (agent)
  - Updated automatically on Chain modification
  - Multiple items can share same key

### QUERY
- **Domain meaning**: Filter expression that selects Chain items
- **Domain rules**:
  - Composable (AND, OR, NOT)
  - Evaluates to true/false per item
  - Does not modify Chain

---

## 3. ACTIONS

### Chain Operations

| Action | Domain Meaning | Valid When | Result |
|--------|----------------|------------|--------|
| **extend** | Add item to Chain | Chain exists, item is valid G | Item added, indexes updated |
| **remove** | Remove item from Chain | Item exists in Chain | Item removed, indexes updated |
| **wipe_out** | Clear all items | Chain exists | Chain empty, indexes cleared |
| **item** | Get item at position | Valid position | Item returned |
| **has** | Check if item exists | Chain exists | True/False |

### Store Operations

| Action | Domain Meaning | Valid When | Result |
|--------|----------------|------------|--------|
| **open** | Prepare file for access | File exists or create mode | Store ready |
| **close** | Finish file access | Store is open | File closed |
| **save** | Write Chain to file | Store is open | Chain persisted |
| **load** | Read Chain from file | Store is open, file valid | Chain populated |

### Index Operations

| Action | Domain Meaning | Valid When | Result |
|--------|----------------|------------|--------|
| **new_index_by** | Create index on field | Chain exists, agent valid | Index available |
| **find_by** | Lookup items by key | Index exists | Items matching key |
| **remove_index** | Delete an index | Index exists | Index removed |

### Query Operations

| Action | Domain Meaning | Valid When | Result |
|--------|----------------|------------|--------|
| **where** | Start filter chain | Chain exists | Query context |
| **and_also** | Combine with AND | Query started | Combined query |
| **or_else** | Combine with OR | Query started | Combined query |
| **not_where** | Negate condition | Condition exists | Negated query |
| **execute** | Run query | Query complete | Filtered results |

### Edition Operations

| Action | Domain Meaning | Valid When | Result |
|--------|----------------|------------|--------|
| **record_addition** | Note item added | Edition active | Addition recorded |
| **record_removal** | Note item removed | Edition active | Removal recorded |
| **apply** | Replay changes | Edition valid | Chain updated |
| **save_edition** | Persist changes only | Store open | Edition saved |

---

## 4. CONSTRAINTS

### Postcondition Candidates ("must X")
- After extend: `count = old count + 1`
- After remove: `count = old count - 1`
- After wipe_out: `is_empty`
- After save: `file exists and is valid`
- After load: `count matches saved count`
- After new_index_by: `has_index (field_name)`

### Precondition Candidates ("cannot X", "never X")
- extend: `item /= Void` (cannot add Void)
- remove: `has (item)` (cannot remove non-member)
- item (i): `valid_index (i)` (cannot access invalid position)
- save: `store.is_open` (cannot save to closed store)
- load: `store.is_open` (cannot load from closed store)
- find_by: `has_index (field)` (cannot query missing index)

### Invariant Candidates ("always X")
- `count >= 0` (count always non-negative)
- `is_empty = (count = 0)` (is_empty consistent with count)
- Indexes always synchronized with Chain content
- If not is_open then no reads/writes possible

---

## 5. RELATIONSHIPS

| Relationship | Type | Domain Justification |
|--------------|------|----------------------|
| CHAIN → PERSISTABLE | uses (generic) | Chain stores Persistables |
| CHAIN → INDEX | composition | Chain owns its indexes |
| CHAIN → STORE | uses | Chain uses Store for I/O |
| INDEX → CHAIN | references | Index points to Chain items |
| QUERY → CHAIN | operates on | Query filters Chain |
| EDITION → CHAIN | belongs to | Edition tracks Chain changes |
| STORE → FILE | wraps | Store abstracts file I/O |

### Inheritance Hierarchy (proposed)

```
PERSISTABLE (deferred)
├── PERSISTABLE_OBJECT (basic)
└── PERSISTABLE_RECORD (field-based)

CHAIN [G]
├── BASIC_CHAIN [G] (simple, no editions)
└── RECOVERABLE_CHAIN [G] (with editions)

STORE
├── BASIC_STORE (simple file I/O)
└── ENCRYPTED_STORE (AES encryption)
```

---

## 6. QUERIES vs COMMANDS

### Queries (returns value, no state change)

| Feature | Returns |
|---------|---------|
| count | INTEGER |
| is_empty | BOOLEAN |
| has (item) | BOOLEAN |
| item (i) | G |
| first | G |
| last | G |
| find_by (key) | LIST [G] |
| is_open | BOOLEAN |
| has_index (name) | BOOLEAN |

### Commands (modifies state, no return)

| Feature | Effect |
|---------|--------|
| extend (item) | Adds item |
| remove (item) | Removes item |
| wipe_out | Clears all |
| open | Opens store |
| close | Closes store |
| save | Writes to file |
| load | Reads from file |
| new_index_by (agent) | Creates index |

---

## SPECIFICATION QUALITY CHECKS

- [x] Every domain concept has clear definition
- [x] Every domain rule captured
- [x] Every feature has domain meaning
- [x] Ambiguities explicitly flagged (see below)

### UNCLEAR Items Requiring Resolution

1. **UNCLEAR**: Should encryption be built-in or separate library?
   - Decision: Defer encryption to Phase 2 or simple_encoding integration

2. **UNCLEAR**: Should Pyxis export be included?
   - Decision: Defer Pyxis, focus on CSV and JSON export

3. **UNCLEAR**: How deep should SCOOP integration go?
   - Decision: Design all classes to be SCOOP-safe from start

4. **UNCLEAR**: Version migration mechanism?
   - Decision: Start simple (version number in header), defer complex migration

---

## Summary

### Classes to Implement (Phase 1 - Core)

| Class | Priority | Description |
|-------|----------|-------------|
| PERSISTABLE | HIGH | Deferred base for storable objects |
| SP_CHAIN | HIGH | Generic typed chain (main class) |
| SP_STORE | HIGH | File persistence |
| SP_INDEX | MEDIUM | Field-based indexing |
| SP_QUERY | MEDIUM | Filter expressions |
| SP_EDITION | LOW | Incremental change tracking |

### Classes to Defer (Phase 2+)

| Class | Reason |
|-------|--------|
| SP_ENCRYPTED_STORE | Integrate with simple_encoding |
| SP_RECOVERABLE_CHAIN | After basic chain works |
| SP_CSV_EXPORTER | After core persistence |
| SP_JSON_EXPORTER | After core persistence |

---

*Step 01 Complete - Proceed to 02-DEFINE-CLASS-STRUCTURE*
