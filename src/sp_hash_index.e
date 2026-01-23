note
	description: "[
		Hash-based index implementation using agent key extractor.

		Model-based contracts using MML_MAP and MML_SET for specification.
		The model_index query provides a mathematical view of the index.
	]"
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
		-- Create index with name using key_extractor to get key from item.
		require
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			key_extractor := a_key_extractor
			create index_table.make (100)
		ensure
			name_set: name = a_name
			key_extractor_set: key_extractor = a_key_extractor
			empty: is_empty
		end

feature -- Access

	name: READABLE_STRING_GENERAL
		-- Name of this index

	key_extractor: FUNCTION [G, K]
		-- Agent that extracts key from item

	items_for_key (a_key: K): LIST [G]
		-- All items with given key value.
		require else
			key_attached: attached a_key
		do
			if attached index_table.item (a_key) as l_list then
				Result := l_list
			else
				create {ARRAYED_LIST [G]} Result.make (0)
			end
		ensure then
			result_attached: attached Result
		end

	first_for_key (a_key: K): detachable G
		-- First item with given key value, or Void.
		require else
			key_attached: attached a_key
		do
			if attached index_table.item (a_key) as l_list and then not l_list.is_empty then
				Result := l_list.first
			end
		ensure then
			result_in_items: attached Result implies items_for_key (a_key).has (Result)
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

feature -- Model

	model_index: MML_MAP [K, MML_SET [G]]
		-- Mathematical model of index as a map from keys to sets of items.
		local
			l_set: MML_SET [G]
			l_item: G
			i: INTEGER
		do
			create Result
			from
				index_table.start
			until
				index_table.after
			loop
				create l_set
				from i := 1 until i > index_table.item_for_iteration.count loop
					l_item := index_table.item_for_iteration.i_th (i)
					l_set := l_set & l_item
					i := i + 1
				end
				Result := Result.updated (index_table.key_for_iteration, l_set)
				index_table.forth
			end
		ensure then
			domain_matches: Result.domain.count = key_count
		end

feature -- Status

	has_key (a_key: K): BOOLEAN
		-- Is there any item with this key?
		require else
			key_attached: attached a_key
		do
			Result := index_table.has (a_key)
		end

	has_item (a_item: G): BOOLEAN
		-- Is this item in the index?
		require else
			item_attached: attached a_item
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
		-- Called when item added to chain.
		require else
			item_attached: attached a_item
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
		ensure then
			key_exists: has_key (key_for (a_item))
		end

	on_remove (a_item: G)
		-- Called when item removed from chain.
		require else
			item_attached: attached a_item
		do
			remove_item (a_item)
		end

	on_replace (old_item, new_item: G)
		-- Called when item replaced in chain.
		require else
			old_attached: attached old_item
			new_attached: attached new_item
		do
			remove_item (old_item)
			on_extend (new_item)
		end

	on_delete (a_item: G)
		-- Called when item marked deleted.
		require else
			item_attached: attached a_item
		do
			remove_item (a_item)
		end

feature -- Removal

	wipe_out
		-- Clear all index entries.
		do
			index_table.wipe_out
		ensure then
			table_empty: index_table.is_empty
		end

	remove_item (a_item: G)
		-- Remove item from index.
		require else
			item_attached: attached a_item
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
		-- Extract key from item using key_extractor.
		require
			item_attached: attached a_item
		do
			Result := key_extractor.item ([a_item])
		end

invariant
	index_table_attached: attached index_table
	key_extractor_attached: attached key_extractor
	name_attached: attached name
	name_not_empty: not name.is_empty

end
