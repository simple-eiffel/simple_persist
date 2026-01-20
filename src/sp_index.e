note
	description: "Deferred base class for chain indexes"
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
		end

	item_count: INTEGER
		-- Total number of indexed items
		deferred
		end

feature -- Status

	has_key (a_key: K): BOOLEAN
		-- Is there any item with this key?
		deferred
		end

	has_item (a_item: G): BOOLEAN
		-- Is this item in the index?
		deferred
		end

	is_empty: BOOLEAN
		-- Is index empty?
		do
			Result := item_count = 0
		end

feature -- Event Handlers

	on_extend (a_item: G)
		-- Called when item added to chain
		deferred
		end

	on_remove (a_item: G)
		-- Called when item removed from chain
		deferred
		end

	on_replace (old_item, new_item: G)
		-- Called when item replaced in chain
		deferred
		end

	on_delete (a_item: G)
		-- Called when item marked deleted
		deferred
		end

feature -- Removal

	wipe_out
		-- Clear all index entries
		deferred
		end

	remove_item (a_item: G)
		-- Remove item from index
		deferred
		end

end
