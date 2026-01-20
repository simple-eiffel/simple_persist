# CLASS SPECIFICATION: SP_ARRAYED_CHAIN

## Identity
- **Role:** ENGINE (Concrete)
- **Domain Concept:** Array-backed persistable collection

## Purpose

This class represents: Concrete array-backed implementation of chain storage
This class is responsible for: Managing items in ARRAYED_LIST, implementing all chain operations
This class guarantees: Items array exists, proper cursor behavior

## Creation

### CREATION: make
- **Signature:** ()
- **Purpose:** Create empty chain with default capacity
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - items_created: items /= Void
  - empty_items: items.is_empty
- **Initial State:**
  - items = new ARRAYED_LIST(10)
  - cursor_index = 0
  - (plus parent state from SP_CHAIN.make)

### CREATION: make_from_file
- **Signature:** (a_path: PATH)
- **Purpose:** Create chain and load from file
- **Preconditions:** (inherited from parent)
- **Postconditions:** (inherited from parent)
- **Initial State:** As make, then populated from file

### CREATION: make_with_capacity
- **Signature:** (n: INTEGER)
- **Purpose:** Create with specific initial capacity
- **Preconditions:**
  - positive_capacity: n > 0
- **Postconditions:**
  - capacity_set: items.capacity >= n
- **Initial State:**
  - items = new ARRAYED_LIST(10) grown to n
  - cursor_index = 0

## Queries

### QUERY: item
- **Signature:** () → G
- **Purpose:** Access current item at cursor
- **Preconditions (require else):**
  - not_empty: not is_empty
  - valid_cursor: not before and not after
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: i_th
- **Signature:** (i: INTEGER) → G
- **Purpose:** Access item at index
- **Preconditions (require else):**
  - valid_index: valid_index (i)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: first
- **Signature:** () → G
- **Purpose:** Access first item
- **Preconditions (require else):**
  - not_empty: not is_empty
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: last
- **Signature:** () → G
- **Purpose:** Access last item
- **Preconditions (require else):**
  - not_empty: not is_empty
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: software_version
- **Signature:** () → NATURAL
- **Purpose:** Report software version (currently 1)
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = 1)
- **Pure:** YES

### QUERY: count
- **Signature:** () → INTEGER
- **Purpose:** Report number of items
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = items.count)
- **Pure:** YES

### QUERY: has
- **Signature:** (v: G) → BOOLEAN
- **Purpose:** Check if chain contains item
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: index
- **Signature:** () → INTEGER
- **Purpose:** Report current cursor position
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = cursor_index)
- **Pure:** YES

### QUERY: after
- **Signature:** () → BOOLEAN
- **Purpose:** Is cursor past last item?
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = cursor_index > items.count)
- **Pure:** YES

### QUERY: before
- **Signature:** () → BOOLEAN
- **Purpose:** Is cursor before first item?
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = cursor_index < 1)
- **Pure:** YES

## Commands

### COMMAND: start
- **Signature:** ()
- **Purpose:** Move cursor to first position
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - at_first: index = 1
- **Modifies:** cursor_index

### COMMAND: finish
- **Signature:** ()
- **Purpose:** Move cursor to last position
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - at_last: index = count
- **Modifies:** cursor_index

### COMMAND: forth
- **Signature:** ()
- **Purpose:** Move cursor forward one position
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - index_advanced: index = old index + 1
- **Modifies:** cursor_index

### COMMAND: back
- **Signature:** ()
- **Purpose:** Move cursor backward one position
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - index_retreated: index = old index - 1
- **Modifies:** cursor_index

### COMMAND: go_i_th
- **Signature:** (i: INTEGER)
- **Purpose:** Move cursor to specific position
- **Preconditions (require else):**
  - valid_index: i >= 0 and i <= count + 1
- **Postconditions (ensure then):**
  - index_set: index = i
- **Modifies:** cursor_index

### COMMAND: extend
- **Signature:** (v: G)
- **Purpose:** Add item to end
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - count_increased: count = old count + 1
  - item_added: last = v
- **Modifies:** items

### COMMAND: put
- **Signature:** (v: G)
- **Purpose:** Replace current item
- **Preconditions (require else):**
  - not_empty: not is_empty
  - valid_cursor: not before and not after
- **Postconditions (ensure then):**
  - item_replaced: item = v
  - count_unchanged: count = old count
- **Modifies:** items[cursor_index]

### COMMAND: force
- **Signature:** (v: G)
- **Purpose:** Add item, growing if needed
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - count_increased: count = old count + 1
- **Modifies:** items

### COMMAND: remove
- **Signature:** ()
- **Purpose:** Remove current item
- **Preconditions (require else):**
  - not_empty: not is_empty
  - valid_cursor: not before and not after
- **Postconditions (ensure then):**
  - count_decreased: count = old count - 1
- **Modifies:** items, cursor_index potentially

### COMMAND: prune
- **Signature:** (v: G)
- **Purpose:** Remove first occurrence of v
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should specify result)
- **Modifies:** items

### COMMAND: wipe_out
- **Signature:** ()
- **Purpose:** Remove all items
- **Preconditions:** NONE
- **Postconditions (ensure then):**
  - empty: is_empty
  - no_deleted: deleted_count = 0
- **Modifies:** items, cursor_index, deleted_count

## Iteration

### COMMAND: do_all
- **Signature:** (action: PROCEDURE [G])
- **Purpose:** Apply action to all items
- **Preconditions:** (inherited)
- **Postconditions:** NONE
- **Modifies:** (depends on action)

### COMMAND: do_if
- **Signature:** (action: PROCEDURE [G]; test: FUNCTION [G, BOOLEAN])
- **Purpose:** Apply action to items satisfying test
- **Preconditions:** (inherited)
- **Postconditions:** NONE
- **Modifies:** (depends on action)

### QUERY: there_exists
- **Signature:** (test: FUNCTION [G, BOOLEAN]) → BOOLEAN
- **Purpose:** Does any item satisfy test?
- **Preconditions:** (inherited)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: for_all
- **Signature:** (test: FUNCTION [G, BOOLEAN]) → BOOLEAN
- **Purpose:** Do all items satisfy test?
- **Preconditions:** (inherited)
- **Postconditions:** NONE
- **Pure:** YES

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| items_attached | items /= Void | Storage array always exists |

(Plus inherited invariants from SP_CHAIN)

## Dependencies

- **Inherits:** SP_CHAIN [G]
- **Uses:** ARRAYED_LIST [G]
- **Creates:** ARRAYED_LIST [G]

**Coupling assessment:** LOW (standard library + parent)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 7/21 | 33% |
| Features with postconditions | 14/21 | 67% |
| Has class invariant | YES | 1 clause (+ inherited) |

**Overall specification quality:** MODERATE

### Gaps Identified
- `prune`: missing postcondition for removal result
- `do_all`, `do_if`: no postconditions (hard to specify)
- `there_exists`, `for_all`: missing result postconditions
