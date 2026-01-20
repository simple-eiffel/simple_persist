# S05: System Constraints - simple_persist

## Invariant Collection

### SP_WRITER
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| buffer_attached | `buffer /= Void` | Buffer always exists | Null pointer dereference |
| count_non_negative | `count >= 0` | Cannot have negative bytes | Invalid state |
| count_within_capacity | `count <= capacity` | Data fits in buffer | Buffer overflow |
| capacity_positive | `capacity > 0` | Buffer has positive size | Division by zero, empty buffer |

### SP_READER
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| buffer_attached | `buffer /= Void` | Buffer always exists | Null pointer dereference |
| position_non_negative | `position >= 0` | Cannot read from negative offset | Invalid memory access |
| position_within_bounds | `position <= count` | Cannot read past valid data | Buffer overread |
| count_non_negative | `count >= 0` | Cannot have negative byte count | Invalid state |

### SP_CHAIN
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| reader_attached | `reader /= Void` | Deserialization always possible | Null pointer on load |
| writer_attached | `writer /= Void` | Serialization always possible | Null pointer on save |
| deleted_count_non_negative | `deleted_count >= 0` | Cannot have negative deleted items | Invalid count |

### SP_ARRAYED_CHAIN
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| items_attached | `items /= Void` | Storage array exists | Null pointer dereference |

### SP_HASH_INDEX
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| index_table_attached | `index_table /= Void` | Hash table exists | Null pointer dereference |
| key_extractor_attached | `key_extractor /= Void` | Key extraction possible | Null pointer on index |
| name_attached | `name /= Void` | Index identifiable | Null pointer on name access |

### SP_QUERY
| Tag | Expression | Meaning | Protects |
|-----|------------|---------|----------|
| chain_attached | `chain /= Void` | Query has target | Null pointer on execute |
| conditions_attached | `conditions /= Void` | Condition list exists | Null pointer on evaluate |
| max_results_non_negative | `max_results >= 0` | Valid limit | Invalid loop condition |
| skip_count_non_negative | `skip_count >= 0` | Valid skip count | Invalid loop condition |

---

## Constraint Categorization

### Data Integrity Rules
| Constraint | Where Enforced | Purpose |
|------------|----------------|---------|
| Buffer attached | SP_WRITER, SP_READER invariant | Serialization data always valid |
| Count non-negative | SP_WRITER, SP_READER invariant | Byte counts meaningful |
| Position bounded | SP_READER invariant | Read position valid |
| Items attached | SP_ARRAYED_CHAIN invariant | Storage always exists |
| Key extractor attached | SP_HASH_INDEX invariant | Index can derive keys |

### State Validity Rules
| Constraint | Where Enforced | Purpose |
|------------|----------------|---------|
| count <= capacity | SP_WRITER invariant | Buffer integrity |
| position <= count | SP_READER invariant | Read within data |
| deleted_count >= 0 | SP_CHAIN invariant | Deletion tracking valid |
| capacity > 0 | SP_WRITER invariant | Meaningful buffer |

### Relationship Consistency Rules
| Constraint | Where Enforced | Purpose |
|------------|----------------|---------|
| Chain has reader/writer | SP_CHAIN invariant | Serialization pair |
| Query targets chain | SP_QUERY invariant | Query has data source |
| Index has key extractor | SP_HASH_INDEX invariant | Index can function |

### Business Rules
| Constraint | Where Enforced | Purpose |
|------------|----------------|---------|
| Storable can serialize | SP_STORABLE.write_to precondition | Data persistence |
| Storable can deserialize | SP_STORABLE.read_from precondition | Data restoration |
| Deleted items excluded | SP_CHAIN.save_as, SP_QUERY.results | Soft delete semantics |

---

## Cross-Class Constraints

### RULE: Writer-Reader Symmetry
**Description:** What SP_WRITER writes, SP_READER must be able to read
**Enforced in:** SP_WRITER.put_*, SP_READER.read_*
**System property:** Serialization roundtrip integrity
```
For all T: reader.read_T = writer.put_T(value) → read value = original value
```

### RULE: Storable Serialization Contract
**Description:** SP_STORABLE descendants must write same format they read
**Enforced in:** SP_STORABLE.write_to, SP_STORABLE.read_from
**System property:** Object persistence identity
```
For storable s: s.write_to(w); s2.read_from(r from w) → s2.is_equal(s)
```

### RULE: Chain-Item Type Constraint
**Description:** Chain items must be SP_STORABLE with make_default
**Enforced in:** SP_CHAIN generic constraint
**System property:** Items can be created and persisted
```
G -> SP_STORABLE create make_default end
```

### RULE: Index Key Constraint
**Description:** Index keys must be hashable
**Enforced in:** SP_INDEX generic constraint
**System property:** Hash-based lookup possible
```
K -> HASHABLE
```

---

