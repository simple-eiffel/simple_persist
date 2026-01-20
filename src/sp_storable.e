note
	description: "Deferred base class for objects that can be stored and retrieved"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SP_STORABLE

feature {NONE} -- Initialization

	make_default
		-- Create in default state
		deferred
		end

feature -- Access

	storage_version: NATURAL
		-- Version number for this data format
		deferred
		end

feature -- Status

	is_deleted: BOOLEAN
		-- Has this item been marked for deletion?

	is_valid: BOOLEAN
		-- Is this item in a valid state?
		deferred
		end

feature -- Status Change

	mark_deleted
		-- Mark this item as deleted
		do
			is_deleted := True
		end

	unmark_deleted
		-- Remove deletion mark from this item
		do
			is_deleted := False
		end

feature -- Serialization

	write_to (a_writer: SP_WRITER)
		-- Write this item's data to writer
		require
			writer_attached: a_writer /= Void
		deferred
		end

	read_from (a_reader: SP_READER)
		-- Read this item's data from reader
		require
			reader_attached: a_reader /= Void
		deferred
		end

	byte_count: INTEGER
		-- Approximate size when serialized
		deferred
		end

end
