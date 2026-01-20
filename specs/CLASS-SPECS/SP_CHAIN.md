# CLASS SPECIFICATION: SP_CHAIN

## Identity
- **Role:** ENGINE (Abstract)
- **Domain Concept:** Persistable collection

## Purpose

This class represents: An ordered collection of storable objects with file persistence
This class is responsible for: Managing collection operations, cursor movement, file I/O
This class guarantees: Reader/writer availability, valid deletion count

## Creation

### CREATION: make
- **Signature:** ()
- **Purpose:** Create empty chain
- **Preconditions:** NONE
- **Postconditions:**
  - no_deleted: deleted_count = 0
  - no_stored_version: stored_version = 0
  - reader_created: reader /= Void
  - writer_created: writer /= Void
- **Initial State:**
  - file_path = empty PATH
  - reader = new SP_READER(4096)
  - writer = new SP_WRITER(4096)
  - deleted_count = 0
  - stored_version = 0

### CREATION: make_from_file
- **Signature:** (a_path: PATH)
- **Purpose:** Create chain and load contents from file
- **Preconditions:**
  - path_attached: a_path /= Void
- **Postconditions:**
  - path_set: file_path = a_path
- **Initial State:** As make, then populated from file

## Queries (Deferred)

### QUERY: item
- **Signature:** () → G
- **Purpose:** Access current item at cursor position
- **Preconditions:** (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: i_th
- **Signature:** (i: INTEGER) → G
- **Purpose:** Access item at specific index
- **Preconditions:** (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: first
- **Signature:** () → G
- **Purpose:** Access first item in chain
- **Preconditions:** (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: last
- **Signature:** () → G
- **Purpose:** Access last item in chain
- **Preconditions:** (implementation-specific)
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: software_version (deferred)
- **Signature:** () → NATURAL
- **Purpose:** Report current software version for data format
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: count (deferred)
- **Signature:** () → INTEGER
- **Purpose:** Report total number of items
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: has (deferred)
- **Signature:** (v: G) → BOOLEAN
- **Purpose:** Check if chain contains specific item
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: index (deferred)
- **Signature:** () → INTEGER
- **Purpose:** Report current cursor position
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: after (deferred)
- **Signature:** () → BOOLEAN
- **Purpose:** Check if cursor is past last item
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: before (deferred)
- **Signature:** () → BOOLEAN
- **Purpose:** Check if cursor is before first item
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

## Queries (Effective)

### QUERY: file_path
- **Signature:** () → PATH
- **Purpose:** Access storage file path
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: stored_version
- **Signature:** () → NATURAL
- **Purpose:** Report version from loaded file
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: deleted_count
- **Signature:** () → INTEGER
- **Purpose:** Report number of soft-deleted items
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: active_count
- **Signature:** () → INTEGER
- **Purpose:** Report count minus deleted count
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = count - deleted_count)
- **Pure:** YES

### QUERY: is_empty
- **Signature:** () → BOOLEAN
- **Purpose:** Check if chain has no items
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = count = 0)
- **Pure:** YES

### QUERY: is_open
- **Signature:** () → BOOLEAN
- **Purpose:** Check if storage file is currently open
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: valid_index
- **Signature:** (i: INTEGER) → BOOLEAN
- **Purpose:** Check if index is within valid range
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = i >= 1 and i <= count)
- **Pure:** YES

### QUERY: has_version_mismatch
- **Signature:** () → BOOLEAN
- **Purpose:** Check if loaded data version differs from software
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = stored_version /= software_version)
- **Pure:** YES

## Commands (Deferred)

### COMMAND: start
- **Purpose:** Move cursor to first position
- **Deferred**

### COMMAND: finish
- **Purpose:** Move cursor to last position
- **Deferred**

### COMMAND: forth
- **Purpose:** Move cursor to next position
- **Deferred**

### COMMAND: back
- **Purpose:** Move cursor to previous position
- **Deferred**

