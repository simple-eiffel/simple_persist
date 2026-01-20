# CLASS SPECIFICATION: SP_WRITER

## Identity
- **Role:** HELPER
- **Domain Concept:** Serialization buffer

## Purpose

This class represents: A memory buffer that accumulates serialized bytes
This class is responsible for: Converting primitive values to bytes and managing buffer growth
This class guarantees: Buffer integrity, count/capacity consistency, non-negative metrics

## Creation

### CREATION: make
- **Signature:** (a_capacity: INTEGER)
- **Purpose:** Create writer with initial buffer capacity
- **Preconditions:**
  - positive_capacity: a_capacity > 0
- **Postconditions:**
  - capacity_set: capacity = a_capacity
  - empty: count = 0
  - buffer_created: buffer /= Void
- **Initial State:**
  - buffer = new MANAGED_POINTER(a_capacity)
  - capacity = a_capacity
  - count = 0

## Queries

### QUERY: buffer
- **Signature:** () → MANAGED_POINTER
- **Purpose:** Access internal byte buffer (for external use like file output)
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: count
- **Signature:** () → INTEGER
- **Purpose:** Report number of bytes written
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: capacity
- **Signature:** () → INTEGER
- **Purpose:** Report current buffer capacity
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: is_full
- **Signature:** () → BOOLEAN
- **Purpose:** Check if buffer is at capacity
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = count >= capacity)
- **Pure:** YES

## Commands

### COMMAND: put_integer_8
- **Signature:** (v: INTEGER_8)
- **Purpose:** Write 8-bit signed integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 1
- **Modifies:** buffer contents, count

### COMMAND: put_integer_16
- **Signature:** (v: INTEGER_16)
- **Purpose:** Write 16-bit signed integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 2
- **Modifies:** buffer contents, count

### COMMAND: put_integer_32
- **Signature:** (v: INTEGER_32)
- **Purpose:** Write 32-bit signed integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 4
- **Modifies:** buffer contents, count

### COMMAND: put_integer_64
- **Signature:** (v: INTEGER_64)
- **Purpose:** Write 64-bit signed integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 8
- **Modifies:** buffer contents, count

### COMMAND: put_natural_8
- **Signature:** (v: NATURAL_8)
- **Purpose:** Write 8-bit unsigned integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 1
- **Modifies:** buffer contents, count

### COMMAND: put_natural_16
- **Signature:** (v: NATURAL_16)
- **Purpose:** Write 16-bit unsigned integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 2
- **Modifies:** buffer contents, count

### COMMAND: put_natural_32
- **Signature:** (v: NATURAL_32)
- **Purpose:** Write 32-bit unsigned integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 4
- **Modifies:** buffer contents, count

### COMMAND: put_natural_64
- **Signature:** (v: NATURAL_64)
- **Purpose:** Write 64-bit unsigned integer to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 8
- **Modifies:** buffer contents, count

### COMMAND: put_real_32
- **Signature:** (v: REAL_32)
- **Purpose:** Write 32-bit floating point to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 4
- **Modifies:** buffer contents, count

### COMMAND: put_real_64
- **Signature:** (v: REAL_64)
- **Purpose:** Write 64-bit floating point to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 8
- **Modifies:** buffer contents, count

### COMMAND: put_boolean
- **Signature:** (v: BOOLEAN)
- **Purpose:** Write boolean as single byte (0 or 1)
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 1
- **Modifies:** buffer contents, count

### COMMAND: put_character_8
- **Signature:** (v: CHARACTER_8)
- **Purpose:** Write 8-bit character to buffer
- **Preconditions:** NONE (auto-grows)
- **Postconditions:**
  - count_increased: count = old count + 1
- **Modifies:** buffer contents, count

### COMMAND: put_string
- **Signature:** (v: READABLE_STRING_GENERAL)
- **Purpose:** Write string with length prefix (4 bytes per code point)
- **Preconditions:** NONE (implied: v /= Void)
- **Postconditions:** NONE (gap - should specify count change)
- **Modifies:** buffer contents, count

### COMMAND: put_bytes
- **Signature:** (v: MANAGED_POINTER; n: INTEGER)
- **Purpose:** Write n raw bytes from source pointer
- **Preconditions:**
  - valid_pointer: v /= Void
  - non_negative_count: n >= 0
  - valid_source_size: n <= v.count
- **Postconditions:**
  - count_increased: count = old count + n
- **Modifies:** buffer contents, count

### COMMAND: reset
- **Signature:** ()
- **Purpose:** Reset buffer for reuse (count = 0, buffer contents undefined)
- **Preconditions:** NONE
- **Postconditions:**
  - empty: count = 0
- **Modifies:** count

### COMMAND: grow
- **Signature:** (a_min_capacity: INTEGER)
- **Purpose:** Ensure capacity is at least a_min_capacity
- **Preconditions:** NONE
- **Postconditions:**
  - capacity_sufficient: capacity >= a_min_capacity
  - count_unchanged: count = old count
- **Modifies:** buffer (may reallocate), capacity

### COMMAND: to_file
- **Signature:** (a_file: RAW_FILE)
- **Purpose:** Write buffer contents to open file
- **Preconditions:** NONE (gap - should require file open for write)
- **Postconditions:** NONE (gap)
- **Modifies:** File (external)

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| buffer_attached | buffer /= Void | Writer always has valid buffer |
| count_non_negative | count >= 0 | Cannot have negative bytes |
| count_within_capacity | count <= capacity | Written bytes fit in buffer |
| capacity_positive | capacity > 0 | Buffer always has positive size |

## Dependencies

- **Inherits:** (none)
- **Uses:** MANAGED_POINTER, RAW_FILE, READABLE_STRING_GENERAL
- **Creates:** MANAGED_POINTER

**Coupling assessment:** LOW (only standard library)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 2/18 | 11% |
| Features with postconditions | 15/18 | 83% |
| Has class invariant | YES | 4 clauses |

**Overall specification quality:** MODERATE

### Gaps Identified
- `put_string`: missing postcondition for count change
- `to_file`: missing precondition for file state, missing postcondition
- Implicit precondition for all puts: string argument should be attached
