note
	description: "Test application for simple_persist"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
		-- Run tests
		do
			print ("simple_persist tests%N")
			test_create_chain
			test_facade_creation
			test_writer_reader_roundtrip
			test_chain_extend
			test_chain_cursor
			test_chain_remove
			test_query_basic
			test_index_basic
			-- Adversarial tests (X04)
			test_empty_string_serialization
			test_query_on_empty_chain
			test_index_edge_cases
			print ("All tests passed%N")
		end

feature -- Tests

	test_create_chain
		-- Test creating an empty chain
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
		do
			print ("  test_create_chain: ")
			create l_chain.make
			check chain_empty: l_chain.is_empty end
			check chain_count_zero: l_chain.count = 0 end
			print ("PASS%N")
		end

	test_facade_creation
		-- Test creating the facade
		local
			l_persist: SIMPLE_PERSIST
		do
			print ("  test_facade_creation: ")
			create l_persist.make
			check no_error: not l_persist.has_error end
			print ("PASS%N")
		end

	test_writer_reader_roundtrip
		-- Test writing and reading values
		local
			l_writer: SP_WRITER
			l_reader: SP_READER
		do
			print ("  test_writer_reader_roundtrip: ")
			create l_writer.make (100)
			l_writer.put_integer_32 (42)
			l_writer.put_string ("Hello")
			l_writer.put_boolean (True)

			create l_reader.make_from_buffer (l_writer.buffer, l_writer.count)
			check int_matches: l_reader.read_integer_32 = 42 end
			check string_matches: l_reader.read_string.same_string ("Hello") end
			check bool_matches: l_reader.read_boolean = True end
			print ("PASS%N")
		end

	test_chain_extend
		-- Test extending chain with items
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			l_item1, l_item2: SP_TEST_ITEM
		do
			print ("  test_chain_extend: ")
			create l_chain.make
			create l_item1.make_with_name ("Item1", 10)
			create l_item2.make_with_name ("Item2", 20)

			l_chain.extend (l_item1)
			l_chain.extend (l_item2)

			check count_is_two: l_chain.count = 2 end
			check first_correct: l_chain.first.name.same_string ("Item1") end
			check last_correct: l_chain.last.name.same_string ("Item2") end
			print ("PASS%N")
		end

	test_chain_cursor
		-- Test chain cursor operations
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			l_item1, l_item2, l_item3: SP_TEST_ITEM
		do
			print ("  test_chain_cursor: ")
			create l_chain.make
			create l_item1.make_with_name ("A", 1)
			create l_item2.make_with_name ("B", 2)
			create l_item3.make_with_name ("C", 3)
			l_chain.extend (l_item1)
			l_chain.extend (l_item2)
			l_chain.extend (l_item3)

			l_chain.start
			check at_first: l_chain.item.name.same_string ("A") end
			l_chain.forth
			check at_second: l_chain.item.name.same_string ("B") end
			l_chain.finish
			check at_last: l_chain.item.name.same_string ("C") end
			l_chain.back
			check back_to_second: l_chain.item.name.same_string ("B") end
			print ("PASS%N")
		end

	test_chain_remove
		-- Test removing items from chain
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			l_item1, l_item2: SP_TEST_ITEM
		do
			print ("  test_chain_remove: ")
			create l_chain.make
			create l_item1.make_with_name ("Keep", 1)
			create l_item2.make_with_name ("Remove", 2)
			l_chain.extend (l_item1)
			l_chain.extend (l_item2)

			l_chain.start
			l_chain.forth
			l_chain.remove

			check count_is_one: l_chain.count = 1 end
			check remaining_correct: l_chain.first.name.same_string ("Keep") end
			print ("PASS%N")
		end

	test_query_basic
		-- Test basic query operations
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			l_query: SP_QUERY [SP_TEST_ITEM]
			l_results: ARRAYED_LIST [SP_TEST_ITEM]
			l_item1, l_item2, l_item3: SP_TEST_ITEM
		do
			print ("  test_query_basic: ")
			create l_chain.make
			create l_item1.make_with_name ("A", 10)
			create l_item2.make_with_name ("B", 20)
			create l_item3.make_with_name ("C", 30)
			l_chain.extend (l_item1)
			l_chain.extend (l_item2)
			l_chain.extend (l_item3)

			create l_query.make (l_chain)
			l_results := l_query.where (agent (it: SP_TEST_ITEM): BOOLEAN do Result := it.value > 15 end).results

			check two_results: l_results.count = 2 end
			print ("PASS%N")
		end

	test_index_basic
		-- Test basic index operations
		local
			l_index: SP_HASH_INDEX [SP_TEST_ITEM, STRING_32]
			l_item1, l_item2, l_item3: SP_TEST_ITEM
			l_items: LIST [SP_TEST_ITEM]
		do
			print ("  test_index_basic: ")
			create l_index.make ("name_index", agent (it: SP_TEST_ITEM): STRING_32 do Result := it.name end)

			create l_item1.make_with_name ("Alpha", 1)
			create l_item2.make_with_name ("Alpha", 2)
			create l_item3.make_with_name ("Beta", 3)

			l_index.on_extend (l_item1)
			l_index.on_extend (l_item2)
			l_index.on_extend (l_item3)

			check two_keys: l_index.key_count = 2 end
			check three_items: l_index.item_count = 3 end

			l_items := l_index.items_for_key ("Alpha")
			check two_alphas: l_items.count = 2 end
			print ("PASS%N")
		end

feature -- Adversarial Tests (X04)

	test_empty_string_serialization
		-- Test serializing and deserializing empty string
		local
			l_writer: SP_WRITER
			l_reader: SP_READER
			l_result: STRING_32
		do
			print ("  test_empty_string_serialization: ")
			create l_writer.make (100)
			l_writer.put_string ("")

			create l_reader.make_from_buffer (l_writer.buffer, l_writer.count)
			l_result := l_reader.read_string

			check empty_result: l_result.is_empty end
			check result_count_zero: l_result.count = 0 end
			print ("PASS%N")
		end

	test_query_on_empty_chain
		-- Test querying an empty chain
		local
			l_chain: SP_ARRAYED_CHAIN [SP_TEST_ITEM]
			l_query: SP_QUERY [SP_TEST_ITEM]
			l_results: ARRAYED_LIST [SP_TEST_ITEM]
		do
			print ("  test_query_on_empty_chain: ")
			create l_chain.make
			create l_query.make (l_chain)

			l_results := l_query.where (agent (it: SP_TEST_ITEM): BOOLEAN do Result := True end).results

			check results_attached: l_results /= Void end
			check results_empty: l_results.is_empty end
			check query_is_empty: l_query.is_empty end
			print ("PASS%N")
		end

	test_index_edge_cases
		-- Test index operations on edge cases
		local
			l_index: SP_HASH_INDEX [SP_TEST_ITEM, STRING_32]
			l_items: LIST [SP_TEST_ITEM]
		do
			print ("  test_index_edge_cases: ")
			create l_index.make ("test_index", agent (it: SP_TEST_ITEM): STRING_32 do Result := it.name end)

			-- Test querying non-existent key
			l_items := l_index.items_for_key ("NonExistent")
			check no_items: l_items.is_empty end

			-- Test empty index stats
			check zero_keys: l_index.key_count = 0 end
			check zero_items: l_index.item_count = 0 end

			-- Test wipe_out on empty index (should not crash)
			l_index.wipe_out
			check still_zero: l_index.key_count = 0 end
			print ("PASS%N")
		end

end
