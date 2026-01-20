# N10: Naming Review - simple_persist

## Date: 2026-01-20

## Class Naming

| Class | Convention | Status |
|-------|------------|--------|
| SIMPLE_PERSIST | Facade class | OK |
| SP_ARRAYED_CHAIN | SP_ prefix + descriptive | OK |
| SP_CHAIN | SP_ prefix + descriptive | OK |
| SP_HASH_INDEX | SP_ prefix + descriptive | OK |
| SP_INDEX | SP_ prefix + descriptive | OK |
| SP_QUERY | SP_ prefix + descriptive | OK |
| SP_READER | SP_ prefix + descriptive | OK |
| SP_STORABLE | SP_ prefix + descriptive | OK |
| SP_WRITER | SP_ prefix + descriptive | OK |

**Result:** All class names follow Eiffel and ecosystem conventions.

## File Naming

| File | Class | Match |
|------|-------|-------|
| simple_persist.e | SIMPLE_PERSIST | YES |
| sp_arrayed_chain.e | SP_ARRAYED_CHAIN | YES |
| sp_chain.e | SP_CHAIN | YES |
| sp_hash_index.e | SP_HASH_INDEX | YES |
| sp_index.e | SP_INDEX | YES |
| sp_query.e | SP_QUERY | YES |
| sp_reader.e | SP_READER | YES |
| sp_storable.e | SP_STORABLE | YES |
| sp_writer.e | SP_WRITER | YES |

**Result:** All filenames match class names (lowercase with underscores).

## Feature Naming

### Conventions Verified
- Creation procedures: `make`, `make_*` - OK
- Queries (no side effects): Noun or adjective - OK
- Commands (with side effects): Verb phrases - OK
- Boolean queries: `is_*`, `has_*` - OK

### Sample Feature Names
| Feature | Type | Convention |
|---------|------|------------|
| make | Creation | OK |
| count | Query | OK |
| is_empty | Boolean query | OK |
| has_more | Boolean query | OK |
| put_integer_32 | Command | OK |
| read_string | Query | OK |
| extend | Command | OK |
| remove | Command | OK |
| start/forth/back/finish | Cursor | OK |

**Result:** All feature names follow Eiffel conventions.

## Argument Naming

### Multi-word Arguments (a_ prefix required)
| Argument | Location | Status |
|----------|----------|--------|
| a_capacity | SP_WRITER.make | OK |
| a_buffer | SP_READER.make_from_buffer | OK |
| a_chain | SP_QUERY.make | OK |
| a_condition | SP_QUERY.where | OK |
| a_comparator | SP_QUERY.order_by | OK |
| a_file | SP_WRITER.to_file | OK |
| a_min_capacity | SP_WRITER.grow | OK |

### Single-letter Arguments (acceptable Eiffel idiom)
| Argument | Context | Status |
|----------|---------|--------|
| v | Value being processed | Acceptable |
| n | Count/number | Acceptable |
| i | Index variable | Acceptable |

**Note:** Single-letter arguments are idiomatic Eiffel for simple parameters, especially in inherited interfaces from base library classes.

**Result:** Naming follows conventions; short names are acceptable idiom.

## Local Variable Naming

### Sample Local Variables (l_ prefix)
| Variable | Location | Status |
|----------|----------|--------|
| l_item | SP_QUERY.results | OK |
| l_match | SP_QUERY.results | OK |
| l_skip | SP_QUERY.results | OK |
| l_count | SP_QUERY.results | OK |
| l_result | SP_QUERY.evaluate | OK |
| l_writer | SP_TEST_APP tests | OK |
| l_reader | SP_TEST_APP tests | OK |

**Result:** All local variables follow l_ prefix convention.

## Constant Naming

| Constant | Class | Convention |
|----------|-------|------------|
| Combiner_and | SP_QUERY | Pascal_case - OK |
| Combiner_or | SP_QUERY | Pascal_case - OK |
| Software_version | SP_CHAIN | Pascal_case - OK |

**Result:** Constants follow Eiffel convention (capitalized words).

## Type Parameter Naming

| Parameter | Class | Convention |
|-----------|-------|------------|
| G | SP_CHAIN, SP_QUERY, etc. | Single uppercase - OK |
| K | SP_HASH_INDEX | Single uppercase - OK |

**Result:** Type parameters follow Eiffel convention.

## Summary

| Category | Convention | Compliance |
|----------|------------|------------|
| Class names | ALL_CAPS, SP_ prefix | 100% |
| File names | lowercase_underscores | 100% |
| Feature names | snake_case | 100% |
| Argument names | a_prefix for multi-word | 100% |
| Local variables | l_ prefix | 100% |
| Constants | Pascal_Case | 100% |
| Type parameters | Single uppercase | 100% |

**Overall Rating:** EXCELLENT

No naming changes required. The codebase follows all Eiffel naming conventions consistently.

---

**Generated:** 2026-01-20
**Workflow:** 10_naming-review
