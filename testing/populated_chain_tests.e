note
	description: "Test cases for SIMPLE_PERSIST - Tier 2: Populated Chain Tests"
	author: "Larry Rix with Claude (Anthropic)"
	date: "$Date$"
	revision: "$Revision$"

class
	POPULATED_CHAIN_TESTS

inherit
	TEST_SET_BASE

feature -- Fixtures

	populated_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			-- Chain with 5 test items
		once
			create Result.make
			add_test_items (Result, 5)
		ensure
			chain_created: Result /= Void
			has_5_items: Result.count = 5
		end

	populated_chain_with_names: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			-- Chain with named items
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		once
			create chain.make
			create item.make_with_name ("item1", 10)
			chain.extend (item)
			create item.make_with_name ("item2", 20)
			chain.extend (item)
			create item.make_with_name ("item3", 30)
			chain.extend (item)
			Result := chain
		ensure
			chain_created: Result /= Void
			has_3_items: Result.count = 3
		end

feature -- Tier 2: Chain Navigation

	test_cursor_movement_forth
			-- Test moving forward through chain.
		do
			populated_chain.start
			assert_integers_equal ("index_1", 1, populated_chain.index)
			populated_chain.forth
			assert_integers_equal ("index_2", 2, populated_chain.index)
		end

	test_cursor_movement_back
			-- Test moving backward through chain.
		do
			populated_chain.finish
			assert_integers_equal ("index_5", 5, populated_chain.index)
			populated_chain.back
			assert_integers_equal ("index_4", 4, populated_chain.index)
		end

	test_cursor_go_i_th
			-- Test moving to specific position.
		do
			populated_chain.go_i_th (3)
			assert_integers_equal ("index_3", 3, populated_chain.index)
		end

feature -- Tier 2: Item Access

	test_item_at_first
			-- Test accessing item at first position.
		do
			populated_chain.start
			assert_attached ("item_attached", populated_chain.item)
		end

	test_item_at_last
			-- Test accessing item at last position.
		do
			populated_chain.finish
			assert_attached ("item_attached", populated_chain.item)
		end

	test_i_th_access
			-- Test accessing item at specific position.
		do
			assert_attached ("item_3_attached", populated_chain.i_th (3))
		end

	test_first_item
			-- Test accessing first item.
		do
			assert_attached ("first_item", populated_chain.first)
		end

	test_last_item
			-- Test accessing last item.
		do
			assert_attached ("last_item", populated_chain.last)
		end

feature -- Tier 2: Status Checks

	test_has_item
			-- Test checking if chain contains item.
		local
			item: SP_TEST_ITEM
		do
			create item.make_default
			assert_true ("has_first_item", populated_chain.has (populated_chain.first))
		end

	test_chain_not_empty
			-- Test that populated chain is not empty.
		do
			assert_false ("not_empty", populated_chain.is_empty)
			assert_true ("count_5", populated_chain.count = 5)
		end

feature -- Tier 2: Iteration

	test_iterate_all_items
			-- Test iterating through all items.
		local
			count: INTEGER
		do
			from
				populated_chain.start
			until
				populated_chain.after
			loop
				count := count + 1
				populated_chain.forth
			end
			assert_integers_equal ("iterate_count_5", 5, count)
		end

feature {NONE} -- Helper

	add_test_items (a_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]; n: INTEGER)
			-- Add n test items to chain.
		local
			i: INTEGER
			item: SP_TEST_ITEM
		do
			from i := 1 until i > n loop
				create item.make_default
				a_chain.extend (item)
				i := i + 1
			end
		end

end
