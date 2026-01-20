# CLASS SPECIFICATION: SP_QUERY

## Identity
- **Role:** HELPER
- **Domain Concept:** Fluent query builder

## Purpose

This class represents: A builder for constructing and executing chain queries
This class is responsible for: Accumulating filter conditions and executing against chain
This class guarantees: Chain exists, conditions list exists, non-negative limits

## Creation

### CREATION: make
- **Signature:** (a_chain: SP_CHAIN [G])
- **Purpose:** Create query targeting given chain
- **Preconditions:**
  - chain_attached: a_chain /= Void
- **Postconditions:** NONE (gap)
- **Initial State:**
  - chain = a_chain
  - conditions = new ARRAYED_LIST(5)
  - max_results = 0 (unlimited)
  - skip_count = 0
  - is_descending = False
  - comparator = Void

## Queries

### QUERY: chain
- **Signature:** () → SP_CHAIN [G]
- **Purpose:** Access target chain
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** YES

### QUERY: results
- **Signature:** () → ARRAYED_LIST [G]
- **Purpose:** Execute query and return matching items
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should ensure Result /= Void)
- **Pure:** NO (iterates chain, modifies cursor)
- **Behavior:**
  1. Iterate chain from start
  2. Skip deleted items
  3. Evaluate all conditions (AND/OR)
  4. Skip first `skip_count` matches
  5. Collect up to `max_results` (0 = unlimited)
  6. Reverse if `is_descending`

### QUERY: first_result
- **Signature:** () → detachable G
- **Purpose:** Execute query and return first match
- **Preconditions:** NONE
- **Postconditions:** NONE
- **Pure:** NO
- **Behavior:** Sets max_results = 1, calls results, returns first or Void

### QUERY: result_count
- **Signature:** () → INTEGER
- **Purpose:** Execute query and return count of matches
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = results.count)
- **Pure:** NO

### QUERY: is_empty
- **Signature:** () → BOOLEAN
- **Purpose:** Does query match nothing?
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = result_count = 0)
- **Pure:** NO (executes query)

### QUERY: has_results
- **Signature:** () → BOOLEAN
- **Purpose:** Does query match anything?
- **Preconditions:** NONE
- **Postconditions:** NONE (implicit: Result = result_count > 0)
- **Pure:** NO (executes query)

## Commands (Fluent Builder Pattern)

### COMMAND: where
- **Signature:** (a_condition: FUNCTION [G, BOOLEAN]) → like Current
- **Purpose:** Add filter condition (first or AND)
- **Preconditions:**
  - condition_attached: a_condition /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** conditions
- **Returns:** Current (for chaining)

### COMMAND: and_where
- **Signature:** (a_condition: FUNCTION [G, BOOLEAN]) → like Current
- **Purpose:** Add condition with AND combiner
- **Preconditions:**
  - condition_attached: a_condition /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** conditions
- **Returns:** Current

### COMMAND: or_where
- **Signature:** (a_condition: FUNCTION [G, BOOLEAN]) → like Current
- **Purpose:** Add condition with OR combiner
- **Preconditions:**
  - condition_attached: a_condition /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** conditions
- **Returns:** Current

### COMMAND: not_where
- **Signature:** (a_condition: FUNCTION [G, BOOLEAN]) → like Current
- **Purpose:** Add negated condition with AND
- **Preconditions:**
  - condition_attached: a_condition /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** conditions
- **Returns:** Current

### COMMAND: take
- **Signature:** (n: INTEGER) → like Current
- **Purpose:** Limit results to first n items
- **Preconditions:**
  - non_negative: n >= 0
- **Postconditions:** NONE (gap - should ensure max_results = n)
- **Modifies:** max_results
- **Returns:** Current

### COMMAND: skip
- **Signature:** (n: INTEGER) → like Current
- **Purpose:** Skip first n matching items
- **Preconditions:**
  - non_negative: n >= 0
- **Postconditions:** NONE (gap - should ensure skip_count = n)
- **Modifies:** skip_count
- **Returns:** Current

### COMMAND: order_by
- **Signature:** (a_comparator: FUNCTION [G, G, BOOLEAN]) → like Current
- **Purpose:** Set ordering comparator
- **Preconditions:**
  - comparator_attached: a_comparator /= Void
- **Postconditions:** NONE (gap)
- **Modifies:** comparator
- **Returns:** Current
- **Note:** Currently stored but not used in results!

### COMMAND: order_descending
- **Signature:** () → like Current
- **Purpose:** Reverse result order
- **Preconditions:** NONE
- **Postconditions:** NONE (gap - should ensure is_descending = True)
- **Modifies:** is_descending
- **Returns:** Current

## Implementation Details

### Constants
- `Combiner_and: INTEGER = 1`
- `Combiner_or: INTEGER = 2`

### evaluate (private)
- **Signature:** (a_item: G) → BOOLEAN
- **Purpose:** Evaluate all conditions against item
- **Behavior:**
  - Empty conditions → True
  - Accumulate: start with True, apply AND/OR per condition
  - Note: First condition uses AND (starts from True)

### negated_condition (private)
- **Signature:** (a_condition: FUNCTION [G, BOOLEAN]; a_item: G) → BOOLEAN
- **Purpose:** Return negation of condition result

### reverse_list (private)
- **Signature:** (a_list: ARRAYED_LIST [G])
- **Purpose:** Reverse list in place for descending order

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| chain_attached | chain /= Void | Query always targets a chain |
| conditions_attached | conditions /= Void | Condition list always exists |
| max_results_non_negative | max_results >= 0 | Cannot limit to negative |
| skip_count_non_negative | skip_count >= 0 | Cannot skip negative |

## Dependencies

- **Inherits:** (none)
- **Uses:** SP_CHAIN [G], FUNCTION [G, BOOLEAN], FUNCTION [G, G, BOOLEAN], ARRAYED_LIST [G], TUPLE
- **Creates:** ARRAYED_LIST [G]

**Coupling assessment:** MEDIUM (uses SP_CHAIN, agents)

## Contract Coverage

| Metric | Count | Percent |
|--------|-------|---------|
| Features with preconditions | 7/15 | 47% |
| Features with postconditions | 0/15 | 0% |
| Has class invariant | YES | 4 clauses |

**Overall specification quality:** MODERATE

### Gaps Identified
- `make`: missing postcondition for initial state
- `results`: missing postcondition `Result /= Void`
- All fluent methods: missing postconditions for state changes
- `order_by`: comparator is stored but never used! (BUG)
- `results` modifies chain cursor (side effect concern)

### Design Issues
1. **Comparator unused**: `order_by` sets comparator but `results` doesn't sort
2. **Cursor pollution**: Query execution modifies chain's cursor position
3. **Condition evaluation**: First condition always ANDed with True (odd semantics for single OR condition)
