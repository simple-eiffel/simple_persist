note
	description: "Fluent query builder for filtering chain items"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SP_QUERY [G -> SP_STORABLE]

create
	make

feature {NONE} -- Initialization

	make (a_chain: SP_CHAIN [G])
		-- Create query on given chain
		require
			chain_attached: a_chain /= Void
		do
			chain := a_chain
			create conditions.make (5)
			max_results := 0
			skip_count := 0
			is_descending := False
		end

feature -- Access

	chain: SP_CHAIN [G]
		-- Chain being queried

	results: ARRAYED_LIST [G]
		-- Execute query and return matching items
		local
			l_item: G
			l_match: BOOLEAN
			l_skip, l_count: INTEGER
		do
			create Result.make (10)
			from chain.start until chain.after loop
				l_item := chain.item
				if not l_item.is_deleted then
					l_match := evaluate (l_item)
					if l_match then
						if l_skip < skip_count then
							l_skip := l_skip + 1
						else
							Result.extend (l_item)
							l_count := l_count + 1
							if max_results > 0 and l_count >= max_results then
								chain.finish
								chain.forth
							end
						end
					end
				end
				chain.forth
			end
			if is_descending then
				reverse_list (Result)
			end
	ensure
		result_attached: Result /= Void
		bounded: max_results > 0 implies Result.count <= max_results
	end

	first_result: detachable G
		-- Execute query and return first match, or Void
		local
			l_results: like results
		do
			max_results := 1
			l_results := results
			if not l_results.is_empty then
				Result := l_results.first
			end
		end

	result_count: INTEGER
		-- Execute query and return count of matches
		do
			Result := results.count
		end

feature -- Conditions

	where (a_condition: FUNCTION [G, BOOLEAN]): like Current
		-- Add filter condition
		require
			condition_attached: a_condition /= Void
		do
			conditions.extend ([a_condition, Combiner_and])
			Result := Current
		end

	and_where (a_condition: FUNCTION [G, BOOLEAN]): like Current
		-- Add condition with AND
		require
			condition_attached: a_condition /= Void
		do
			conditions.extend ([a_condition, Combiner_and])
			Result := Current
		end

	or_where (a_condition: FUNCTION [G, BOOLEAN]): like Current
		-- Add condition with OR
		require
			condition_attached: a_condition /= Void
		do
			conditions.extend ([a_condition, Combiner_or])
			Result := Current
		end

	not_where (a_condition: FUNCTION [G, BOOLEAN]): like Current
		-- Add negated condition
		require
			condition_attached: a_condition /= Void
		do
			conditions.extend ([agent negated_condition (a_condition, ?), Combiner_and])
			Result := Current
		end

feature -- Limiting

	take (n: INTEGER): like Current
		-- Limit results to first n items
		require
			non_negative: n >= 0
		do
			max_results := n
			Result := Current
		end

	skip (n: INTEGER): like Current
		-- Skip first n matching items
		require
			non_negative: n >= 0
		do
			skip_count := n
			Result := Current
		end

feature -- Ordering

	order_by (a_comparator: FUNCTION [G, G, BOOLEAN]): like Current
		-- Order results using comparator
		require
			comparator_attached: a_comparator /= Void
		do
			comparator := a_comparator
			Result := Current
		end

	order_descending: like Current
		-- Reverse order of results
		do
			is_descending := True
			Result := Current
		end

feature -- Status

	is_empty: BOOLEAN
		-- Does query match no items?
		do
			Result := result_count = 0
		end

	has_results: BOOLEAN
		-- Does query match any items?
		do
			Result := result_count > 0
		end

feature {NONE} -- Implementation

	conditions: ARRAYED_LIST [TUPLE [condition: FUNCTION [G, BOOLEAN]; combiner: INTEGER]]
		-- List of conditions with combiners (AND=1, OR=2)

	max_results: INTEGER
		-- Maximum number of results (0 = unlimited)

	skip_count: INTEGER
		-- Number of results to skip

	comparator: detachable FUNCTION [G, G, BOOLEAN]
		-- Ordering comparator

	is_descending: BOOLEAN
		-- Should order be reversed?

	Combiner_and: INTEGER = 1
	Combiner_or: INTEGER = 2

	evaluate (a_item: G): BOOLEAN
		-- Evaluate all conditions against item
		local
			l_result: BOOLEAN
			l_tuple: TUPLE [condition: FUNCTION [G, BOOLEAN]; combiner: INTEGER]
			l_cond: FUNCTION [G, BOOLEAN]
			l_comb: INTEGER
			i: INTEGER
		do
			if conditions.is_empty then
				Result := True
			else
				l_result := True
				from i := 1 until i > conditions.count loop
					l_tuple := conditions.i_th (i)
					l_cond := l_tuple.condition
					l_comb := l_tuple.combiner
					if l_comb = Combiner_and then
						l_result := l_result and l_cond.item ([a_item])
					else
						l_result := l_result or l_cond.item ([a_item])
					end
					i := i + 1
				end
				Result := l_result
			end
		end

	negated_condition (a_condition: FUNCTION [G, BOOLEAN]; a_item: G): BOOLEAN
		-- Negate condition result
		do
			Result := not a_condition.item ([a_item])
		end

	reverse_list (a_list: ARRAYED_LIST [G])
		-- Reverse list in place
		local
			i, j: INTEGER
			temp: G
		do
			from
				i := 1
				j := a_list.count
			until
				i >= j
			loop
				temp := a_list.i_th (i)
				a_list.put_i_th (a_list.i_th (j), i)
				a_list.put_i_th (temp, j)
				i := i + 1
				j := j - 1
			end
		end

invariant
	chain_attached: chain /= Void
	conditions_attached: conditions /= Void
	max_results_non_negative: max_results >= 0
	skip_count_non_negative: skip_count >= 0

end
