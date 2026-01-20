# CLASS SPECIFICATION: SP_READER

## Identity
- **Role:** HELPER
- **Domain Concept:** Deserialization buffer

## Purpose

This class represents: A memory buffer providing deserialized values
This class is responsible for: Reading primitive values from bytes and tracking read position
This class guarantees: Buffer integrity, position bounds, non-negative metrics

## Creation

### CREATION: make
- **Signature:** (a_capacity: INTEGER)
- **Purpose:** Create empty reader with initial buffer capacity
- **Preconditions:**
  - positive_capacity: a_capacity > 0
- **Postconditions:**
  - buffer_created: buffer /= Void
  - empty: count = 0
  - at_start: position = 0
  - no_version: data_version = 0
- **Initial State:**
  - buffer = new MANAGED_POINTER(a_capacity)
  - count = 0
  - position = 0
  - data_version = 0

### CREATION: make_from_buffer
- **Signature:** (a_buffer: MANAGED_POINTER; a_count: INTEGER)
- **Purpose:** Create reader wrapping existing buffer with a_count valid bytes
- **Preconditions:**
  - valid_buffer: a_buffer /= Void
  - non_negative_count: a_count >= 0
  - valid_count: a_count <= a_buffer.count
- **Postconditions:**
  - buffer_set: buffer = a_buffer
  - count_set: count = a_count
  - at_start: position = 0
  - no_version: data_version = 0
- **Initial State:**
  - buffer = a_buffer (shared reference)
  - count = a_count
  - position = 0
  - data_version = 0

## Queries

### QUERY: buffer
- **Signature:** () → MANAGED_POINTER
- **Purpose:** Access internal byte buffer
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: position
- **Signature:** () → INTEGER
- **Purpose:** Report current read position
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: count
- **Signature:** () → INTEGER
- **Purpose:** Report number of valid bytes in buffer
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: data_version
- **Signature:** () → NATURAL
- **Purpose:** Report version of data being read (for migration)
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: is_end_of_buffer
- **Signature:** () → BOOLEAN
- **Purpose:** Check if all bytes have been read
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = position >= count)
- **Pure:** YES

### QUERY: has_more
- **Signature:** (n: INTEGER) → BOOLEAN
- **Purpose:** Check if at least n more bytes are available
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = position + n <= count)
- **Pure:** YES

### QUERY: read_integer_8
- **Signature:** () → INTEGER_8
- **Purpose:** Read 8-bit signed integer and advance position
- **Preconditions:**
  - has_bytes: has_more (1)
- **Postconditions:**
  - position_advanced: position = old position + 1
- **Pure:** NO (advances position)

### QUERY: read_integer_16
- **Signature:** () → INTEGER_16
- **Purpose:** Read 16-bit signed integer and advance position
- **Preconditions:**
  - has_bytes: has_more (2)
- **Postconditions:**
  - position_advanced: position = old position + 2
- **Pure:** NO

### QUERY: read_integer_32
- **Signature:** () → INTEGER_32
- **Purpose:** Read 32-bit signed integer and advance position
- **Preconditions:**
  - has_bytes: has_more (4)
- **Postconditions:**
  - position_advanced: position = old position + 4
- **Pure:** NO

### QUERY: read_integer_64
- **Signature:** () → INTEGER_64
- **Purpose:** Read 64-bit signed integer and advance position
- **Preconditions:**
  - has_bytes: has_more (8)
- **Postconditions:**
  - position_advanced: position = old position + 8
- **Pure:** NO

### QUERY: read_natural_8
- **Signature:** () → NATURAL_8
- **Purpose:** Read 8-bit unsigned integer and advance position
- **Preconditions:**
  - has_bytes: has_more (1)
- **Postconditions:**
  - position_advanced: position = old position + 1
- **Pure:** NO

### QUERY: read_natural_16
- **Signature:** () → NATURAL_16
- **Purpose:** Read 16-bit unsigned integer and advance position
- **Preconditions:**
  - has_bytes: has_more (2)
- **Postconditions:**
  - position_advanced: position = old position + 2
- **Pure:** NO

