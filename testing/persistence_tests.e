note
	description: "Test cases for SIMPLE_PERSIST - Tier 3: Persistence Tests"
	author: "Larry Rix with Claude (Anthropic)"
	date: "$Date$"
	revision: "$Revision$"

class
	PERSISTENCE_TESTS

inherit
	TEST_SET_BASE

feature -- Tier 3: Save and Load

	test_save_chain_to_file
			-- Test saving a populated chain to file.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
			path: PATH
			l_file: RAW_FILE
		do
			create chain.make
			create item.make_with_name ("test_item", 42)
			chain.extend (item)

			create path.make_from_string ("test_chain.dat")
			chain.save_as (path)

			-- File should exist after save
			assert_true ("file_exists", (create {RAW_FILE}.make_with_path (path)).exists)

			-- Clean up
			create l_file.make_with_path (path)
			if l_file.exists then l_file.delete end
		end

	test_roundtrip_preserves_count
			-- Test that saving and loading preserves item count.
		local
			saved_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			loaded_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
			path: PATH
			i: INTEGER
			l_file: RAW_FILE
		do
			-- Create and save chain with 5 items
			create saved_chain.make
			from i := 1 until i > 5 loop
				create item.make_with_name ("item" + i.out, i * 10)
				saved_chain.extend (item)
				i := i + 1
			end

			create path.make_from_string ("roundtrip_test.dat")
			saved_chain.save_as (path)

			-- Load and verify count
			create loaded_chain.make_from_file (path)
			assert_integers_equal ("count_preserved", 5, loaded_chain.count)

			-- Clean up
			create l_file.make_with_path (path)
			if l_file.exists then l_file.delete end
		end

	test_roundtrip_preserves_content
			-- Test that item content is preserved through save/load cycle.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			loaded_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
			path: PATH
			l_file: RAW_FILE
		do
			-- Create chain with named item
			create chain.make
			create item.make_with_name ("test_item", 123)
			chain.extend (item)

			create path.make_from_string ("content_test.dat")
			chain.save_as (path)

			-- Load and verify content
			create loaded_chain.make_from_file (path)
			assert_integers_equal ("count_one", 1, loaded_chain.count)

			-- Verify item properties
			loaded_chain.start
			if attached loaded_chain.item as l_item then
				assert_integers_equal ("value_123", 123, l_item.value)
			end

			-- Clean up
			create l_file.make_with_path (path)
			if l_file.exists then l_file.delete end
		end

	test_empty_chain_save_and_load
			-- Test saving and loading an empty chain.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			loaded_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			path: PATH
			l_file: RAW_FILE
		do
			-- Create and save empty chain
			create chain.make
			create path.make_from_string ("empty_test.dat")
			chain.save_as (path)

			-- Load and verify empty
			create loaded_chain.make_from_file (path)
			assert_integers_equal ("count_zero", 0, loaded_chain.count)
			assert_true ("is_empty", loaded_chain.is_empty)

			-- Clean up
			create l_file.make_with_path (path)
			if l_file.exists then l_file.delete end
		end

feature -- Tier 3: State Verification

	test_chain_state_after_operations
			-- Test that chain maintains consistent state after operations.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		do
			create chain.make

			-- Add items
			create item.make_default
			chain.extend (item)
			create item.make_default
			chain.extend (item)

			-- Move cursor and verify state
			chain.start
			assert_integers_equal ("index_1", 1, chain.index)
			assert_false ("not_before", chain.before)
			assert_false ("not_after", chain.after)

			-- Move to end
			chain.finish
			assert_integers_equal ("index_2", 2, chain.index)
		end

	test_cursor_validity_after_navigation
			-- Test cursor stays valid after various navigation operations.
		local
			chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			item: SP_TEST_ITEM
		do
			create chain.make
			create item.make_default
			chain.extend (item)
			create item.make_default
			chain.extend (item)
			create item.make_default
			chain.extend (item)

			-- Navigate forward
			chain.start
			chain.forth
			chain.forth
			assert_integers_equal ("at_position_3", 3, chain.index)

			-- Navigate backward
			chain.back
			assert_integers_equal ("at_position_2", 2, chain.index)

			-- Jump to position
			chain.go_i_th (1)
			assert_integers_equal ("at_position_1", 1, chain.index)
		end

end
