# 7S-04-SIMPLE-STAR: simple_persist

**BACKWASH DOCUMENT** - Generated retroactively from existing implementation
**Date**: 2026-01-23
**Library**: simple_persist
**Status**: Production (v1.0.0)

## Ecosystem Position

simple_persist is a FOUNDATION-level library providing object persistence without database dependencies.

```
FOUNDATION_API (core utilities including persistence)
       |
SERVICE_API (may use persistence for caching)
       |
APP_API (application data storage)
```

## Dependencies

| Library | Purpose | Required |
|---------|---------|----------|
| EiffelBase | Core types | Yes (standard) |
| None | Pure Eiffel | - |

**Zero external dependencies** - Pure Eiffel implementation.

## Integration Pattern

### Basic Usage
```eiffel
class MY_ITEM inherit SP_STORABLE
feature
    name: STRING_32
    value: INTEGER

    write_to (writer: SP_WRITER)
        do
            writer.put_string (name)
            writer.put_integer_32 (value)
        end

    read_from (reader: SP_READER)
        do
            name := reader.read_string
            value := reader.read_integer_32
        end
end
```

### ECF Integration
```xml
<library name="simple_persist"
         location="$SIMPLE_EIFFEL/simple_persist/simple_persist.ecf"/>
```

## Ecosystem Conventions Followed

1. **Naming**: SP_ prefix for internal classes
2. **Facade**: SIMPLE_PERSIST main entry point
3. **DBC**: Full contract coverage
4. **Void Safety**: Complete
5. **SCOOP**: Compatible design
