note
	description: "[
		Array-backed implementation of SP_CHAIN.

		Model-based contracts using MML_SEQUENCE for specification.
		The model_items query provides a mathematical view of chain contents.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_ARRAYED_CHAIN [G -> SP_STORABLE create make_default end]

inherit
	SP_CHAIN [G]
		redefine
			make, make_from_file
		end

create
	make,
	make_from_file,
	make_with_capacity

feature {NONE} -- Initialization

	make
		-- Create empty chain
		do
			Precursor
			create items.make (10)
			cursor_index := 0
		ensure then
			items_created: items /= Void
			empty_items: items.is_empty
		end

	make_from_file (a_path: PATH)
		-- Create and load from file
		do
			make
			file_path := a_path
			load
		end

	make_with_capacity (n: INTEGER)
		-- Create with initial capacity for n items
		require
			positive_capacity: n > 0
		do
			make
			items.grow (n)
		ensure
			capacity_set: items.capacity >= n
		end

feature -- Access

	item: G
		-- Current item
		require else
			not_empty: not is_empty
			valid_cursor: not before and not after
		do
			Result := items.i_th (cursor_index)
		end

	i_th (i: INTEGER): G
		-- Item at position i
		require else
			valid_index: valid_index (i)
		do
			Result := items.i_th (i)
		end

	first: G
		-- First item
		require else
			not_empty: not is_empty
		do
			Result := items.first
		end

	last: G
		-- Last item
		require else
			not_empty: not is_empty
		do
			Result := items.last
		end

	software_version: NATURAL
		-- Version number of this software
		do
			Result := 1
		end

feature -- Measurement

	count: INTEGER
		-- Number of items in chain
		do
			Result := items.count
		end

feature -- Model

	model_items: MML_SEQUENCE [G]
		-- Mathematical model of chain contents as a sequence.
		local
			i: INTEGER
		do
			create Result
			from i := 1 until i > items.count loop
				Result := Result & items.i_th (i)
				i := i + 1
			end
		ensure then
			domain_valid: Result.domain.count = count
		end

feature -- Status

	has (v: G): BOOLEAN
		-- Does chain contain v?
		do
			Result := items.has (v)
		end

feature -- Cursor Movement

	start
		-- Move to first position
		do
			cursor_index := 1
		ensure then
			at_first: index = 1
		end

	finish
		-- Move to last position
		do
			cursor_index := items.count
		ensure then
			at_last: index = count
		end

	forth
		-- Move to next position
		do
			cursor_index := cursor_index + 1
		ensure then
			index_advanced: index = old index + 1
		end

	back
		-- Move to previous position
		do
			cursor_index := cursor_index - 1
		ensure then
			index_retreated: index = old index - 1
		end

	go_i_th (i: INTEGER)
		-- Move to position i
		require else
			valid_index: i >= 0 and i <= count + 1
		do
			cursor_index := i
		ensure then
			index_set: index = i
		end

	index: INTEGER
		-- Current position
		do
			Result := cursor_index
		end

	after: BOOLEAN
		-- Is cursor past last item?
		do
			Result := cursor_index > items.count
		end

	before: BOOLEAN
		-- Is cursor before first item?
		do
			Result := cursor_index < 1
		end

feature -- Element Change

	extend (v: G)
		-- Add v to end of chain
		do
			items.extend (v)
		ensure then
			count_increased: count = old count + 1
			item_added: last = v
		end

	put (v: G)
		-- Replace current item with v
		require else
			not_empty: not is_empty
			valid_cursor: not before and not after
		do
			items.put_i_th (v, cursor_index)
		ensure then
			item_replaced: item = v
			count_unchanged: count = old count
		end

	force (v: G)
		-- Add v, extending capacity if needed
		do
			items.force (v)
		ensure then
			count_increased: count = old count + 1
		end

feature -- Removal

	remove
		-- Remove current item
		require else
			not_empty: not is_empty
			valid_cursor: not before and not after
		do
			items.go_i_th (cursor_index)
			items.remove
		ensure then
			count_decreased: count = old count - 1
		end

	prune (v: G)
		-- Remove first occurrence of v
		do
			items.prune (v)
		end

	wipe_out
		-- Remove all items
		do
			items.wipe_out
			cursor_index := 0
			deleted_count := 0
		ensure then
			empty: is_empty
			no_deleted: deleted_count = 0
		end

feature -- Iteration

	do_all (action: PROCEDURE [G])
		-- Apply action to every item
		do
			items.do_all (action)
		end

	do_if (action: PROCEDURE [G]; test: FUNCTION [G, BOOLEAN])
		-- Apply action to items satisfying test
		do
			items.do_if (action, test)
		end

	there_exists (test: FUNCTION [G, BOOLEAN]): BOOLEAN
		-- Does any item satisfy test?
		do
			Result := items.there_exists (test)
		end

	for_all (test: FUNCTION [G, BOOLEAN]): BOOLEAN
		-- Do all items satisfy test?
		do
			Result := items.for_all (test)
		end

feature {NONE} -- Implementation

	items: ARRAYED_LIST [G]
		-- Internal storage

	cursor_index: INTEGER
		-- Current cursor position

invariant
	items_attached: attached items
	cursor_valid: cursor_index >= 0 and cursor_index <= items.count + 1

end
