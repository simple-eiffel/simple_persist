# simple_persist

<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/simple-eiffel.github.io/main/images/simple_persist_logo.png" alt="simple_persist logo" width="200"/>
</p>

<p align="center">
  <strong>SCOOP-Safe Object Persistence for Eiffel</strong>
</p>

<p align="center">
  <a href="https://github.com/simple-eiffel/simple_persist"><img src="https://img.shields.io/badge/Eiffel-25.02-blue.svg" alt="Eiffel 25.02"></a>
  <a href="https://github.com/simple-eiffel/simple_persist/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License"></a>
  <a href="https://simple-eiffel.github.io/simple_persist/"><img src="https://img.shields.io/badge/docs-online-brightgreen.svg" alt="Documentation"></a>
</p>

---

## Overview

**simple_persist** is a lightweight object persistence library for Eiffel that provides:

- Binary serialization with `SP_WRITER` and `SP_READER`
- In-memory object chains with `SP_CHAIN` and `SP_ARRAYED_CHAIN`
- Fluent query API with `SP_QUERY`
- Hash-based indexing with `SP_HASH_INDEX`
- Soft delete support with `is_deleted` flag
- SCOOP-compatible design for concurrent applications

## Quick Start

### Installation

Add to your ECF:

```xml
<library name="simple_persist" location="$SIMPLE_LIBS\simple_persist\simple_persist.ecf"/>
```

### Basic Usage

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

-- Create and populate chain
local
    chain: SP_ARRAYED_CHAIN [MY_ITEM]
    item: MY_ITEM
do
    create chain.make
    create item.make
    item.name := "Test"
    item.value := 42
    chain.extend (item)
    chain.save_as ("data.bin")
end
```

### Querying Data

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

### Indexing

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

- **Design by Contract**: Full preconditions, postconditions, and invariants
- **Void Safety**: 100% void-safe implementation
- **SCOOP Compatible**: Safe for concurrent access
- **Binary Format**: Efficient binary serialization
- **Fluent API**: Builder pattern for queries
- **Soft Delete**: Mark items deleted without removal

## Requirements

- EiffelStudio 25.02 or later
- Windows, Linux, or macOS

## Documentation

- [Full API Documentation](https://simple-eiffel.github.io/simple_persist/)
- [Specification Summary](specs/SPEC-SUMMARY.md)
- [Class Specifications](specs/CLASS-SPECS/)

## Testing

```bash
# Compile tests
ec -batch -config simple_persist.ecf -target simple_persist_tests -c_compile

# Run tests
./EIFGENs/simple_persist_tests/W_code/simple_persist.exe
```

Current test coverage: **11 tests, 100% pass**

## License

MIT License - see [LICENSE](LICENSE) for details.

## Part of the Simple Eiffel Ecosystem

<p align="center">
  <a href="https://github.com/simple-eiffel">
    <img src="https://img.shields.io/badge/ecosystem-simple--eiffel-blue.svg" alt="Simple Eiffel">
  </a>
</p>

simple_persist is part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem of libraries.

---

**Author:** Larry Rix
**Version:** 1.0.0
