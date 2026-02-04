note
	description: "Test cases for SIMPLE_PERSIST - Tier 1: Empty Chain Tests"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Tier 1: Empty Chain Creation

	test_empty_chain_creation
			-- Test creating an empty chain.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
		do
			create chain.make
			assert_integers_equal ("count_zero", 0, chain.count)
			assert_true ("is_empty", chain.is_empty)
		end

	test_empty_chain_cursor_position
			-- Test cursor position in empty chain.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
		do
			create chain.make
			assert_true ("before_initially", chain.before)
			assert_false ("not_after_initially", chain.after)
		end

	test_chain_with_capacity
			-- Test creating chain with initial capacity.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
		do
			create chain.make_with_capacity (100)
			assert_integers_equal ("count_zero", 0, chain.count)
			assert_true ("is_empty", chain.is_empty)
		end

feature -- Tier 1: Adding Items to Empty Chain

	test_extend_single_item
			-- Test extending chain with one item.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		do
			create chain.make
			create item.make_default
			chain.extend (item)
			assert_integers_equal ("count_one", 1, chain.count)
			assert_false ("not_empty", chain.is_empty)
		end

	test_extend_multiple_items
			-- Test extending chain with multiple items.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
			i: INTEGER
		do
			create chain.make
			from i := 1 until i > 3 loop
				create item.make_default
				chain.extend (item)
				i := i + 1
			end
			assert_integers_equal ("count_three", 3, chain.count)
		end

	test_first_item_access
			-- Test accessing first item after extend.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		do
			create chain.make
			create item.make_with_name ("first", 1)
			chain.extend (item)
			chain.start
			assert_attached ("item_attached", chain.item)
		end

feature -- Tier 1: Cursor Navigation

	test_cursor_start_position
			-- Test starting at first position.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		do
			create chain.make
			create item.make_default
			chain.extend (item)
			chain.start
			assert_integers_equal ("index_one", 1, chain.index)
		end

	test_cursor_finish_position
			-- Test moving to last position.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
			i: INTEGER
		do
			create chain.make
			from i := 1 until i > 3 loop
				create item.make_default
				chain.extend (item)
				i := i + 1
			end
			chain.finish
			assert_integers_equal ("index_three", 3, chain.index)
		end

end
