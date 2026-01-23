note
	description: "[
		Generic chain of storable objects that can be persisted to file.

		Model-based contracts using MML_SEQUENCE for specification.
		All elements are modeled as a mathematical sequence.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SP_CHAIN [G -> SP_STORABLE create make_default end]

feature {NONE} -- Initialization

	make
		-- Create empty chain
		do
			create file_path.make_empty
			create reader.make (Default_buffer_size)
			create writer.make (Default_buffer_size)
			deleted_count := 0
			stored_version := 0
		ensure
			no_deleted: deleted_count = 0
			no_stored_version: stored_version = 0
			reader_created: reader /= Void
			writer_created: writer /= Void
		end

	make_from_file (a_path: PATH)
		-- Create and load from file
		require
			path_attached: a_path /= Void
		do
			make
			file_path := a_path
			load
		ensure
			path_set: file_path = a_path
		end

feature -- Access

	file_path: PATH
		-- Path to storage file

	item: G
		-- Current item
		deferred
		end

	i_th (i: INTEGER): G
		-- Item at position i
		deferred
		end

	first: G
		-- First item
		deferred
		end

	last: G
		-- Last item
		deferred
		end

	software_version: NATURAL
		-- Version number of this software
		deferred
		end

	stored_version: NATURAL
		-- Version number from stored file

feature -- Model

	model_items: MML_SEQUENCE [G]
		-- Mathematical model of chain contents as a sequence.
		-- For use in contracts only; not efficient for runtime use.
		deferred
		ensure
			count_matches: Result.count = count
		end

feature -- Measurement

	count: INTEGER
		-- Number of items in chain
		deferred
		end

	deleted_count: INTEGER
		-- Number of items marked for deletion

	active_count: INTEGER
		-- Number of non-deleted items
		do
			Result := count - deleted_count
		end

feature -- Status

	is_empty: BOOLEAN
		-- Is chain empty?
		do
			Result := count = 0
		end

	is_open: BOOLEAN
		-- Is storage file open?

	has (v: G): BOOLEAN
		-- Does chain contain v?
		deferred
		ensure
			model_consistent: Result = model_items.has (v)
		end

	valid_index (i: INTEGER): BOOLEAN
		-- Is i a valid index?
		do
			Result := i >= 1 and i <= count
		end

	has_version_mismatch: BOOLEAN
		-- Does stored version differ from software version?
		do
			Result := stored_version /= software_version
		end

feature -- Cursor Movement

	start
		-- Move to first position
		deferred
		end

	finish
		-- Move to last position
		deferred
		end

	forth
		-- Move to next position
		deferred
		end

	back
		-- Move to previous position
		deferred
		end

	go_i_th (i: INTEGER)
		-- Move to position i
		require
			valid_index: i >= 0 and i <= count + 1
		deferred
		end

	index: INTEGER
		-- Current position
		deferred
		end

	after: BOOLEAN
		-- Is cursor past last item?
		deferred
		end

	before: BOOLEAN
		-- Is cursor before first item?
		deferred
		end

feature -- Element Change

	extend (v: G)
		-- Add v to end of chain.
		deferred
		ensure
			count_increased: count = old count + 1
			model_extended: model_items |=| (old model_items).extended (v)
		end

	put (v: G)
		-- Replace current item with v.
		deferred
		end

	force (v: G)
		-- Add v, extending capacity if needed.
		deferred
		ensure
			count_increased: count = old count + 1
		end

feature -- Removal

	remove
		-- Remove current item.
		require
			not_empty: not is_empty
			valid_cursor: not before and not after
		deferred
		ensure
			count_decreased: count = old count - 1
			model_item_removed: model_items |=| (old model_items).removed_at (old index)
		end

	prune (v: G)
		-- Remove first occurrence of v.
		deferred
		ensure
			count_effect: old model_items.has (v) implies count = old count - 1
		end

	wipe_out
		-- Remove all items.
		deferred
		ensure
			empty: is_empty
			model_empty: model_items.is_empty
		end

	mark_deleted
		-- Mark current item as deleted
		require
			not_empty: not is_empty
			valid_cursor: not before and not after
		do
			item.mark_deleted
			deleted_count := deleted_count + 1
		ensure
			deleted_count_increased: deleted_count = old deleted_count + 1
			item_deleted: item.is_deleted
		end

	compact
		-- Remove all items marked as deleted
		do
			from start until after loop
				if item.is_deleted then
					remove
				else
					forth
				end
			end
			deleted_count := 0
		ensure
			no_deleted_items: deleted_count = 0
		end

feature -- Persistence

	save
		-- Save chain to file_path
		do
			save_as (file_path)
		end

	save_as (a_path: PATH)
		-- Save chain to specified path
		require
			path_attached: a_path /= Void
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_path (a_path)
			l_file.open_write
			-- Write header: version and count
			l_file.put_natural_32 (software_version)
			l_file.put_integer (active_count)
			-- Write items
			from start until after loop
				if not item.is_deleted then
					writer.reset
					item.write_to (writer)
					l_file.put_integer (writer.count)
					writer.to_file (l_file)
				end
				forth
			end
			l_file.close
			file_path := a_path
		ensure
			path_updated: file_path = a_path
		end

	load
		-- Load chain from file_path
		local
			l_file: RAW_FILE
			l_count, l_size, i: INTEGER
			l_item: G
		do
			create l_file.make_with_path (file_path)
			if l_file.exists then
				l_file.open_read
				-- Read header
				l_file.read_natural_32
				stored_version := l_file.last_natural_32
				l_file.read_integer
				l_count := l_file.last_integer
				-- Read items
				wipe_out
				from i := 1 until i > l_count or l_file.end_of_file loop
					l_file.read_integer
					l_size := l_file.last_integer
					reader.from_file (l_file, l_size)
					reader.set_data_version (stored_version)
					create l_item.make_default
					l_item.read_from (reader)
					extend (l_item)
					i := i + 1
				end
				l_file.close
			end
		end

	close
		-- Close any open file handles
		do
			is_open := False
		ensure
			not_open: not is_open
		end

feature -- Iteration

	do_all (action: PROCEDURE [G])
		-- Apply action to every item
		require
			action_attached: action /= Void
		deferred
		end

	do_if (action: PROCEDURE [G]; test: FUNCTION [G, BOOLEAN])
		-- Apply action to items satisfying test
		require
			action_attached: action /= Void
			test_attached: test /= Void
		deferred
		end

	there_exists (test: FUNCTION [G, BOOLEAN]): BOOLEAN
		-- Does any item satisfy test?
		require
			test_attached: test /= Void
		deferred
		end

	for_all (test: FUNCTION [G, BOOLEAN]): BOOLEAN
		-- Do all items satisfy test?
		require
			test_attached: test /= Void
		deferred
		end

feature {NONE} -- Implementation

	reader: SP_READER
		-- Reader for deserialization

	writer: SP_WRITER
		-- Writer for serialization

	header_size: INTEGER = 8
		-- Size of file header in bytes (4 + 4)

	Default_buffer_size: INTEGER = 4096
		-- Default size for read/write buffers

invariant
	reader_attached: attached reader
	writer_attached: attached writer
	deleted_count_non_negative: deleted_count >= 0
	model_count_consistent: model_items.count = count

end
