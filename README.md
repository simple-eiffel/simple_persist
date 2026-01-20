<p align="center">
  <img src="docs/images/logo.png" alt="simple_persist logo" width="200">
</p>

<h1 align="center">simple_persist</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_persist/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_persist">GitHub</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

SCOOP-safe object persistence library for Eiffel with binary serialization, fluent queries, and hash indexing.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 11 tests passing
- Full Design by Contract
- SCOOP compatible
- Void safe

## Overview

SIMPLE_PERSIST provides lightweight object persistence with **binary serialization** (SP_WRITER/SP_READER), **in-memory chains** (SP_ARRAYED_CHAIN), **fluent queries** (SP_QUERY), and **hash indexing** (SP_HASH_INDEX).

## Quick Start

### Installation

Add to your ECF:

```xml
<library name="simple_persist" location="$SIMPLE_LIBS\simple_persist\simple_persist.ecf"/>
```

### Define a Storable Object

```eiffel
class MY_ITEM inherit SP_STORABLE

feature
    name: STRING_32
    value: INTEGER

    store (writer: SP_WRITER)
        do
            writer.put_string (name)
            writer.put_integer_32 (value)
        end

    retrieve (reader: SP_READER)
        do
            name := reader.read_string
            value := reader.read_integer_32
        end
end
```

### Create and Persist

```eiffel
local
    chain: SP_ARRAYED_CHAIN [MY_ITEM]
    item: MY_ITEM
do
    create chain.make
    create item.make_default
    item.name := "Test"
    item.value := 42
    chain.extend (item)
    chain.save_as ("data.bin")
end
```

### Query Data

```eiffel
local
    query: SP_QUERY [MY_ITEM]
    results: LIST [MY_ITEM]
do
    create query.make (chain)
    results := query
        .where (agent (it: MY_ITEM): BOOLEAN do Result := it.value > 10 end)
        .take (100)
        .results
end
```

### Use Indexes

```eiffel
local
    index: SP_HASH_INDEX [MY_ITEM, STRING_32]
do
    create index.make ("name_index", agent (it: MY_ITEM): STRING_32 do Result := it.name end)
    index.on_extend (item)
    -- Fast lookup
    results := index.items_for_key ("Test")
end
```

## API Reference

| Class | Purpose |
|-------|---------|
| `SIMPLE_PERSIST` | Facade for common operations |
| `SP_WRITER` | Binary serialization writer |
| `SP_READER` | Binary deserialization reader |
| `SP_CHAIN` | Base class for object chains |
| `SP_ARRAYED_CHAIN` | Array-backed chain implementation |
| `SP_STORABLE` | Base class for persistable objects |
| `SP_QUERY` | Fluent query builder |
| `SP_INDEX` | Base class for indexes |
| `SP_HASH_INDEX` | Hash-based index implementation |

## Features

- **Binary Serialization**: Efficient binary format for all primitive types and strings
- **Object Chains**: In-memory collections with cursor navigation and soft delete
- **Fluent Queries**: Builder pattern with where/and_where/or_where/take/skip
- **Hash Indexing**: Fast key-based lookups with multi-value support
- **Design by Contract**: Full preconditions, postconditions, and invariants
- **SCOOP Compatible**: Safe for concurrent access

## Requirements

- EiffelStudio 25.02 or later
- Windows, Linux, or macOS

## Testing

```bash
# Compile tests
ec -batch -config simple_persist.ecf -target simple_persist_tests -c_compile

# Run tests
./EIFGENs/simple_persist_tests/W_code/simple_persist.exe
```

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Author:** Larry Rix
