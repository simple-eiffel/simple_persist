# S04: Feature Specifications - simple_persist

This document contains detailed behavioral specifications for key features.

---

## FEATURE SPECIFICATION: SP_CHAIN.save_as

### Signature
```eiffel
save_as (a_path: PATH)
```

### Purpose
Persist all non-deleted items to a binary file, storing version and item count in header.

### Behavior
**Algorithm:**
1. Create RAW_FILE at a_path and open for write
2. Write header: software_version (NATURAL_32), active_count (INTEGER)
3. For each item from start to finish:
   - If not deleted:
     - Reset writer buffer
     - Call item.write_to(writer)
     - Write item size (INTEGER) to file
     - Write writer buffer to file
4. Close file
5. Update file_path to a_path

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | Empty chain | Writes header with count=0, no items |
| B | All deleted | Writes header with count=0, no items |
| C | Mixed items | Writes only non-deleted items |

### Contracts
**Existing:**
```eiffel
require
  path_attached: a_path /= Void
ensure
  path_updated: file_path = a_path
```

**Recommended Additions:**
```eiffel
require
  -- none needed
ensure
  file_exists: (create {RAW_FILE}.make_with_path (a_path)).exists
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| file_path | any | a_path |
| items | unchanged | unchanged |
| writer | any state | reset |

**External Effect:** File created/overwritten at a_path

### Input Validation
| Input | Valid | Invalid |
|-------|-------|---------|
| a_path | Any attached PATH | Void (precondition violation) |

### Output Specification
No return value (command)

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Empty chain | chain.is_empty | Writes header only | None needed |
| All deleted | deleted_count = count | Writes header with 0 | Handled in loop |
| Path not writable | Invalid path | RAW_FILE exception | Not handled (gap) |

### Test Coverage
- **test_chain_extend**: Implicitly tests via save/load roundtrip (not directly)
- **UNTESTED**: Direct save_as, file format verification, error handling

---

## FEATURE SPECIFICATION: SP_CHAIN.load

### Signature
```eiffel
load
```

### Purpose
Populate chain from binary file at file_path, restoring all persisted items.

### Behavior
**Algorithm:**
1. Create RAW_FILE at file_path
2. If file exists:
   a. Open for read
   b. Read header: stored_version (NATURAL_32), count (INTEGER)
   c. Wipe out existing items
   d. For i = 1 to count (or until EOF):
      - Read item size (INTEGER)
      - Read size bytes into reader via from_file
      - Set reader.data_version to stored_version
      - Create new item via make_default
      - Call item.read_from(reader)
      - Extend chain with item
   e. Close file
3. If file doesn't exist: do nothing

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | File doesn't exist | No change to chain |
| B | File exists, empty | Chain wiped, stored_version set |
| C | File exists with items | Chain populated |
| D | Truncated file | Partial load (EOF check) |

### Contracts
**Existing:**
```eiffel
-- No preconditions
-- No postconditions
```

**Recommended Additions:**
```eiffel
require
  path_set: not file_path.is_empty
ensure
  version_set: (old (create {RAW_FILE}.make_with_path (file_path)).exists) implies stored_version >= 0
  -- Note: Full postcondition difficult due to file I/O
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| items | any | populated from file or empty |
| stored_version | any | version from file header |
| deleted_count | any | 0 (wipe_out resets) |

### Input Validation
Uses file_path attribute (no parameters)

### Output Specification
No return value (command)

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Missing file | file doesn't exist | No change | if l_file.exists check |
| Empty file | 0 bytes | Likely crash | Not protected (gap) |
| Corrupt header | Invalid version/count | Undefined | Not protected (gap) |
| Truncated data | EOF before count items | Partial load | l_file.end_of_file check |

### Test Coverage
- **test_chain_extend**: Uses make_from_file indirectly
- **UNTESTED**: File not exists, corrupt file, version mismatch

---

## FEATURE SPECIFICATION: SP_QUERY.results

### Signature
```eiffel
results: ARRAYED_LIST [G]
```

### Purpose
Execute query against chain, returning all matching non-deleted items after applying filters, skip, and limit.