## Implicit Constraints (Needs Formalization)

### IMPLICIT: Cursor validity before item access
**Evidence:** SP_ARRAYED_CHAIN.item requires `not before and not after`
**Should be:** Invariant or documented protocol
**Risk:** Precondition violation crash

### IMPLICIT: File path valid before save
**Evidence:** SP_CHAIN.save_as creates file at path, no validation
**Should be:** Precondition checking path writability
**Risk:** Runtime exception on invalid path

### IMPLICIT: Reader has enough bytes
**Evidence:** SP_READER.read_* require has_more(n)
**Should be:** Caller must check before each read
**Risk:** Precondition violation, buffer overread

### IMPLICIT: String encoding compatible
**Evidence:** SP_WRITER.put_string uses v.code(i), SP_READER uses append_code
**Should be:** Documented: strings stored as UTF-32 code points
**Risk:** Encoding confusion with non-Unicode strings

### IMPLICIT: Version compatibility
**Evidence:** stored_version vs software_version exist but unused
**Should be:** Migration logic when versions differ
**Risk:** Silent data corruption on version mismatch

### IMPLICIT: Index-Chain synchronization
**Evidence:** SP_INDEX has on_extend/on_remove but chain doesn't call them
**Should be:** Chain calls index methods, or documented manual protocol
**Risk:** Index becomes stale

---

## Void Safety Rules

### SP_CHAIN.file_path
- **Detachable:** NO (attached PATH)
- **Null allowed:** Never after make
- **Must be attached:** For save/load operations
- **Note:** Starts as empty path, not Void

### SP_QUERY.comparator
- **Detachable:** YES
- **Null allowed:** When no ordering specified
- **Must be attached:** For sorting (but sorting NOT IMPLEMENTED)

### SP_STORABLE.is_deleted
- **Detachable:** NO (BOOLEAN)
- **Null allowed:** N/A (value type)
- **Initial value:** False

### SP_INDEX.first_for_key return
- **Detachable:** YES
- **Null allowed:** When key not found
- **Caller must:** Check for Void before use

### SIMPLE_PERSIST.last_error
- **Detachable:** YES
- **Null allowed:** When no error occurred
- **Must be attached:** When has_error = True

---

## Temporal Rules

### RULE: Create before use
**Before:** Object creation via make/make_from_file/make_with_capacity
**After:** Any feature call
**Enforced by:** Eiffel creation semantics

### RULE: Read file before access
**Before:** SP_READER.from_file or make_from_buffer
**After:** read_* operations
**Enforced by:** has_more preconditions (partial)

### RULE: Write before file output
**Before:** SP_WRITER.put_* operations
**After:** SP_WRITER.to_file
**Enforced by:** Convention only (gap)

### RULE: Start iteration before access
**Before:** SP_CHAIN.start
**After:** SP_CHAIN.item
**Enforced by:** before/after preconditions

### RULE: Position cursor before modification
**Before:** SP_CHAIN.start/forth/go_i_th to valid position
**After:** SP_CHAIN.put/remove
**Enforced by:** before/after preconditions

### RULE: Add to index when extending chain
**Before:** SP_CHAIN.extend(item)
**After:** SP_INDEX.on_extend(item) (if using index)
**Enforced by:** Convention only (manual call required)

---

## Constraint Gaps (Needs Contracts)

### Missing Invariants
| Class | Should have | Why |
|-------|-------------|-----|
| SIMPLE_PERSIST | `default_path /= Void` | Always has path object |
| SP_STORABLE | `byte_count >= 0` | Size always non-negative |

### Missing Preconditions
| Feature | Should have | Why |
|---------|-------------|-----|
| SP_WRITER.put_string | `v /= Void` | String must exist |
| SP_WRITER.to_file | `a_file.is_open_write` | File must be writable |
| SP_CHAIN.load | `not file_path.is_empty` | Must have path to load |
| SP_READER.read_string | Full bytes available | Currently only checks length prefix |

### Missing Postconditions
| Feature | Should have | Why |
|---------|-------------|-----|
| SIMPLE_PERSIST.set_default_path | `default_path = a_path` | State change visible |
| SP_HASH_INDEX.on_extend | `has_item(a_item)` | Item now indexed |
| SP_HASH_INDEX.wipe_out | `is_empty` | Index cleared |
| SP_QUERY.results | `Result /= Void` | Always returns list |
| SP_CHAIN.save_as | File exists | File created |

### Missing Cross-Class Contracts
| Rule | Should exist | Why |
|------|--------------|-----|
| Index-Chain integration | Chain notifies indexes | Automatic synchronization |
| Version migration | Check on load | Data compatibility |
| Error propagation | Chain errors to facade | Unified error handling |

---

**Generated:** 2026-01-20
**Workflow:** 02_spec-extraction / S05-EXTRACT-CONSTRAINTS
