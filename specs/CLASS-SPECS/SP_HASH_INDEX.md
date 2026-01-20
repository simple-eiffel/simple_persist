# CLASS SPECIFICATION: SP_HASH_INDEX

## Identity
- **Role:** HELPER (Concrete)
- **Domain Concept:** Hash-based chain index

## Purpose

This class represents: A hash table index mapping keys to lists of items
This class is responsible for: Fast O(1) average lookup of items by key value
This class guarantees: Table exists, key extractor exists, name exists

## Creation

### CREATION: make
- **Signature:** (a_name: READABLE_STRING_GENERAL; a_key_extractor: FUNCTION [G, K])
- **Purpose:** Create index with name and key extraction agent
- **Preconditions:**
  - name_attached: a_name /= Void
  - name_not_empty: not a_name.is_empty
  - key_extractor_attached: a_key_extractor /= Void
- **Postconditions:** NONE (gap)
- **Initial State:**
  - name = a_name
  - key_extractor = a_key_extractor
  - index_table = new HASH_TABLE(100)

## Queries

### QUERY: name
- **Signature:** () → READABLE_STRING_GENERAL
- **Purpose:** Return identifying name
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: key_extractor
- **Signature:** () → FUNCTION [G, K]
- **Purpose:** Return agent that extracts key from item
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: items_for_key
- **Signature:** (a_key: K) → LIST [G]
- **Purpose:** Return all items with given key
- **Preconditions (require else):**
  - key_attached: a_key /= Void
- **Postconditions:** NONE (gap - should guarantee Result /= Void)
- **Pure:** YES
- **Note:** Returns empty list if key not found

### QUERY: first_for_key
- **Signature:** (a_key: K) → detachable G
- **Purpose:** Return first item with key, or Void
- **Preconditions (require else):**
  - key_attached: a_key /= Void
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: key_count
- **Signature:** () → INTEGER
- **Purpose:** Return number of distinct keys
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = index_table.count)
- **Pure:** YES

### QUERY: item_count
- **Signature:** () → INTEGER
- **Purpose:** Return total indexed items (sum of all lists)
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: has_key
- **Signature:** (a_key: K) → BOOLEAN
- **Purpose:** Check if any item has this key
- **Preconditions (require else):**
  - key_attached: a_key /= Void
- **Postconditions:** NONE (implicit: Result = index_table.has(a_key))
- **Pure:** YES

### QUERY: has_item
- **Signature:** (a_item: G) → BOOLEAN
- **Purpose:** Check if item is in index
- **Preconditions (require else):**
  - item_attached: a_item /= Void
- **Postconditions:** NONE
- **Pure:** YES

## Commands

### COMMAND: on_extend
- **Signature:** (a_item: G)
- **Purpose:** Add item to index when added to chain
- **Preconditions (require else):**
  - item_attached: a_item /= Void
- **Postconditions:** NONE (gap - should ensure has_item(a_item))
- **Modifies:** index_table
- **Behavior:** Extracts key, adds to existing list or creates new

### COMMAND: on_remove
- **Signature:** (a_item: G)
- **Purpose:** Remove item from index when removed from chain
- **Preconditions (require else):**
  - item_attached: a_item /= Void
- **Postconditions:** NONE (gap - should ensure not has_item(a_item))
- **Modifies:** index_table

### COMMAND: on_replace
- **Signature:** (old_item, new_item: G)
- **Purpose:** Update index when item replaced
- **Preconditions (require else):**
  - old_item_attached: old_item /= Void
  - new_item_attached: new_item /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** index_table
- **Behavior:** Removes old_item, adds new_item

### COMMAND: on_delete
- **Signature:** (a_item: G)
- **Purpose:** Remove item from index when soft-deleted
- **Preconditions (require else):**
  - item_attached: a_item /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** index_table

### COMMAND: wipe_out
- **Signature:** ()
- **Purpose:** Clear all index entries
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should ensure is_empty)
- **Modifies:** index_table

### COMMAND: remove_item
- **Signature:** (a_item: G)
- **Purpose:** Remove item from its key's list
- **Preconditions (require else):**
  - item_attached: a_item /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** index_table
- **Behavior:** Removes from list, removes key if list becomes empty

## Implementation Details

### key_for (private)
- **Signature:** (a_item: G) → K
- **Purpose:** Extract key from item using key_extractor agent
- **Implementation:** `Result := key_extractor.item ([a_item])`

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| index_table_attached | index_table /= Void | Hash table always exists |
| key_extractor_attached | key_extractor /= Void | Key extraction always possible |
| name_attached | name /= Void | Index always identifiable |

## Dependencies

- **Inherits:** SP_INDEX [G, K]
- **Uses:** HASH_TABLE [ARRAYED_LIST [G], K], FUNCTION [G, K], ARRAYED_LIST [G]
- **Creates:** HASH_TABLE, ARRAYED_LIST

**Coupling assessment:** LOW (standard library + parent)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 10/13 | 77% |
| Features with postconditions | 0/13 | 0% |
| Has class invariant | YES | 3 clauses |

**Overall specification quality:** MODERATE

### Gaps Identified
- `make`: missing postcondition for state initialization
- `items_for_key`: missing postcondition `Result /= Void`
- `on_extend`: missing postcondition `has_item(a_item)`
- `on_remove`: missing postcondition `not has_item(a_item)`
- `wipe_out`: missing postcondition `is_empty`
- All mutation commands lack state change postconditions