### Behavior
**Algorithm:**
1. Create empty ARRAYED_LIST for results
2. Initialize l_skip = 0, l_count = 0
3. From chain.start until chain.after:
   a. Get current item
   b. If not item.is_deleted:
      - Evaluate all conditions against item
      - If match:
        - If l_skip < skip_count: increment l_skip
        - Else: extend result, increment l_count
        - If max_results > 0 and l_count >= max_results: exit loop early
   c. Move to next item (chain.forth)
4. If is_descending: reverse result list
5. Return result

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | Empty chain | Empty result |
| B | No conditions | All non-deleted items |
| C | No matches | Empty result |
| D | Skip > matches | Empty result |
| E | max_results reached | Partial result, early exit |
| F | is_descending | Reversed result |

### Contracts
**Existing:**
```eiffel
-- No contracts
```

**Recommended Additions:**
```eiffel
ensure
  result_attached: Result /= Void
  result_count_bounded: max_results > 0 implies Result.count <= max_results
  all_match_conditions: Result.for_all (agent evaluate)
  no_deleted: Result.for_all (agent (it: G): BOOLEAN do Result := not it.is_deleted end)
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| chain.cursor | any | after last or at max_results position |
| max_results | any | possibly modified (see first_result) |

**Side Effect Warning:** Modifies chain cursor position!

### Input Validation
No parameters (uses internal state)

### Output Specification
| Output | Type | Meaning |
|--------|------|---------|
| Result | ARRAYED_LIST [G] | Items matching all conditions |
| Range | 0 to (max_results or all matches) | Depends on limits |

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Empty chain | chain.is_empty | Empty result | Loop exits immediately |
| No conditions | conditions.is_empty | All non-deleted items | evaluate returns True |
| All deleted | all items.is_deleted | Empty result | Deleted check in loop |
| skip_count >= matches | Large skip | Empty result | l_skip logic |

### Test Coverage
- **test_query_basic**: Tests where condition, verifies count
- **UNTESTED**: skip, take, order_descending, multiple conditions, OR conditions

---

## FEATURE SPECIFICATION: SP_QUERY.evaluate

### Signature
```eiffel
evaluate (a_item: G): BOOLEAN
```

### Purpose
Test if item satisfies all accumulated query conditions using AND/OR combiners.

### Behavior
**Algorithm:**
1. If conditions.is_empty: return True
2. Initialize l_result = True
3. For i = 1 to conditions.count:
   a. Get condition tuple (condition, combiner)
   b. If combiner = Combiner_and:
      - l_result := l_result AND condition.item([a_item])
   c. Else (combiner = Combiner_or):
      - l_result := l_result OR condition.item([a_item])
4. Return l_result

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | No conditions | True |
| B | Single AND condition | condition result |
| C | Multiple AND | All must be true |
| D | OR after false | Can become true |
| E | AND after true | Can become false |

**Truth Table Example:**
```
Conditions: [A=AND, B=OR, C=AND]
Initial: True
After A: True AND A = A
After B: A OR B
After C: (A OR B) AND C
```

### Contracts
**Existing:**
```eiffel
-- None (private feature)
```

**Recommended Additions:**
```eiffel
-- None (private feature, contracts in public wrapper)
```

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Empty conditions | conditions.is_empty | Returns True | Explicit check |
| Single condition | One condition | Returns its result | Works naturally |
| All OR | All Combiner_or | Any true → true | Works naturally |
| First OR oddity | First condition with OR | True OR cond = True | Semantic issue! |

**Design Issue:** First condition combiner is ignored (starts with True). If first condition is OR:
- `True OR anything = True` → first condition has no effect!
- Should probably treat first condition as AND always, or start with first condition result.

### Test Coverage
- **test_query_basic**: Exercises single AND condition
- **UNTESTED**: Multiple conditions, OR combiner, negation, empty conditions

---

## FEATURE SPECIFICATION: SP_HASH_INDEX.on_extend

### Signature
```eiffel
on_extend (a_item: G)
```

### Purpose
Add item to index when added to chain, grouping by extracted key.

### Behavior
**Algorithm:**
1. Extract key from item using key_extractor
2. Look up key in index_table
3. If key exists: extend existing list with item
4. If key doesn't exist: create new list, add item, put in table

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | Key not in table | New list created with item |
| B | Key exists | Item added to existing list |

### Contracts
**Existing:**
```eiffel
require else
  item_attached: a_item /= Void
