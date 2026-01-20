note
	description: "Test storable item for unit tests"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_TEST_ITEM

inherit
	SP_STORABLE

create
	make_default,
	make_with_name

feature {NONE} -- Initialization

	make_default
		-- Create with empty name
		do
			create name.make_empty
			value := 0
		end

	make_with_name (a_name: STRING_32; a_value: INTEGER)
		-- Create with name and value
		do
			name := a_name
			value := a_value
		end

feature -- Access

	name: STRING_32
		-- Item name

	value: INTEGER
		-- Item value

	storage_version: NATURAL
		-- Version number
		do
			Result := 1
		end

feature -- Status

	is_valid: BOOLEAN
		-- Is this item valid?
		do
			Result := not name.is_empty
		end

feature -- Element Change

	set_name (a_name: STRING_32)
		-- Set name
		do
			name := a_name
		end

	set_value (a_value: INTEGER)
		-- Set value
		do
			value := a_value
		end

feature -- Serialization

	write_to (a_writer: SP_WRITER)
		-- Write to writer
		do
			a_writer.put_string (name)
			a_writer.put_integer_32 (value)
		end

	read_from (a_reader: SP_READER)
		-- Read from reader
		do
			name := a_reader.read_string
			value := a_reader.read_integer_32
		end

	byte_count: INTEGER
		-- Approximate serialized size
		do
			Result := 4 + name.count * 4 + 4
		end

end
