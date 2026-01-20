note
	description: "Memory buffer reader for deserializing objects"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_READER

create
	make,
	make_from_buffer

feature {NONE} -- Initialization

	make (a_capacity: INTEGER)
		-- Create with initial buffer capacity
		require
			positive_capacity: a_capacity > 0
		do
			create buffer.make (a_capacity)
			count := 0
			position := 0
			data_version := 0
		ensure
			buffer_created: buffer /= Void
			empty: count = 0
			at_start: position = 0
			no_version: data_version = 0
		end

	make_from_buffer (a_buffer: MANAGED_POINTER; a_count: INTEGER)
		-- Create from existing buffer with a_count valid bytes
		require
			valid_buffer: a_buffer /= Void
			non_negative_count: a_count >= 0
			valid_count: a_count <= a_buffer.count
		do
			buffer := a_buffer
			count := a_count
			position := 0
			data_version := 0
		ensure
			buffer_set: buffer = a_buffer
			count_set: count = a_count
			at_start: position = 0
			no_version: data_version = 0
		end

feature -- Access

	buffer: MANAGED_POINTER
		-- Internal byte buffer

	position: INTEGER
		-- Current read position

	count: INTEGER
		-- Number of valid bytes in buffer

	data_version: NATURAL
		-- Version of data being read

feature -- Status

	is_end_of_buffer: BOOLEAN
		-- Have we read all bytes?
		do
			Result := position >= count
		end

	has_more (n: INTEGER): BOOLEAN
		-- Are there at least n more bytes to read?
		do
			Result := position + n <= count
		end

feature -- Read Primitives

	read_integer_8: INTEGER_8
		-- Read 8-bit integer
		require
			has_bytes: has_more (1)
		do
			Result := buffer.read_integer_8 (position)
			position := position + 1
		ensure
			position_advanced: position = old position + 1
		end

	read_integer_16: INTEGER_16
		-- Read 16-bit integer
		require
			has_bytes: has_more (2)
		do
			Result := buffer.read_integer_16 (position)
			position := position + 2
		ensure
			position_advanced: position = old position + 2
		end

	read_integer_32: INTEGER_32
		-- Read 32-bit integer
		require
			has_bytes: has_more (4)
		do
			Result := buffer.read_integer_32 (position)
			position := position + 4
		ensure
			position_advanced: position = old position + 4
		end

	read_integer_64: INTEGER_64
		-- Read 64-bit integer
		require
			has_bytes: has_more (8)
		do
			Result := buffer.read_integer_64 (position)
			position := position + 8
		ensure
			position_advanced: position = old position + 8
		end

	read_natural_8: NATURAL_8
		-- Read 8-bit natural
		require
			has_bytes: has_more (1)
		do
			Result := buffer.read_natural_8 (position)
			position := position + 1
		ensure
			position_advanced: position = old position + 1
		end

	read_natural_16: NATURAL_16
		-- Read 16-bit natural
		require
			has_bytes: has_more (2)
		do
			Result := buffer.read_natural_16 (position)
			position := position + 2
		ensure
			position_advanced: position = old position + 2
		end

	read_natural_32: NATURAL_32
		-- Read 32-bit natural
		require
			has_bytes: has_more (4)
		do
			Result := buffer.read_natural_32 (position)
			position := position + 4
		ensure
			position_advanced: position = old position + 4
		end

	read_natural_64: NATURAL_64
		-- Read 64-bit natural
		require
			has_bytes: has_more (8)
		do
			Result := buffer.read_natural_64 (position)
			position := position + 8
		ensure
			position_advanced: position = old position + 8
		end

	read_real_32: REAL_32
		-- Read 32-bit real
		require
			has_bytes: has_more (4)
		do
			Result := buffer.read_real_32 (position)
			position := position + 4
		ensure
			position_advanced: position = old position + 4
		end

	read_real_64: REAL_64
		-- Read 64-bit real
		require
			has_bytes: has_more (8)
		do
			Result := buffer.read_real_64 (position)
			position := position + 8
		ensure
			position_advanced: position = old position + 8
		end

	read_boolean: BOOLEAN
		-- Read boolean
		require
			has_bytes: has_more (1)
		do
			Result := read_natural_8 /= 0
		ensure
			position_advanced: position = old position + 1
		end

	read_character_8: CHARACTER_8
		-- Read 8-bit character
		require
			has_bytes: has_more (1)
		do
			Result := buffer.read_character (position)
			position := position + 1
		ensure
			position_advanced: position = old position + 1
		end

	read_string: STRING_32
		-- Read string with length prefix
		require
			has_length_prefix: has_more (4)
		local
			len, i: INTEGER
		do
			len := read_integer_32
			if len < 0 then
				len := 0  -- Defensive: treat corrupt negative length as empty
			end
			create Result.make (len)
			from i := 1 until i > len loop
				Result.append_code (read_integer_32.to_natural_32)
				i := i + 1
			end
		ensure
			result_attached: Result /= Void
		end

	read_bytes (n: INTEGER): MANAGED_POINTER
		-- Read n bytes into new pointer
		require
			non_negative_count: n >= 0
			has_bytes: has_more (n)
		local
			i: INTEGER
		do
			create Result.make (n)
			from i := 0 until i >= n loop
				Result.put_natural_8 (buffer.read_natural_8 (position + i), i)
				i := i + 1
			end
			position := position + n
		ensure
			result_attached: Result /= Void
			result_size: Result.count = n
			position_advanced: position = old position + n
		end

feature -- Buffer Operations

	reset
		-- Reset position to start
		do
			position := 0
		ensure
			at_start: position = 0
		end

	set_data_version (v: NATURAL)
		-- Set version of data being read
		do
			data_version := v
		ensure
			version_set: data_version = v
		end

	from_file (a_file: RAW_FILE; n: INTEGER)
		-- Read n bytes from file into buffer
		require
			file_attached: a_file /= Void
			file_open_read: a_file.is_open_read
			non_negative_count: n >= 0
		do
			if buffer.count < n then
				buffer.resize (n)
			end
			a_file.read_to_managed_pointer (buffer, 0, n)
			count := n
			position := 0
		ensure
			count_set: count = n
			at_start: position = 0
		end

invariant
	buffer_attached: buffer /= Void
	position_non_negative: position >= 0
	position_within_bounds: position <= count
	count_non_negative: count >= 0

end
