# CLASS SPECIFICATION: SP_INDEX

## Identity
- **Role:** HELPER (Abstract)
- **Domain Concept:** Chain index interface

## Purpose

This class represents: The contract for fast lookup structures on chain items
This class is responsible for: Defining index operations for key-based item retrieval
This class guarantees: Consistent interface for all index implementations

## Creation

No creation procedures (deferred class)

## Queries (Deferred)

### QUERY: name
- **Signature:** () → READABLE_STRING_GENERAL
- **Purpose:** Return identifying name of this index
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: items_for_key
- **Signature:** (a_key: K) → LIST [G]
- **Purpose:** Return all items matching the given key
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Pure:** YES

### QUERY: first_for_key
- **Signature:** (a_key: K) → detachable G
- **Purpose:** Return first item matching key, or Void
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Pure:** YES

### QUERY: key_count
- **Signature:** () → INTEGER
- **Purpose:** Return number of distinct keys
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: item_count
- **Signature:** () → INTEGER
- **Purpose:** Return total number of indexed items
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: has_key
- **Signature:** (a_key: K) → BOOLEAN
- **Purpose:** Check if any item has this key
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: has_item
- **Signature:** (a_item: G) → BOOLEAN
- **Purpose:** Check if item is in the index
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

## Queries (Effective)

### QUERY: is_empty
- **Signature:** () → BOOLEAN
- **Purpose:** Check if index has no items
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = item_count = 0)
- **Pure:** YES

## Commands (Deferred)

### COMMAND: on_extend
- **Signature:** (a_item: G)
- **Purpose:** Handle item added to chain (add to index)
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** index entries

### COMMAND: on_remove
- **Signature:** (a_item: G)
- **Purpose:** Handle item removed from chain
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** index entries

### COMMAND: on_replace
- **Signature:** (old_item, new_item: G)
- **Purpose:** Handle item replaced in chain
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** index entries

### COMMAND: on_delete
- **Signature:** (a_item: G)
- **Purpose:** Handle item marked as deleted
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** index entries

### COMMAND: wipe_out
- **Signature:** ()
- **Purpose:** Remove all index entries
- **Preconditions:** NONE
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** All index entries

### COMMAND: remove_item
- **Signature:** (a_item: G)
- **Purpose:** Remove specific item from index
- **Preconditions:** NONE (implementation-specific)
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** index entries for item's key

## Invariants

**No class invariant defined** (appropriate for deferred class)

## Dependencies

- **Inherits:** (none)
- **Uses:** SP_STORABLE [G], HASHABLE [K], LIST [G]
- **Creates:** (none)

**Coupling assessment:** LOW

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 0/11 | 0% |
| Features with postconditions | 0/11 | 0% |
| Has class invariant | NO | - |

**Overall specification quality:** WEAK (but appropriate for interface)

### Gaps Identified
- All features lack contracts (to be defined by implementations)
- Could have postcondition on `is_empty`: `Result = (item_count = 0)`

### Generic Constraints
- G -> SP_STORABLE: Items must be storable objects
- K -> HASHABLE: Keys must be hashable for lookup
