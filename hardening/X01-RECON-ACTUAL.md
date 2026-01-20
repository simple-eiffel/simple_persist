# X01: Reconnaissance - simple_persist

## Date: 2026-01-20

## Baseline Verification

### Compilation
```
Eiffel Compilation Manager
Version 25.02.9.8732 - win64

Degree 6: Examining System
Degree 5: Parsing Classes
Degree 4: Analyzing Inheritance
Degree 3: Checking Types
Degree 2: Generating Byte Code
Freezing System Changes
Degree -1: Generating Code
System Recompiled.
Preparing C compilation using Microsoft Visual Studio 2022 VC++ (17.0)...
[... C compilation files ...]
C compilation completed
```

### Test Run
```
simple_persist tests
  test_create_chain: PASS
  test_facade_creation: PASS
  test_writer_reader_roundtrip: PASS
  test_chain_extend: PASS
  test_chain_cursor: PASS
  test_chain_remove: PASS
  test_query_basic: PASS
  test_index_basic: PASS
All tests passed
```

### Baseline Status
- Compiles: YES
- Tests: 8 pass, 0 fail
- Warnings: 0

## Source Files

| File | Class | Lines | Features | Contracts |
|------|-------|-------|----------|-----------|
| simple_persist.e | SIMPLE_PERSIST | 90 | 9 | 3 pre, 0 post, 0 inv |
| sp_chain.e | SP_CHAIN | 347 | 31 | 10 pre, 7 post, 3 inv |
| sp_arrayed_chain.e | SP_ARRAYED_CHAIN | 271 | 21 | 7 pre, 14 post, 1 inv |
| sp_writer.e | SP_WRITER | 251 | 18 | 2 pre, 15 post, 4 inv |
| sp_reader.e | SP_READER | 290 | 20 | 17 pre, 18 post, 4 inv |
| sp_storable.e | SP_STORABLE | 69 | 9 | 2 pre, 0 post, 0 inv |
| sp_index.e | SP_INDEX | 91 | 11 | 0 pre, 0 post, 0 inv |
| sp_hash_index.e | SP_HASH_INDEX | 193 | 13 | 10 pre, 0 post, 3 inv |
| sp_query.e | SP_QUERY | 252 | 15 | 7 pre, 0 post, 4 inv |

**Total:** 9 source files, 147 features

## Public API Analysis

### SIMPLE_PERSIST (Facade)

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | - | 0 | 0 | L |
| file_exists | query | PATH | 1 | 0 | M |
| delete_file | command | PATH | 1 | 0 | M |
| set_default_path | command | PATH | 1 | 0 | M |
| clear_error | command | - | 0 | 0 | L |
| version | query | - | 0 | 0 | L |
| default_path | query | - | 0 | 0 | L |
| last_error | query | - | 0 | 0 | L |
| has_error | query | - | 0 | 0 | L |

### SP_WRITER

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | INTEGER | 1 | 3 | L |
| put_integer_* | command | various | 0 | 1 | M |
| put_natural_* | command | various | 0 | 1 | M |
| put_real_* | command | various | 0 | 1 | M |
| put_boolean | command | BOOLEAN | 0 | 1 | L |
| put_character_8 | command | CHAR | 0 | 1 | L |
| put_string | command | STRING | 0 | 0 | **H** |
| put_bytes | command | POINTER, INT | 3 | 1 | M |
| reset | command | - | 0 | 1 | L |
| grow | command | INTEGER | 0 | 2 | L |
| to_file | command | RAW_FILE | 0 | 0 | **H** |

### SP_READER

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | INTEGER | 1 | 4 | L |
| make_from_buffer | creation | POINTER, INT | 3 | 4 | L |
| read_* | query | - | 1 | 1-3 | L |
| read_string | query | - | 1 | 1 | M |
| read_bytes | query | INTEGER | 2 | 3 | L |
| reset | command | - | 0 | 1 | L |
| set_data_version | command | NATURAL | 0 | 1 | L |
| from_file | command | RAW_FILE, INT | 3 | 2 | M |

### SP_CHAIN

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | - | 0 | 4 | L |
| make_from_file | creation | PATH | 1 | 1 | M |
| save | command | - | 0 | 0 | **H** |
| save_as | command | PATH | 1 | 1 | M |
| load | command | - | 0 | 0 | **H** |
| mark_deleted | command | - | 2 | 2 | L |
| compact | command | - | 0 | 1 | L |

### SP_QUERY

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | SP_CHAIN | 1 | 0 | M |
| where | command | FUNCTION | 1 | 0 | M |
| and_where | command | FUNCTION | 1 | 0 | M |
| or_where | command | FUNCTION | 1 | 0 | M |
| not_where | command | FUNCTION | 1 | 0 | M |
| take | command | INTEGER | 1 | 0 | M |
| skip | command | INTEGER | 1 | 0 | M |
| order_by | command | FUNCTION | 1 | 0 | M |
| results | query | - | 0 | 0 | **H** |

### SP_HASH_INDEX

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | STRING, FUNCTION | 3 | 0 | M |
| items_for_key | query | K | 1 | 0 | M |
| first_for_key | query | K | 1 | 0 | M |
| on_extend | command | G | 1 | 0 | M |
| on_remove | command | G | 1 | 0 | M |
| on_replace | command | G, G | 2 | 0 | M |
| on_delete | command | G | 1 | 0 | M |
| wipe_out | command | - | 0 | 0 | M |
| remove_item | command | G | 1 | 0 | M |

## Contract Coverage Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total features | 147 | 100% |
| With preconditions | 53 | 36% |
| With postconditions | 54 | 37% |
| Classes with invariants | 6/9 | 67% |

## Attack Surface Priority

### High (Unprotected public features with external effects)
1. `SP_WRITER.put_string` - No precondition for Void check
2. `SP_WRITER.to_file` - No precondition for file state
3. `SP_CHAIN.save` - No preconditions, file I/O
4. `SP_CHAIN.load` - No preconditions, file I/O
5. `SP_QUERY.results` - No postcondition for Result /= Void

### Medium (Partial protection)
1. `SIMPLE_PERSIST.*` - Preconditions but no postconditions
2. `SP_HASH_INDEX.*` - Preconditions but no postconditions
3. `SP_QUERY.where/and_where/or_where` - No postconditions for state change
4. `SP_READER.read_string` - Only checks length prefix, not string content

### Low (Protected)
1. `SP_WRITER.put_bytes` - Full preconditions
2. `SP_READER.make_from_buffer` - Full contracts
3. `SP_ARRAYED_CHAIN.*` - Good contract coverage
4. All invariant-protected classes

## VERIFICATION CHECKPOINT

```
Compilation output: PASTED (Success)
Test output: PASTED (8/8 pass)
Source files read: 9
Attack surfaces listed: 18 (5 high, 9 medium, 4 low)
hardening/X01-RECON-ACTUAL.md: CREATED
```

---

**Generated:** 2026-01-20
**Workflow:** 07_maintenance-xtreme / X01-RECONNAISSANCE