```

**Recommended Additions:**
```eiffel
ensure
  has_item: has_item (a_item)
  key_exists: has_key (key_for (a_item))
  item_count_increased: item_count = old item_count + 1
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| index_table | any | contains key → list including item |
| key_count | n | n or n+1 (if new key) |
| item_count | m | m+1 |

### Input Validation
| Input | Valid | Invalid |
|-------|-------|---------|
| a_item | Any attached G | Void (precondition) |

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| First item | Empty index | Creates first entry | Works naturally |
| Duplicate item | Same item twice | Added twice (no uniqueness) | Not protected |
| Same key | Different items, same key | Both in same list | Intended behavior |

### Test Coverage
- **test_index_basic**: Tests adding items, verifies key_count, item_count, items_for_key
- **UNTESTED**: Duplicate item handling, removing items

---

## FEATURE SPECIFICATION: SP_WRITER.put_string

### Signature
```eiffel
put_string (v: READABLE_STRING_GENERAL)
```

### Purpose
Serialize string with length prefix, encoding each character as 32-bit code point.

### Behavior
**Algorithm:**
1. Write string length as INTEGER_32 (4 bytes)
2. For each character position i from 1 to v.count:
   - Get character code at position i
   - Write as INTEGER_32 (4 bytes)

**Wire Format:**
```
[length: 4 bytes][char1: 4 bytes][char2: 4 bytes]...[charN: 4 bytes]
Total: 4 + (length * 4) bytes
```

**Code Paths:**
| Path | Condition | Outcome |
|------|-----------|---------|
| A | Empty string | Writes 4 bytes (length=0) |
| B | ASCII string | Works correctly |
| C | Unicode string | Full code points preserved |

### Contracts
**Existing:**
```eiffel
-- No preconditions (implicit: v /= Void)
-- No postconditions
```

**Recommended Additions:**
```eiffel
require
  string_attached: v /= Void
ensure
  count_increased: count = old count + 4 + v.count * 4
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| count | n | n + 4 + v.count * 4 |
| buffer | any | contains encoded string |
| capacity | c | c or larger (auto-grow) |

### Input Validation
| Input | Valid | Invalid |
|-------|-------|---------|
| v | Any READABLE_STRING_GENERAL | Void (undefined behavior) |

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Empty string | "" | Writes only length (0) | Works naturally |
| Unicode | "日本語" | Each code point as 4 bytes | Code point access |
| Very long | Huge string | Auto-grows buffer | ensure_capacity |

### Test Coverage
- **test_writer_reader_roundtrip**: Tests "Hello" string
- **UNTESTED**: Empty string, Unicode, very long strings

---

## FEATURE SPECIFICATION: SP_READER.read_string

### Signature
```eiffel
read_string: STRING_32
```

### Purpose
Deserialize length-prefixed string, reconstructing from 32-bit code points.

### Behavior
**Algorithm:**
1. Read length as INTEGER_32
2. Create empty STRING_32 with capacity = length
3. For i from 1 to length:
   - Read code point as INTEGER_32
   - Append to string via append_code
4. Return string

### Contracts
**Existing:**
```eiffel
require
  has_length_prefix: has_more (4)
ensure
  result_attached: Result /= Void
```

**Recommended Additions:**
```eiffel
require
  -- After reading length, need enough bytes for string:
  -- has_more (4 + read_integer_32 * 4)  -- Can't express easily
ensure
  -- position_advanced: position = old position + 4 + Result.count * 4
```

### State Changes
| Attribute | Before | After |
|-----------|--------|-------|
| position | p | p + 4 + length * 4 |

### Output Specification
| Output | Type | Meaning |
|--------|------|---------|
| Result | STRING_32 | Reconstructed string |
| Range | Any valid STRING_32 | Including empty |

### Edge Cases
| Edge Case | Input | Behavior | Protection |
|-----------|-------|----------|------------|
| Empty string | length=0 | Returns empty string | Works naturally |
| Truncated | Not enough bytes | Precondition violation | has_more (4) only |
| Negative length | Corrupt data | Large allocation attempt | Not protected (gap) |

### Test Coverage
- **test_writer_reader_roundtrip**: Tests "Hello" roundtrip
- **UNTESTED**: Empty string, Unicode, truncated buffer, corrupt length

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S04-EXTRACT-FEATURE-SPECS
