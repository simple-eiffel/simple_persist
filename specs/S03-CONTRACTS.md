# S03-CONTRACTS: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## SP_WRITER Contracts

### make
```eiffel
make (a_capacity: INTEGER)
    require
        positive_capacity: a_capacity > 0
    ensure
        capacity_set: capacity = a_capacity
        empty: count = 0
        buffer_created: buffer /= Void
```

### put_integer_32
```eiffel
put_integer_32 (v: INTEGER_32)
    ensure
        count_increased: count = old count + 4
```

### put_string
```eiffel
put_string (v: READABLE_STRING_GENERAL)
    -- Length prefix (4 bytes) + content
```

### Invariant
```eiffel
invariant
    buffer_attached: attached buffer
    count_non_negative: count >= 0
    count_within_capacity: count <= capacity
    capacity_positive: capacity > 0
```

## SP_STORABLE Contracts

### write_to
```eiffel
write_to (a_writer: SP_WRITER)
    require
        writer_attached: a_writer /= Void
```

### read_from
```eiffel
read_from (a_reader: SP_READER)
    require
        reader_attached: a_reader /= Void
```

## SIMPLE_PERSIST Contracts

### delete_file
```eiffel
delete_file (a_path: PATH)
    ensure
        deleted: not file_exists (a_path)
```

### set_default_path
```eiffel
set_default_path (a_path: PATH)
    ensure
        path_set: default_path = a_path
```
