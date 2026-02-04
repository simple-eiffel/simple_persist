note
	description: "Test application for SIMPLE_PERSIST"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_PERSIST tests...%N%N")
			passed := 0
			failed := 0

			print ("-- Tier 1: Empty Chain Tests --%N")
			run_lib_tests

			print ("%N-- Tier 2: Populated Chain Tests --%N")
			run_populated_chain_tests

			print ("%N-- Tier 3: Persistence Tests --%N")
			run_persistence_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		local
			tests: LIB_TESTS
		do
			create tests
			-- Tier 1: Empty Chain Tests
			run_test (agent tests.test_empty_chain_creation, "test_empty_chain_creation")
			run_test (agent tests.test_empty_chain_cursor_position, "test_empty_chain_cursor_position")
			run_test (agent tests.test_chain_with_capacity, "test_chain_with_capacity")
			run_test (agent tests.test_extend_single_item, "test_extend_single_item")
			run_test (agent tests.test_extend_multiple_items, "test_extend_multiple_items")
			run_test (agent tests.test_first_item_access, "test_first_item_access")
			run_test (agent tests.test_cursor_start_position, "test_cursor_start_position")
			run_test (agent tests.test_cursor_finish_position, "test_cursor_finish_position")
		end

	run_populated_chain_tests
		local
			tests: POPULATED_CHAIN_TESTS
		do
			create tests
			-- Tier 2: Populated Chain Tests
			run_test (agent tests.test_cursor_movement_forth, "test_cursor_movement_forth")
			run_test (agent tests.test_cursor_movement_back, "test_cursor_movement_back")
			run_test (agent tests.test_cursor_go_i_th, "test_cursor_go_i_th")
			run_test (agent tests.test_item_at_first, "test_item_at_first")
			run_test (agent tests.test_item_at_last, "test_item_at_last")
			run_test (agent tests.test_i_th_access, "test_i_th_access")
			run_test (agent tests.test_first_item, "test_first_item")
			run_test (agent tests.test_last_item, "test_last_item")
			run_test (agent tests.test_has_item, "test_has_item")
			run_test (agent tests.test_chain_not_empty, "test_chain_not_empty")
			run_test (agent tests.test_iterate_all_items, "test_iterate_all_items")
		end

	run_persistence_tests
		local
			tests: PERSISTENCE_TESTS
		do
			create tests
			-- Tier 3: Persistence Tests
			run_test (agent tests.test_save_chain_to_file, "test_save_chain_to_file")
			run_test (agent tests.test_roundtrip_preserves_count, "test_roundtrip_preserves_count")
			run_test (agent tests.test_roundtrip_preserves_content, "test_roundtrip_preserves_content")
			run_test (agent tests.test_empty_chain_save_and_load, "test_empty_chain_save_and_load")
			run_test (agent tests.test_chain_state_after_operations, "test_chain_state_after_operations")
			run_test (agent tests.test_cursor_validity_after_navigation, "test_cursor_validity_after_navigation")
		end

feature {NONE} -- Implementation

	passed, failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
