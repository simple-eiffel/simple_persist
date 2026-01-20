# CLASS SPECIFICATION: SP_STORABLE

## Identity
- **Role:** DATA (Abstract)
- **Domain Concept:** Persistable object interface

## Purpose

This class represents: The contract that objects must fulfill to be stored in chains
This class is responsible for: Defining serialization interface and deletion marking
This class guarantees: Objects can serialize/deserialize themselves

## Creation

### CREATION: make_default (deferred)
- **Signature:** ()
- **Purpose:** Create instance in default state (for deserialization)
- **Preconditions:** NONE
- **Postconditions:** NONE (implementation-specific)
- **Initial State:** Implementation-defined default state

## Queries

### QUERY: storage_version (deferred)
- **Signature:** () → NATURAL
- **Purpose:** Report data format version for migration support
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: is_deleted
- **Signature:** () → BOOLEAN
- **Purpose:** Check if item is marked for soft deletion
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: is_valid (deferred)
- **Signature:** () → BOOLEAN
- **Purpose:** Check if item is in valid state
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: byte_count (deferred)
- **Signature:** () → INTEGER
- **Purpose:** Report approximate serialized size in bytes
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

## Commands

### COMMAND: mark_deleted
- **Signature:** ()
- **Purpose:** Mark item as deleted (soft delete)
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should ensure is_deleted = True)
- **Modifies:** is_deleted

### COMMAND: unmark_deleted
- **Signature:** ()
- **Purpose:** Remove deletion mark
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should ensure is_deleted = False)
- **Modifies:** is_deleted

### COMMAND: write_to (deferred)
- **Signature:** (a_writer: SP_WRITER)
- **Purpose:** Serialize item state to writer buffer
- **Preconditions:**
  - writer_attached: a_writer /= Void
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** a_writer buffer contents

### COMMAND: read_from (deferred)
- **Signature:** (a_reader: SP_READER)
- **Purpose:** Deserialize item state from reader buffer
- **Preconditions:**
  - reader_attached: a_reader /= Void
- **Postconditions:** NONE (implementation-specific)
- **Modifies:** All item attributes

## Invariants

**No class invariant defined** (appropriate for deferred class)

## Dependencies

- **Inherits:** (none)
- **Uses:** SP_WRITER, SP_READER
- **Creates:** (none)

**Coupling assessment:** LOW (only internal library types)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 2/9 | 22% |
| Features with postconditions | 0/9 | 0% |
| Has class invariant | NO | - |

**Overall specification quality:** WEAK (but acceptable for deferred class)

### Gaps Identified
- `mark_deleted`: missing postcondition `is_deleted = True`
- `unmark_deleted`: missing postcondition `is_deleted = False`
- `byte_count`: could have postcondition `Result >= 0`

### Implementation Notes
Descendants must implement:
- `make_default` - creation from nothing
- `storage_version` - version identifier
- `is_valid` - validation logic
- `byte_count` - size estimation
- `write_to` - serialization
- `read_from` - deserialization
