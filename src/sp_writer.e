note
	description: "[
		Memory buffer writer for serializing objects.

		Design by Contract enhanced with void-safety assertions.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_WRITER

create
	make

feature {NONE} -- Initialization

	make (a_capacity: INTEGER)
		-- Create with initial buffer capacity
		require
			positive_capacity: a_capacity > 0
		do
			create buffer.make (a_capacity)
			capacity := a_capacity
			count := 0
		ensure
			capacity_set: capacity = a_capacity
			empty: count = 0
			buffer_created: buffer /= Void
		end

feature -- Access

	buffer: MANAGED_POINTER
		-- Internal byte buffer

	count: INTEGER
		-- Number of bytes written

	capacity: INTEGER
		-- Current buffer capacity

feature -- Status

	is_full: BOOLEAN
		-- Is buffer at capacity?
		do
			Result := count >= capacity
		end

feature -- Write Primitives

	put_integer_8 (v: INTEGER_8)
		-- Write 8-bit integer
		do
			ensure_capacity (1)
			buffer.put_integer_8 (v, count)
			count := count + 1
		ensure
			count_increased: count = old count + 1
		end

	put_integer_16 (v: INTEGER_16)
		-- Write 16-bit integer
		do
			ensure_capacity (2)
			buffer.put_integer_16 (v, count)
			count := count + 2
		ensure
			count_increased: count = old count + 2
		end

	put_integer_32 (v: INTEGER_32)
		-- Write 32-bit integer
		do
			ensure_capacity (4)
			buffer.put_integer_32 (v, count)
			count := count + 4
		ensure
			count_increased: count = old count + 4
		end

	put_integer_64 (v: INTEGER_64)
		-- Write 64-bit integer
		do
			ensure_capacity (8)
			buffer.put_integer_64 (v, count)
			count := count + 8
		ensure
			count_increased: count = old count + 8
		end

	put_natural_8 (v: NATURAL_8)
		-- Write 8-bit natural
		do
			ensure_capacity (1)
			buffer.put_natural_8 (v, count)
			count := count + 1
		ensure
			count_increased: count = old count + 1
		end

	put_natural_16 (v: NATURAL_16)
		-- Write 16-bit natural
		do
			ensure_capacity (2)
			buffer.put_natural_16 (v, count)
			count := count + 2
		ensure
			count_increased: count = old count + 2
		end

	put_natural_32 (v: NATURAL_32)
		-- Write 32-bit natural
		do
			ensure_capacity (4)
			buffer.put_natural_32 (v, count)
			count := count + 4
		ensure
			count_increased: count = old count + 4
		end

	put_natural_64 (v: NATURAL_64)
		-- Write 64-bit natural
		do
			ensure_capacity (8)
			buffer.put_natural_64 (v, count)
			count := count + 8
		ensure
			count_increased: count = old count + 8
		end

	put_real_32 (v: REAL_32)
		-- Write 32-bit real
		do
			ensure_capacity (4)
			buffer.put_real_32 (v, count)
			count := count + 4
		ensure
			count_increased: count = old count + 4
		end

	put_real_64 (v: REAL_64)
		-- Write 64-bit real
		do
			ensure_capacity (8)
			buffer.put_real_64 (v, count)
			count := count + 8
		ensure
			count_increased: count = old count + 8
		end

	put_boolean (v: BOOLEAN)
		-- Write boolean
		do
			if v then
				put_natural_8 (1)
			else
				put_natural_8 (0)
			end
		ensure
			count_increased: count = old count + 1
		end

	put_character_8 (v: CHARACTER_8)
		-- Write 8-bit character
		do
			ensure_capacity (1)
			buffer.put_character (v, count)
			count := count + 1
		ensure
			count_increased: count = old count + 1
		end

	put_string (v: READABLE_STRING_GENERAL)
		-- Write string with length prefix.
		local
			i: INTEGER
		do
			put_integer_32 (v.count)
			from i := 1 until i > v.count loop
				put_integer_32 (v.code (i).to_integer_32)
				i := i + 1
			end
		end

	put_bytes (v: MANAGED_POINTER; n: INTEGER)
		-- Write n bytes from pointer.
		require
			non_negative_count: n >= 0
			valid_source_size: n <= v.count
		local
			i: INTEGER
		do
			ensure_capacity (n)
			from i := 0 until i >= n loop
				buffer.put_natural_8 (v.read_natural_8 (i), count + i)
				i := i + 1
			end
			count := count + n
		ensure
			count_increased: count = old count + n
		end

feature -- Buffer Operations

	reset
		-- Reset count to zero for reuse
		do
			count := 0
		ensure
			empty: count = 0
		end

	grow (a_min_capacity: INTEGER)
		-- Ensure capacity is at least a_min_capacity
		local
			new_buffer: MANAGED_POINTER
		do
			if a_min_capacity > capacity then
				create new_buffer.make (a_min_capacity)
				new_buffer.item.memory_copy (buffer.item, count)
				buffer := new_buffer
				capacity := a_min_capacity
			end
		ensure
			capacity_sufficient: capacity >= a_min_capacity
			count_unchanged: count = old count
		end

	to_file (a_file: RAW_FILE)
		-- Write buffer contents to file.
		require
			file_open: a_file.is_open_write
		do
			a_file.put_managed_pointer (buffer, 0, count)
		end

feature {NONE} -- Implementation

	ensure_capacity (n: INTEGER)
		-- Ensure we can write n more bytes
		do
			if count + n > capacity then
				grow ((capacity * 2).max (count + n))
			end
		end

invariant
	buffer_attached: attached buffer
	count_non_negative: count >= 0
	count_within_capacity: count <= capacity
	capacity_positive: capacity > 0

end
