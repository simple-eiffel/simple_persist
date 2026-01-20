note
	description: "Hash-based index implementation using agent key extractor"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_HASH_INDEX [G -> SP_STORABLE, K -> HASHABLE]

inherit
	SP_INDEX [G, K]

create
	make

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_GENERAL; a_key_extractor: FUNCTION [G, K])
		-- Create index with name using key_extractor to get key from item
		require
			name_attached: a_name /= Void
			name_not_empty: not a_name.is_empty
			key_extractor_attached: a_key_extractor /= Void
		do
			name := a_name
			key_extractor := a_key_extractor
			create index_table.make (100)
		end

feature -- Access

	name: READABLE_STRING_GENERAL
		-- Name of this index

	key_extractor: FUNCTION [G, K]
		-- Agent that extracts key from item

	items_for_key (a_key: K): LIST [G]
		-- All items with given key value
		require else
			key_attached: a_key /= Void
		do
			if attached index_table.item (a_key) as l_list then
				Result := l_list
			else
				create {ARRAYED_LIST [G]} Result.make (0)
			end
		end

	first_for_key (a_key: K): detachable G
		-- First item with given key value, or Void
		require else
			key_attached: a_key /= Void
		do
			if attached index_table.item (a_key) as l_list and then not l_list.is_empty then
				Result := l_list.first
			end
		end

feature -- Measurement

	key_count: INTEGER
		-- Number of distinct keys
		do
			Result := index_table.count
		end

	item_count: INTEGER
		-- Total number of indexed items
		local
			l_count: INTEGER
		do
			from
				index_table.start
			until
				index_table.after
			loop
				l_count := l_count + index_table.item_for_iteration.count
				index_table.forth
			end
			Result := l_count
		end

feature -- Status

	has_key (a_key: K): BOOLEAN
		-- Is there any item with this key?
		require else
			key_attached: a_key /= Void
		do
			Result := index_table.has (a_key)
		end

	has_item (a_item: G): BOOLEAN
		-- Is this item in the index?
		require else
			item_attached: a_item /= Void
		local
			l_key: K
		do
			l_key := key_for (a_item)
			if attached index_table.item (l_key) as l_list then
				Result := l_list.has (a_item)
			end
		end

feature -- Event Handlers

	on_extend (a_item: G)
		-- Called when item added to chain
		require else
			item_attached: a_item /= Void
		local
			l_key: K
			l_list: ARRAYED_LIST [G]
		do
			l_key := key_for (a_item)
			if attached index_table.item (l_key) as existing_list then
				existing_list.extend (a_item)
			else
				create l_list.make (5)
				l_list.extend (a_item)
				index_table.put (l_list, l_key)
			end
		end

	on_remove (a_item: G)
		-- Called when item removed from chain
		require else
			item_attached: a_item /= Void
		do
			remove_item (a_item)
		end

	on_replace (old_item, new_item: G)
		-- Called when item replaced in chain
		require else
			old_item_attached: old_item /= Void
			new_item_attached: new_item /= Void
		do
			remove_item (old_item)
			on_extend (new_item)
		end

	on_delete (a_item: G)
		-- Called when item marked deleted
		require else
			item_attached: a_item /= Void
		do
			remove_item (a_item)
		end

feature -- Removal

	wipe_out
		-- Clear all index entries
		do
			index_table.wipe_out
		end

	remove_item (a_item: G)
		-- Remove item from index
		require else
			item_attached: a_item /= Void
		local
			l_key: K
		do
			l_key := key_for (a_item)
			if attached index_table.item (l_key) as l_list then
				l_list.prune (a_item)
				if l_list.is_empty then
					index_table.remove (l_key)
				end
			end
		end

feature {NONE} -- Implementation

	index_table: HASH_TABLE [ARRAYED_LIST [G], K]
		-- Maps keys to lists of items

	key_for (a_item: G): K
		-- Extract key from item using key_extractor
		do
			Result := key_extractor.item ([a_item])
		end

invariant
	index_table_attached: index_table /= Void
	key_extractor_attached: key_extractor /= Void
	name_attached: name /= Void

end