### QUERY: read_natural_32
- **Signature:** () → NATURAL_32
- **Purpose:** Read 32-bit unsigned integer and advance position
- **Preconditions:**
  - has_bytes: has_more (4)
- **Postconditions:**
  - position_advanced: position = old position + 4
- **Pure:** NO

### QUERY: read_natural_64
- **Signature:** () → NATURAL_64
- **Purpose:** Read 64-bit unsigned integer and advance position
- **Preconditions:**
  - has_bytes: has_more (8)
- **Postconditions:**
  - position_advanced: position = old position + 8
- **Pure:** NO

### QUERY: read_real_32
- **Signature:** () → REAL_32
- **Purpose:** Read 32-bit floating point and advance position
- **Preconditions:**
  - has_bytes: has_more (4)
- **Postconditions:**
  - position_advanced: position = old position + 4
- **Pure:** NO

### QUERY: read_real_64
- **Signature:** () → REAL_64
- **Purpose:** Read 64-bit floating point and advance position
- **Preconditions:**
  - has_bytes: has_more (8)
- **Postconditions:**
  - position_advanced: position = old position + 8
- **Pure:** NO

### QUERY: read_boolean
- **Signature:** () → BOOLEAN
- **Purpose:** Read single byte as boolean (0 = False, else True)
- **Preconditions:**
  - has_bytes: has_more (1)
- **Postconditions:**
  - position_advanced: position = old position + 1
- **Pure:** NO

### QUERY: read_character_8
- **Signature:** () → CHARACTER_8
- **Purpose:** Read 8-bit character and advance position
- **Preconditions:**
  - has_bytes: has_more (1)
- **Postconditions:**
  - position_advanced: position = old position + 1
- **Pure:** NO

### QUERY: read_string
- **Signature:** () → STRING_32
- **Purpose:** Read length-prefixed string
- **Preconditions:**
  - has_length_prefix: has_more (4)
- **Postconditions:**
  - result_attached: Result /= Void
- **Pure:** NO

### QUERY: read_bytes
- **Signature:** (n: INTEGER) → MANAGED_POINTER
- **Purpose:** Read n raw bytes into new pointer
- **Preconditions:**
  - non_negative_count: n >= 0
  - has_bytes: has_more (n)
- **Postconditions:**
  - result_attached: Result /= Void
  - result_size: Result.count = n
  - position_advanced: position = old position + n
- **Pure:** NO

## Commands

### COMMAND: reset
- **Signature:** ()
- **Purpose:** Reset position to beginning for re-reading
- **Preconditions:** NONE
- **Postconditions:**
  - at_start: position = 0
- **Modifies:** position

### COMMAND: set_data_version
- **Signature:** (v: NATURAL)
- **Purpose:** Set version of data being read (for migration logic)
- **Preconditions:** NONE
- **Postconditions:**
  - version_set: data_version = v
- **Modifies:** data_version

### COMMAND: from_file
- **Signature:** (a_file: RAW_FILE; n: INTEGER)
- **Purpose:** Load n bytes from file into buffer
- **Preconditions:**
  - file_attached: a_file /= Void
  - file_open_read: a_file.is_open_read
  - non_negative_count: n >= 0
- **Postconditions:**
  - count_set: count = n
  - at_start: position = 0
- **Modifies:** buffer contents, count, position

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| buffer_attached | buffer /= Void | Reader always has valid buffer |
| position_non_negative | position >= 0 | Cannot read from negative offset |
| position_within_bounds | position <= count | Cannot read past valid data |
| count_non_negative | count >= 0 | Cannot have negative byte count |

## Dependencies

- **Inherits:** (none)
- **Uses:** MANAGED_POINTER, RAW_FILE, STRING_32
- **Creates:** MANAGED_POINTER, STRING_32

**Coupling assessment:** LOW (only standard library)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 17/20 | 85% |
| Features with postconditions | 18/20 | 90% |
| Has class invariant | YES | 4 clauses |

**Overall specification quality:** STRONG

### Gaps Identified
- `read_string`: position postcondition missing (should show final position)
- All read_* queries: technically not "pure" since they modify position