### COMMAND: go_i_th
- **Signature:** (i: INTEGER)
- **Purpose:** Move cursor to specific position
- **Preconditions:**
  - valid_index: i >= 0 and i <= count + 1
- **Deferred**

### COMMAND: extend
- **Signature:** (v: G)
- **Purpose:** Add item to end of chain
- **Deferred**

### COMMAND: put
- **Signature:** (v: G)
- **Purpose:** Replace current item
- **Deferred**

### COMMAND: force
- **Signature:** (v: G)
- **Purpose:** Add item, extending capacity if needed
- **Deferred**

### COMMAND: remove
- **Purpose:** Remove current item
- **Deferred**

### COMMAND: prune
- **Signature:** (v: G)
- **Purpose:** Remove first occurrence of item
- **Deferred**

### COMMAND: wipe_out
- **Purpose:** Remove all items
- **Deferred**

## Commands (Effective)

### COMMAND: mark_deleted
- **Signature:** ()
- **Purpose:** Soft-delete current item
- **Preconditions:**
  - not_empty: not is_empty
  - valid_cursor: not before and not after
- **Postconditions:**
  - deleted_count_increased: deleted_count = old deleted_count + 1
  - item_deleted: item.is_deleted
- **Modifies:** deleted_count, current item's is_deleted

### COMMAND: compact
- **Signature:** ()
- **Purpose:** Physically remove all soft-deleted items
- **Preconditions:** NONE
- **Postconditions:**
  - no_deleted_items: deleted_count = 0
- **Modifies:** items collection, deleted_count

### COMMAND: save
- **Signature:** ()
- **Purpose:** Save chain to file_path
- **Preconditions:** NONE
- **Postconditions:** NONE (gap)
- **Modifies:** File (external)

### COMMAND: save_as
- **Signature:** (a_path: PATH)
- **Purpose:** Save chain to specified path
- **Preconditions:**
  - path_attached: a_path /= Void
- **Postconditions:**
  - path_updated: file_path = a_path
- **Modifies:** File (external), file_path

### COMMAND: load
- **Signature:** ()
- **Purpose:** Load chain contents from file_path
- **Preconditions:** NONE
- **Postconditions:** NONE (gap)
- **Modifies:** All items, stored_version

### COMMAND: close
- **Signature:** ()
- **Purpose:** Close any open file handles
- **Preconditions:** NONE
- **Postconditions:**
  - not_open: not is_open
- **Modifies:** is_open

## Iteration (Deferred)

### COMMAND: do_all
- **Signature:** (action: PROCEDURE [G])
- **Preconditions:**
  - action_attached: action /= Void
- **Deferred**

### COMMAND: do_if
- **Signature:** (action: PROCEDURE [G]; test: FUNCTION [G, BOOLEAN])
- **Preconditions:**
  - action_attached: action /= Void
  - test_attached: test /= Void
- **Deferred**

### QUERY: there_exists
- **Signature:** (test: FUNCTION [G, BOOLEAN]) → BOOLEAN
- **Preconditions:**
  - test_attached: test /= Void
- **Deferred**

### QUERY: for_all
- **Signature:** (test: FUNCTION [G, BOOLEAN]) → BOOLEAN
- **Preconditions:**
  - test_attached: test /= Void
- **Deferred**

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| reader_attached | reader /= Void | Always has deserialization capability |
| writer_attached | writer /= Void | Always has serialization capability |
| deleted_count_non_negative | deleted_count >= 0 | Cannot have negative deleted count |

## Dependencies

- **Inherits:** (none)
- **Uses:** SP_STORABLE, SP_READER, SP_WRITER, PATH, RAW_FILE
- **Creates:** SP_READER, SP_WRITER, RAW_FILE, PATH

**Coupling assessment:** MEDIUM (uses several library types)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 10/31 | 32% |
| Features with postconditions | 7/31 | 23% |
| Has class invariant | YES | 3 clauses |

**Overall specification quality:** MODERATE

### Gaps Identified
- `save`: missing postcondition for file creation
- `load`: missing postcondition for items populated
- Most deferred features: contracts are implementation-specific
