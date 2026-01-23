note
	description: "[
		Deferred base class for chain indexes.

		Model-based contracts using MML_MAP and MML_SET for specification.
		The model_index query provides a mathematical view of index structure.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SP_INDEX [G -> SP_STORABLE, K -> HASHABLE]

feature -- Access

	name: READABLE_STRING_GENERAL
		-- Name of this index
		deferred
		end

	items_for_key (a_key: K): LIST [G]
		-- All items with given key value
		deferred
		end

	first_for_key (a_key: K): detachable G
		-- First item with given key value, or Void
		deferred
		end

feature -- Measurement

	key_count: INTEGER
		-- Number of distinct keys
		deferred
		ensure
			model_consistent: Result = model_index.domain.count
		end

	item_count: INTEGER
		-- Total number of indexed items
		deferred
		end

feature -- Model

	model_index: MML_MAP [K, MML_SET [G]]
		-- Mathematical model of index as a map from keys to sets of items.
		-- For use in contracts only; not efficient for runtime use.
		deferred
		ensure
			key_count_matches: Result.domain.count = key_count
		end

feature -- Status

	has_key (a_key: K): BOOLEAN
		-- Is there any item with this key?
		require
			key_attached: attached a_key
		deferred
		ensure
			model_consistent: Result = model_index.domain [a_key]
		end

	has_item (a_item: G): BOOLEAN
		-- Is this item in the index?
		require
			item_attached: attached a_item
		deferred
		end

	is_empty: BOOLEAN
		-- Is index empty?
		do
			Result := item_count = 0
		end

feature -- Event Handlers

	on_extend (a_item: G)
		-- Called when item added to chain.
		require
			item_attached: attached a_item
		deferred
		ensure
			item_indexed: has_item (a_item)
			item_count_increased: item_count >= old item_count
		end

	on_remove (a_item: G)
		-- Called when item removed from chain.
		require
			item_attached: attached a_item
		deferred
		ensure
			item_removed: not has_item (a_item)
		end

	on_replace (old_item, new_item: G)
		-- Called when item replaced in chain.
		require
			old_attached: attached old_item
			new_attached: attached new_item
		deferred
		ensure
			old_removed: not has_item (old_item)
			new_indexed: has_item (new_item)
		end

	on_delete (a_item: G)
		-- Called when item marked deleted.
		require
			item_attached: attached a_item
		deferred
		ensure
			item_removed: not has_item (a_item)
		end

feature -- Removal

	wipe_out
		-- Clear all index entries.
		deferred
		ensure
			empty: is_empty
			model_empty: model_index.is_empty
		end

	remove_item (a_item: G)
		-- Remove item from index.
		require
			item_attached: attached a_item
		deferred
		ensure
			item_removed: not has_item (a_item)
		end

end
