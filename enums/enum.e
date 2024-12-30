note
	description: "[
			Provides common enumerable operations like map, filter, reduce etc.
		]"

class
	ENUM [G]

inherit
	ITERABLE [G]

create
	make

feature {NONE} -- Initialization

	make (a_iterable: ITERABLE [G])
			-- Create a new enum from an iterable
		do
			iterable := a_iterable
		end


feature -- Access

	iterable: ITERABLE [G]
			-- Underlying iterable collection

feature -- Basic Operations

	map (a_mapper: FUNCTION [G, G]): ENUM [G]
			-- Returns a new enum where each element is mapped to the same type
		local
			l_result: ARRAYED_LIST [G]
		do
			create l_result.make (count)
			across iterable as ic loop
				l_result.extend (a_mapper.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_any (a_mapper: FUNCTION [G, ANY]): ENUM [ANY]
			-- Returns a new enum where each element is mapped to ANY
		local
			l_result: ARRAYED_LIST [ANY]
		do
			create l_result.make (count)
			across iterable as ic loop
				l_result.force (a_mapper.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_integer (a_mapper: FUNCTION [G, INTEGER]): ENUM [INTEGER]
			-- Returns a new enum where each element is mapped to INTEGER
		local
			l_result: ARRAYED_LIST [INTEGER]
		do
			create l_result.make (count)
			across iterable as ic loop
				l_result.extend (a_mapper.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_string (a_mapper: FUNCTION [G, STRING]): ENUM [STRING_GENERAL]
			-- Returns a new enum where each element is mapped to STRING
		local
			l_result: ARRAYED_LIST [STRING_GENERAL]
		do
			create l_result.make (count)
			across iterable as ic loop
				l_result.extend (a_mapper.item (ic))
			end
			create Result.make (l_result)
		end

	filter (a_predicate: PREDICATE [G]): ENUM [G]
			-- Returns only the elements for which a_predicate returns true
		local
			l_result: ARRAYED_LIST [G]
		do
			create l_result.make (count)
			across iterable as ic loop
				if a_predicate.item (ic) then
					l_result.extend (ic)
				end
			end
			create Result.make (l_result)
		end

	reduce (a_reducer: FUNCTION [G, G, G]): detachable G
			-- Reduce the items of the stream applying the function `a_function`.
		local
			l_result: G
			found: BOOLEAN
		do
			across iterable as ic loop
				if found and attached l_result as res then
					l_result := a_reducer.item (res, ic)
				else
					l_result := ic
					found := True
				end
			end

			Result := l_result
		end

	reduce_with_predicate (a_predicate: PREDICATE [G, G]): detachable G
			-- Reduce the items of the stream applying the predicate `a_predicate`.
		local
			l_result: G
			found: BOOLEAN
		do
			across iterable as ic loop
				if found and attached l_result as res then
					if a_predicate.item (res, ic) then
						l_result := res
					else
						l_result := ic
					end
				else
					l_result := ic
					found := True
				end
			end

			Result := l_result
		end

	frequencies (a_comparator: PREDICATE [G, G]): ENUM [TUPLE [element: G; len: INTEGER]]
			-- Returns enumerable of tuples containing unique elements and their frequencies
			-- Uses a_comparator for element equality comparison
		local
			l_result: ARRAYED_LIST [TUPLE [element: G; len: INTEGER]]
		do
			create l_result.make (10)

				-- Count frequencies using list of tuples
			across iterable as ic loop
				find_and_increment_or_add (l_result, ic, a_comparator)
			end

			create Result.make (l_result)
		end

	zip (a_iterables: ITERABLE [ITERABLE [ANY]]): ENUM [ITERABLE [ANY]]
			-- Zips corresponding elements from all iterables into tuples
		local
			l_result: ARRAYED_LIST [ITERABLE [ANY]]
			l_cursors: ARRAYED_LIST [ITERATION_CURSOR [ANY]]
			l_current_items: ARRAYED_LIST [ANY]
			l_cursor_index: INTEGER
		do
			create l_cursors.make (0)
			create l_result.make (count_of_shortest (a_iterables))

				-- Initialize cursors for all iterables
			across a_iterables as l_iterable loop
				l_cursors.extend (l_iterable.new_cursor)
			end

			from
			until
				cursors_exhausted (l_cursors)
			loop
					-- Create list with current items
				create l_current_items.make (l_cursors.count)
				across l_cursors as ic loop
					l_current_items.extend (ic.item)
				end
				l_result.extend (l_current_items)

					-- Advance all cursors
				across l_cursors as ic loop
					ic.forth
				end
			end

			create Result.make (l_result)
		end

feature {NONE} -- Implementation

	count_of_shortest (a_iterables: ITERABLE [ITERABLE [ANY]]): INTEGER
			-- Returns count of shortest iterable
		local
			l_count: INTEGER
			l_min_count: INTEGER
			l_first: BOOLEAN
		do
			l_first := True
			across a_iterables as l_iterable loop
				l_count := 0
				across l_iterable as ic loop
					l_count := l_count + 1
				end
				if l_first then
					l_min_count := l_count
					l_first := False
				else
					l_min_count := l_min_count.min (l_count)
				end
			end
			Result := l_min_count
		end

	cursors_exhausted (a_cursors: ARRAYED_LIST [ITERATION_CURSOR [ANY]]): BOOLEAN
			-- Returns True if any cursor has reached its end
		do
			if a_cursors.is_empty then
				Result := True
			else
				Result := False
				across a_cursors as ic loop
					if ic.after then
						Result := True
					end
				end
			end
		end

	find_and_increment_or_add (a_list: ARRAYED_LIST [TUPLE [element: G; len: INTEGER]];
			an_element: G;
			a_comparator: PREDICATE [G, G])
			-- Find element in list and increment its count, or add new entry if not found
			-- Uses a_comparator for element equality comparison
		local
			found: BOOLEAN
		do
			across a_list as entry loop
				if a_comparator.item (entry.element, an_element) then
					entry.len := entry.len + 1
					found := True
				end
			end

			if not found then
				a_list.extend ([an_element, 1])
			end
		end

feature -- Indexing

	with_index: ENUM [TUPLE [elem: G; index: INTEGER]]
			-- Returns enumerable with each element paired with its index (0-based)
		local
			l_result: ARRAYED_LIST [TUPLE [elem: G; index: INTEGER]]
			l_index: INTEGER
		do
			create l_result.make (count)
			from
				l_index := 0
			until
				l_index >= count
			loop
				across iterable as ic loop
					l_result.extend ([ic, l_index])
					l_index := l_index + 1
				end
			end
			create Result.make (l_result)
		end

	with_index_offset (a_offset: INTEGER): ENUM [TUPLE [elem: G; index: INTEGER]]
			-- Returns enumerable with each element paired with its index starting from offset
		local
			l_result: ARRAYED_LIST [TUPLE [elem: G; index: INTEGER]]
			l_index: INTEGER
		do
			create l_result.make (count)
			from
				l_index := a_offset
			until
				l_index >= count + a_offset
			loop
				across iterable as ic loop
					l_result.extend ([ic, l_index])
					l_index := l_index + 1
				end
			end
			create Result.make (l_result)
		end

feature -- Predicate

	there_is_any (a_predicate: PREDICATE [G]): BOOLEAN
			-- Returns true if a_predicate returns true for any element
		do
			across iterable as ic until Result loop
				Result := a_predicate.item (ic)
			end
		end

	for_all (a_predicate: PREDICATE [G]): BOOLEAN
			-- Returns true if a_predicate returns true for all elements
		do
			Result := True
			across iterable as ic until not Result loop
				Result := a_predicate.item (ic)
			end
		end

	has (a_element: G): BOOLEAN
			-- Checks if element exists within the enumerable
			-- Uses object equality for comparison
		do
			across iterable as ic until Result loop
				Result := ic ~ a_element
			end
		end

feature -- Drop

	drop (n: INTEGER): ENUM [G]
			-- Drops first n elements
		local
			l_result: ARRAYED_LIST [G]
			l_count: INTEGER
		do
			create l_result.make (count - n)
			across iterable as ic loop
				if l_count >= n then
					l_result.force (ic)
				end
				l_count := l_count + 1
			end
			create Result.make (l_result)
		end

feature -- Split Collection

	take (n: INTEGER): ENUM [G]
			-- Takes first n elements
		local
			l_result: ARRAYED_LIST [G]
			l_count: INTEGER
		do
			if n < 0 then
				create l_result.make (0)
			else
				create l_result.make (n.min (count))
			end
			across iterable as ic until l_count >= n loop
				l_result.force (ic)
				l_count := l_count + 1
			end
			create Result.make (l_result)
		end

	take_every (n: INTEGER): ENUM [G]
			-- Takes every nth element
		local
			l_result: ARRAYED_LIST [G]
			l_count: INTEGER
		do
			if n <= 0 then
				create Result.make (create {ARRAYED_LIST [G]}.make (0))
			else
				create l_result.make (count // n + 1)
				if n > 0 then
					across iterable as ic loop
						l_count := l_count + 1
						if (l_count - 1) \\ n = 0 then
							l_result.extend (ic)
						end
					end
				end
				create Result.make (l_result)
			end
		end

	take_while (a_predicate: PREDICATE [G]): ENUM [G]
			-- Takes elements from the beginning while predicate returns true
		local
			l_result: ARRAYED_LIST [G]
			continue: BOOLEAN
		do
			create l_result.make (count)
			continue := True

			across iterable as ic until not continue loop
				if a_predicate.item (ic) then
					l_result.extend (ic)
				else
					continue := False
				end
			end

			create Result.make (l_result)
		end

	split (n: INTEGER): TUPLE [first, second: ENUM [G]]
			-- Splits the enumerable into two enumerables, leaving n elements in the first one
			-- If n is negative, counts from the back
		local
			l_first, l_second: ARRAYED_LIST [G]
			l_split_point: INTEGER
		do
			if n < 0 then
					-- For negative n, calculate split point from end
				l_split_point := count + n
			else
					-- For positive n, if n is larger than count, split point is count
				l_split_point := n.min (count)
			end

				-- Ensure split point is not negative
			l_split_point := l_split_point.max (0)

			create l_first.make (l_split_point)
			create l_second.make (count - l_split_point)

			across iterable as ic loop
				if l_first.count < l_split_point then
					l_first.extend (ic)
				else
					l_second.extend (ic)
				end
			end

			Result := [create {ENUM [G]}.make (l_first),
				create {ENUM [G]}.make (l_second)]
		end

	split_while (a_predicate: PREDICATE [G]): TUPLE [first, second: ENUM [G]]
			-- Splits enumerable in two at the position where predicate first returns false
			-- The element that fails the predicate is part of the second list
		local
			l_first, l_second: ARRAYED_LIST [G]
			continue: BOOLEAN
		do
			create l_first.make (count)
			create l_second.make (count)
			continue := False

			across iterable as ic loop
				if a_predicate.item (ic) and not continue then
					l_first.extend (ic)
				else
					continue := True
					l_second.extend (ic)
				end
			end

			Result := [create {ENUM [G]}.make (l_first),
				create {ENUM [G]}.make (l_second)]
		end

feature -- Concatenation

	concat (a_other: ITERABLE [G]): ENUM [G]
			-- Concatenates two iterables into a new enum
		local
			l_result: ARRAYED_LIST [G]
		do
			create l_result.make (count + count_of_iterable (a_other))

				-- Add elements from current iterable
			across iterable as ic loop
				l_result.extend (ic)
			end

				-- Add elements from other iterable
			across a_other as ic loop
				l_result.extend (ic)
			end

			create Result.make (l_result)
		end

	concat_any (a_other: ITERABLE [ANY]): ENUM [ANY]
			-- Concatenates with any iterable, converting current elements to ANY
		local
			l_result: ARRAYED_LIST [ANY]
		do
			create l_result.make (count + count_of_iterable_any (a_other))

				-- Add elements from current iterable
			across iterable as ic loop
				if attached {ANY} ic as i then
					l_result.force (i)
				end
			end

				-- Add elements from other iterable
			across a_other as ic loop
				l_result.extend (ic)
			end

			create Result.make (l_result)
		end

feature -- Select

	at_with_default (a_index: INTEGER; a_default_value: G): G
			-- Returns the element at position `a_index` (1-based)
			-- If position is invalid, returns `a_default_value`
		local
			l_count: INTEGER
		do
			Result := a_default_value
			if a_index > 0 then
					-- do nothing.
			else
				across iterable as ic loop
					l_count := l_count + 1
					if l_count = a_index then
						Result := ic
					end
				end
				if l_count < a_index then
					Result := a_default_value
				end
			end
		end

	at (a_index: INTEGER): G
			-- Returns the element at position `a_index` (1-based)
			-- If position is invalid, returns default value of type
		require
			valid_index: (1 <= a_index) and (a_index <= count)
		do
			Result := (create {ARRAYED_LIST [G]}.make_from_iterable (iterable)).at (a_index)
		end

	reject (a_predicate: PREDICATE [G]): ENUM [G]
			-- Returns only the elements for which a_predicate returns false
		local
			l_result: ARRAYED_LIST [G]
		do
			create l_result.make (count)
			across iterable as ic loop
				if not a_predicate.item (ic) then
					l_result.extend (ic)
				end
			end
			create Result.make (l_result)
		end

feature -- Sort

	sort (a_comparator: PREDICATE [G, G]): ENUM [G]
			-- Returns a new enum with elements sorted according to comparator
		local
			l_sorter: SORTER [G]
			l_list: ARRAYED_LIST [G]
		do
			create l_list.make_from_iterable (iterable)
			create {QUICK_SORTER [G]} l_sorter.make (
				create {AGENT_EQUALITY_TESTER [G]}.make (a_comparator))
			l_sorter.sort (l_list)
			create Result.make (l_list)
		end

feature -- Compare

	max (a_comparator: PREDICATE [G, G]): G
			-- Returns the maximum element in the collection
			-- Requires collection to be non-empty
		require
			not_empty: count > 0
		local
			l_cursor: ITERATION_CURSOR [G]
		do
			l_cursor := new_cursor
			Result := l_cursor.item -- Start with first element
			l_cursor.forth

			from
			until
				l_cursor.after
			loop
				if a_comparator.item (l_cursor.item, Result) then
					Result := l_cursor.item
				end
				l_cursor.forth
			end
		end

feature -- String Operations

	join: STRING
			-- Joins all elements into a string with empty separator
		do
			Result := join_with ("")
		end

	join_with (a_joiner: STRING): STRING
			-- Joins all elements into a string with given joiner
		local
			first_element: BOOLEAN
		do
			create Result.make_empty
			first_element := True

			across iterable as ic loop
				if not first_element then
					Result.append (a_joiner)
				end
				Result.append (to_string_imp (ic))
				first_element := False
			end
		end

feature {NONE} -- Implementation

	to_string_imp (a_item: G): STRING
		do
			Result := if attached a_item then create {STRING}.make_from_separate (a_item.out) else "" end
		end

	count_of_iterable (a_iterable: ITERABLE [G]): INTEGER
			-- Count elements in iterable
		do
			across a_iterable as ic loop
				Result := Result + 1
			end
		end

	count_of_iterable_any (a_iterable: ITERABLE [ANY]): INTEGER
			-- Count elements in ANY iterable
		do
			across a_iterable as ic loop
				Result := Result + 1
			end
		end

feature -- Conversion

	to_list: LIST [G]
			-- Converts enum to list
		do
			create {ARRAYED_LIST [G]} Result.make_from_iterable (iterable)
		end

	to_array: ARRAY [G]
			-- Converts enum to array
		local
			l_list: LIST [G]
		do
			if count > 0 then
				l_list := to_list
				create Result.make_filled (l_list.first, 1, l_list.count)
				across 1 |..| l_list.count as i loop
					Result.put (l_list.i_th (i.item), i.item)
				end
			else
				create Result.make_empty
			end
		end

feature -- Status Report

	count: INTEGER
			-- Number of elements
		do
			Result := 0
			across iterable as ic loop
				Result := Result + 1
			end
		end

	is_empty: BOOLEAN
			-- Determines if the enumerable is empty
		do
			Result := count = 0
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [G]
			-- Fresh cursor for iteration
		do
			Result := iterable.new_cursor
		end

feature -- Chunking

	chunk_by (a_function: FUNCTION [G, ANY]): ENUM [ENUM [G]]
			-- Splits enumerable on every element for which a_function returns a new value.
			-- Returns an enumerable of enumerables (chunks).
		local
			l_result: ARRAYED_LIST [ENUM [G]]
			l_current_chunk: ARRAYED_LIST [G]
			l_previous_value: detachable ANY
			l_current_value: ANY
		do
			create l_result.make (0)
			create l_current_chunk.make (0)

			across iterable as ic loop
				l_current_value := a_function.item (ic)

				if l_current_chunk.is_empty then
						-- First element of the first chunk
					l_current_chunk.extend (ic)
					l_previous_value := l_current_value
				else
						-- Check if value changed
					if attached l_previous_value as prev and then not prev.is_deep_equal (l_current_value) then
							-- Value changed, create new chunk
						l_result.extend (create {ENUM [G]}.make (l_current_chunk))
						create l_current_chunk.make (0)
						l_current_chunk.extend (ic)
					else
							-- Same value, add to current chunk
						l_current_chunk.extend (ic)
					end
					l_previous_value := l_current_value
				end
			end

				-- Add the last chunk if not empty
			if not l_current_chunk.is_empty then
				l_result.extend (create {ENUM [G]}.make (l_current_chunk))
			end

			create Result.make (l_result)
		end

	chunk_every (a_count: INTEGER; a_step: INTEGER; a_leftover: detachable ITERABLE [G]): ENUM [ENUM [G]]
			-- Returns list of lists containing count elements each, where each new chunk starts step elements into the enumerable.
			-- If the last chunk is incomplete, elements from a_leftover are used to fill it.
			-- If a_leftover is Void, incomplete chunks are returned as-is.
		require
			valid_count: a_count > 0
			valid_step: a_step > 0
		local
			l_result: ARRAYED_LIST [ENUM [G]]
			l_current_chunk: ARRAYED_LIST [G]
			l_position: INTEGER
			l_leftover_enum: detachable ENUM [G]
			l_leftover_cursor: detachable ITERATION_CURSOR [G]
			l_elements: ARRAYED_LIST [G]
		do
			create l_result.make (0)
			create l_elements.make_from_iterable (iterable)

			from
				l_position := 1
			until
				l_position > l_elements.count
			loop
					-- Create a new chunk starting at current position
				create l_current_chunk.make (a_count)

					-- Fill chunk with up to a_count elements
				from
					l_current_chunk.extend (l_elements [l_position])
				until
					l_current_chunk.count = a_count or
					l_position + l_current_chunk.count > l_elements.count
				loop
					l_current_chunk.extend (l_elements [l_position + l_current_chunk.count])
				end

					-- Add chunk if it's complete or if we're allowing partial chunks
				if l_current_chunk.count = a_count then
					l_result.extend (create {ENUM [G]}.make (l_current_chunk))
				elseif attached a_leftover as left then
						-- Try to fill with leftover elements
					create l_leftover_enum.make (left)
					l_leftover_cursor := l_leftover_enum.new_cursor
					from
					until
						l_current_chunk.count = a_count or
						(attached l_leftover_cursor as lc and then lc.after)
					loop
						l_current_chunk.extend (l_leftover_cursor.item)
						l_leftover_cursor.forth
					end
					if l_current_chunk.count > 0 then
						l_result.extend (create {ENUM [G]}.make (l_current_chunk))
					end
				elseif l_current_chunk.count > 0 then
						-- Add partial chunk if no leftover and not discarding
					l_result.extend (create {ENUM [G]}.make (l_current_chunk))
				end

					-- Move position by step size
				l_position := l_position + a_step
			end

			create Result.make (l_result)
		end

	chunk_every_discard (a_count: INTEGER; a_step: INTEGER): ENUM [ENUM [G]]
			-- Same as chunk_every but discards the last chunk if incomplete
		require
			valid_count: a_count > 0
			valid_step: a_step > 0
		local
			l_result: ARRAYED_LIST [ENUM [G]]
			l_current_chunk: ARRAYED_LIST [G]
			l_position: INTEGER
			l_elements: ARRAYED_LIST [G]
		do
			create l_result.make (0)
			create l_elements.make_from_iterable (iterable)

			from
				l_position := 1
			until
				l_position > l_elements.count
			loop
					-- Create a new chunk starting at current position
				create l_current_chunk.make (a_count)

					-- Fill chunk with up to a_count elements
				from
					l_current_chunk.extend (l_elements [l_position])
				until
					l_current_chunk.count = a_count or
					l_position + l_current_chunk.count > l_elements.count
				loop
					l_current_chunk.extend (l_elements [l_position + l_current_chunk.count])
				end

					-- Only add complete chunks
				if l_current_chunk.count = a_count then
					l_result.extend (create {ENUM [G]}.make (l_current_chunk))
				end

					-- Move position by step size
				l_position := l_position + a_step
			end

			create Result.make (l_result)
		end

	chunk_every_default (a_count: INTEGER): ENUM [ENUM [G]]
			-- Simplified version where step equals count (non-overlapping chunks)
		require
			valid_count: a_count > 0
		do
			Result := chunk_every (a_count, a_count, Void)
		end

feature -- Filtering

	uniq: ENUM [G]
			-- Returns a new enum with all duplicate elements removed
		require
			count > 0
		local
			l_result: ARRAYED_LIST [G]
			l_seen: ARRAYED_LIST [G]
			is_seen: BOOLEAN
		do
			create l_result.make (count)
			create l_seen.make (count)
			across iterable as ic loop
				is_seen := across l_seen as seen some
						if attached {G} ic as current_item and then
							attached {G} seen as seen_item
						then
							current_item ~ seen_item
						else
							False
						end
 					end
				if not is_seen then
					l_result.extend (ic)
					l_seen.extend (ic)
				end
			end
			create Result.make (l_result)
		end

	uniq_by (a_function: FUNCTION [G, ANY]): ENUM [G]
			-- Returns a new enum with elements removed for which a_function returns duplicate values.
			-- The first occurrence of each element is kept.
		local
			l_result: ARRAYED_LIST [G]
			l_seen_values: ARRAYED_LIST [ANY]
			l_current_value: ANY
			is_seen: BOOLEAN
		do
			create l_result.make (count)
			create l_seen_values.make (count)

			across iterable as ic loop
				l_current_value := a_function.item (ic)

					-- Check if we've seen this value before
				is_seen := across l_seen_values as seen some
					if attached seen then
						seen.is_deep_equal (l_current_value)
					else
						False
					end
				end

				if not is_seen then
					l_result.extend (ic)
					l_seen_values.extend (l_current_value)
				end
			end

			create Result.make (l_result)
		end

end
