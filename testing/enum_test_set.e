note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	ENUM_TEST_SET

inherit
	EQA_COMMONLY_USED_ASSERTIONS
		rename
			default_create as dc,
			assert as assert_cua
		end
	EQA_TEST_SET
		select
			default_create
		end

feature -- Test routines

	test_to_list
			-- Test converting range to list
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_list: LIST [INTEGER]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

			l_list := l_enum.to_list

			assert ("list has correct size", l_list.count = 5)
			assert ("first element is 1", l_list.first = 1)
			assert ("last element is 5", l_list.last = 5)

				-- Verify all elements are present in order
			across 1 |..| 5 as i loop
				assert ("element " + i.item.out + " is correct",
					l_list.i_th (i.item) = i.item)
			end
		end

	test_concat
			-- Test concatenating two collections
		local
			l_enum1, l_enum2: ENUM [INTEGER]
			l_range1, l_range2: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range1.make (1, 3)
			create l_range2.make (4, 6)
			create l_enum1.make (l_range1)
			create l_enum2.make (l_range2)

			l_result := l_enum1.concat (l_range2).to_list

			assert ("list has correct size", l_result.count = 6)
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 6", l_result.last = 6)

				-- Verify all elements are present in order
			across 1 |..| 6 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item)
			end
		end

	test_concat_any
			-- Test concatenating integer sequence with character sequence
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_chars: ARRAY [CHARACTER]
			l_result: LIST [ANY]
		do
			create l_range.make (1, 3)
			create l_enum.make (l_range)
			create l_chars.make_filled ('a', 1, 3)

				-- Fill array with characters 'a', 'b', 'c'
			l_chars.put ('a', 1)
			l_chars.put ('b', 2)
			l_chars.put ('c', 3)

			l_result := l_enum.concat_any (l_chars).to_list

			assert ("list has correct size", l_result.count = 6)
			assert ("first element is 1", l_result.first.out.is_equal ("1"))
			assert ("fourth element is 'a'", l_result.i_th (4).out.is_equal ("a"))
			assert ("last element is 'c'", l_result.last.out.is_equal ("c"))

				-- Verify integer elements (1,2,3)
			across 1 |..| 3 as i loop
				assert ("integer element " + i.item.out + " is correct",
					l_result.i_th (i.item).out.is_equal (i.item.out))
			end

				-- Verify character elements (a,b,c)
			across 1 |..| 3 as i loop
				assert ("character element " + i.item.out + " is correct",
					l_result.i_th (i.item + 3).out.is_equal (
						(('a').code + i.item - 1).to_character_8.out))
			end
		end

	test_map
			-- Test mapping elements using a function
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
			l_string_result: LIST [STRING_GENERAL]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Test mapping integers to integers (multiply by 10)
			l_result := l_enum.map (agent (x: INTEGER): INTEGER
						do
							Result := x * 10
						end).to_list

			assert ("list has correct size", l_result.count = 5)
			assert ("first element is 10", l_result.first = 10)
			assert ("last element is 50", l_result.last = 50)

				-- Verify all elements are multiplied by 10
			across 1 |..| 5 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item * 10)
			end

				-- Test mapping integers to strings (duplicate "*")
			l_string_result := l_enum.map_to_string (agent (x: INTEGER): STRING
						do
							create Result.make_filled ('*', x)
						end).to_list

			assert ("string list has correct size", l_string_result.count = 5)
			assert ("first string is *", l_string_result.first.is_equal ("*"))
			assert ("last string is *****", l_string_result.last.is_equal ("*****"))

				-- Verify all strings have correct length
			across 1 |..| 5 as i loop
				assert ("string " + i.item.out + " has correct length",
					l_string_result.i_th (i.item).count = i.item)
			end
		end

	test_at
			-- Test accessing elements by position
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
		do
			create l_range.make (10, 20)
			create l_enum.make (l_range)

				-- Test valid index
			assert ("element at position 3 is 12",
				l_enum.at (3) = 12)

				-- Test out of bounds index (should return default value)
			assert ("element at position 20 returns default value",
				l_enum.at_with_default (20, -1) = -1)

				-- Test negative index (should return default value)
			assert ("element at negative position returns default value",
				l_enum.at_with_default (-1, -999) = -999)

				-- Test index beyond bounds (should return default value)
			assert ("element beyond bounds returns default value",
				l_enum.at_with_default (100, -1) = -1)
		end

	test_filter
			-- Test filtering elements using a predicate
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Filter elements greater than 2
			l_result := l_enum.filter (agent (x: INTEGER): BOOLEAN
						do
							Result := x > 2
						end).to_list

				-- Test size of filtered list
			assert ("filtered list has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 3", l_result.first = 3)
			assert ("last element is 5", l_result.last = 5)

				-- Verify all elements are greater than 2
			across l_result as ic loop
				assert ("element " + ic.item.out + " is greater than 2",
					ic.item > 2)
			end

				-- Verify elements are in correct order
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item + 2)
			end
		end

	test_filter_even
			-- Test filtering even numbers
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 6)
			create l_enum.make (l_range)

				-- Filter even elements
			l_result := l_enum.filter (agent (x: INTEGER): BOOLEAN
						do
							Result := (x \\ 2) = 0 -- Modulo operator to check for even numbers
						end).to_list

				-- Test size of filtered list
			assert ("filtered list has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 2", l_result.first = 2)
			assert ("last element is 6", l_result.last = 6)

				-- Verify all elements are even
			across l_result as ic loop
				assert ("element " + ic.item.out + " is even",
					(ic.item \\ 2) = 0)
			end

				-- Verify elements are in correct order (2,4,6)
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item * 2)
			end
		end

	test_reject_even
			-- Test rejecting even numbers
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 6)
			create l_enum.make (l_range)

				-- Reject even elements
			l_result := l_enum.reject (agent (x: INTEGER): BOOLEAN
						do
							Result := (x \\ 2) = 0 -- Modulo operator to check for even numbers
						end).to_list

				-- Test size of filtered list
			assert ("filtered list has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 5", l_result.last = 5)

				-- Verify all elements are odd
			across l_result as ic loop
				assert ("element " + ic.item.out + " is odd",
					(ic.item \\ 2) = 1)
			end

				-- Verify elements are in correct order (1,3,5)
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = (i.item * 2) - 1)
			end
		end

	test_sort_strings
			-- Test sorting strings alphabetically
		local
			l_enum: ENUM [STRING]
			l_array: ARRAY [STRING]
			l_result: LIST [STRING]
		do
			create l_array.make_filled ("", 1, 5)
			l_array [1] := "there"
			l_array [2] := "was"
			l_array [3] := "a"
			l_array [4] := "crooked"
			l_array [5] := "man"

			create l_enum.make (l_array)

			l_result := l_enum.sort (agent (a, b: STRING): BOOLEAN
						do
							Result := a < b
						end).to_list

				-- Test size of sorted list
			assert ("sorted list has correct size", l_result.count = 5)

				-- Test first and last elements
			assert ("first element is 'a'", l_result.first.is_equal ("a"))
			assert ("last element is 'was'", l_result.last.is_equal ("was"))

				-- Verify complete order
			assert ("second element is 'crooked'", l_result.i_th (2).is_equal ("crooked"))
			assert ("third element is 'man'", l_result.i_th (3).is_equal ("man"))
			assert ("fourth element is 'there'", l_result.i_th (4).is_equal ("there"))

				-- Verify elements are in sorted order
			across 1 |..| (l_result.count - 1) as i loop
				assert ("elements " + i.item.out + " and " + (i.item + 1).out + " are in order",
					l_result.i_th (i.item) < l_result.i_th (i.item + 1))
			end
		end

	test_sort_strings_by_length
			-- Test sorting strings by length
		local
			l_enum: ENUM [STRING]
			l_array: ARRAY [STRING]
			l_result: LIST [STRING]
		do
			create l_array.make_filled ("", 1, 5)
			l_array [1] := "there"
			l_array [2] := "was"
			l_array [3] := "a"
			l_array [4] := "crooked"
			l_array [5] := "man"

			create l_enum.make (l_array)

			l_result := l_enum.sort (agent (a, b: STRING): BOOLEAN
						do
							Result := a.count <= b.count
						end).to_list

				-- Test size of sorted list
			assert ("sorted list has correct size", l_result.count = 5)

				-- Test first and last elements (shortest and longest)
			assert ("first element is 'a'", l_result.first.is_equal ("a"))
			assert ("last element is 'crooked'", l_result.last.is_equal ("crooked"))

				-- Verify elements are in ascending length order
			across 1 |..| (l_result.count - 1) as i loop
				assert ("element " + i.item.out + " is not longer than next element",
					l_result.i_th (i.item).count <= l_result.i_th (i.item + 1).count)
			end

				-- Verify specific lengths
			assert ("first element length is 1", l_result.first.count = 1) -- "a"
			assert ("last element length is 7", l_result.last.count = 7) -- "crooked"
		end

	test_max_strings_with_comparator
			-- Test finding maximum string using a comparator
		local
			l_enum: ENUM [STRING]
			l_array: ARRAY [STRING]
			l_result: STRING
		do
			create l_array.make_filled ("", 1, 5)
			l_array [1] := "there"
			l_array [2] := "was"
			l_array [3] := "a"
			l_array [4] := "crooked"
			l_array [5] := "man"

			create l_enum.make (l_array)

				-- Find maximum string using lexicographical comparison
			l_result := l_enum.max (agent (a, b: STRING): BOOLEAN
						do
							Result := a > b
						end)

				-- Test that "was" is the maximum string
			assert ("maximum element is 'was'", l_result.is_equal ("was"))

				-- Verify it's greater than all other elements
			across l_array as ic loop
				assert ("'was' is greater or equal to '" + ic + "'",
					l_result >= ic)
			end

				-- Now test finding longest string
			l_result := l_enum.max (agent (a, b: STRING): BOOLEAN
						do
							Result := a.count > b.count
						end)

				-- Test that "crooked" is the longest string
			assert ("longest element is 'crooked'", l_result.is_equal ("crooked"))

				-- Verify it's the longest
			across l_array as ic loop
				assert ("'crooked' is longer or equal to '" + ic + "'",
					l_result.count >= ic.count)
			end
		end

	test_max_by_string_length
			-- Test finding maximum string by length
		local
			l_enum: ENUM [STRING]
			l_array: ARRAY [STRING]
			l_result: STRING
		do
			create l_array.make_filled ("", 1, 5)
			l_array [1] := "there"
			l_array [2] := "was"
			l_array [3] := "a"
			l_array [4] := "crooked"
			l_array [5] := "man"

			create l_enum.make (l_array)

				-- Find string with maximum length
			l_result := l_enum.max (agent (a, b: STRING): BOOLEAN
						do
							Result := a.count > b.count
						end)

				-- Test that "crooked" is the longest string
			assert ("longest element is 'crooked'", l_result.is_equal ("crooked"))

				-- Verify it's the longest
			across l_array as ic loop
				assert ("'crooked' length >= '" + ic + "' length",
					l_result.count >= ic.count)
			end

				-- Verify specific length
			assert ("longest string has length 7", l_result.count = 7)
		end

	test_take
			-- Test taking first n elements
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Take first 3 elements
			l_result := l_enum.take (3).to_list

				-- Test size of result
			assert ("result has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 3", l_result.last = 3)

				-- Verify all elements are present in order
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item)
			end

				-- Test taking more elements than available
			l_result := l_enum.take (10).to_list
			assert ("taking more than available returns all elements",
				l_result.count = 5)

				-- Test taking zero elements
			l_result := l_enum.take (0).to_list
			assert ("taking zero elements returns empty list",
				l_result.count = 0)

				-- Test taking negative number of elements
			l_result := l_enum.take (-1).to_list
			assert ("taking negative elements returns empty list",
				l_result.count = 0)
		end

	test_take_every
			-- Test taking every nth element
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 6)
			create l_enum.make (l_range)

				-- Take every 2nd element
			l_result := l_enum.take_every (2).to_list

				-- Test size of result
			assert ("result has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 5", l_result.last = 5)

				-- Verify elements are correct (1,3,5)
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = (2 * i.item - 1))
			end

				-- Test taking every 3rd element
			l_result := l_enum.take_every (3).to_list
			assert ("taking every 3rd element returns 2 elements",
				l_result.count = 2)
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 4", l_result.last = 4)

				-- Test taking every element (step = 1)
			l_result := l_enum.take_every (1).to_list
			assert ("taking every element returns all elements",
				l_result.count = 6)

				-- Test invalid steps
			l_result := l_enum.take_every (0).to_list
			assert ("taking every 0th element returns empty list",
				l_result.count = 0)

			l_result := l_enum.take_every (-1).to_list
			assert ("taking every negative element returns empty list",
				l_result.count = 0)
		end

	test_take_while
			-- Test taking elements while predicate is true
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: LIST [INTEGER]
		do
			create l_range.make (1, 6)
			create l_enum.make (l_range)

				-- Take elements while less than 4
			l_result := l_enum.take_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end).to_list

				-- Test size of result
			assert ("result has correct size", l_result.count = 3)

				-- Test first and last elements
			assert ("first element is 1", l_result.first = 1)
			assert ("last element is 3", l_result.last = 3)

				-- Verify all elements are less than 4
			across l_result as ic loop
				assert ("element " + ic.item.out + " is less than 4",
					ic.item < 4)
			end

				-- Verify elements are in correct order (1,2,3)
			across 1 |..| 3 as i loop
				assert ("element " + i.item.out + " is correct",
					l_result.i_th (i.item) = i.item)
			end

				-- Test empty result when first element fails predicate
			l_result := l_enum.take_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 1
						end).to_list
			assert ("empty result when first element fails predicate",
				l_result.count = 0)
		end

	test_split
			-- Test splitting enumerable into two parts
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: TUPLE [first, second: ENUM [INTEGER]]
			l_first, l_second: LIST [INTEGER]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Test positive split point
			l_result := l_enum.split (3)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify first part
			assert ("first part has correct size", l_first.count = 3)
			assert ("first element of first part is 1", l_first.first = 1)
			assert ("last element of first part is 3", l_first.last = 3)

				-- Verify second part
			assert ("second part has correct size", l_second.count = 2)
			assert ("first element of second part is 4", l_second.first = 4)
			assert ("last element of second part is 5", l_second.last = 5)

				-- Test negative split point
			l_result := l_enum.split (-2)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify first part with negative index
			assert ("first part has correct size (negative)", l_first.count = 3)
			assert ("first element is 1", l_first.first = 1)
			assert ("last element is 3", l_first.last = 3)

				-- Verify second part with negative index
			assert ("second part has correct size (negative)", l_second.count = 2)
			assert ("first element is 4", l_second.first = 4)
			assert ("last element is 5", l_second.last = 5)

				-- Test split point larger than list size
			l_result := l_enum.split (10)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

			assert ("first part contains all elements", l_first.count = 5)
			assert ("second part is empty", l_second.count = 0)

				-- Test split point of zero
			l_result := l_enum.split (0)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

			assert ("first part is empty", l_first.count = 0)
			assert ("second part contains all elements", l_second.count = 5)
		end

	test_split_while
			-- Test splitting enumerable based on predicate
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: TUPLE [first, second: ENUM [INTEGER]]
			l_first, l_second: LIST [INTEGER]
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Test splitting while less than 4
			l_result := l_enum.split_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify first part
			assert ("first part has correct size", l_first.count = 3)
			assert ("first element of first part is 1", l_first.first = 1)
			assert ("last element of first part is 3", l_first.last = 3)

				-- Verify second part
			assert ("second part has correct size", l_second.count = 2)
			assert ("first element of second part is 4", l_second.first = 4)
			assert ("last element of second part is 5", l_second.last = 5)

				-- Test splitting while less than 3
			l_result := l_enum.split_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 3
						end)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify parts for split at 3
			assert ("first part has size 2", l_first.count = 2)
			assert ("second part has size 3", l_second.count = 3)
			assert ("first part ends with 2", l_first.last = 2)
			assert ("second part starts with 3", l_second.first = 3)

				-- Test when predicate is always false
			l_result := l_enum.split_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 0
						end)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify empty first part when predicate is always false
			assert ("first part is empty", l_first.count = 0)
			assert ("second part contains all elements", l_second.count = 5)

				-- Test when predicate is always true
			l_result := l_enum.split_while (agent (x: INTEGER): BOOLEAN
						do
							Result := x > 0
						end)
			l_first := l_result.first.to_list
			l_second := l_result.second.to_list

				-- Verify all elements in first part when predicate is always true
			assert ("first part contains all elements", l_first.count = 5)
			assert ("second part is empty", l_second.count = 0)
		end

	test_join
			-- Test joining elements into string
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: STRING
		do
			create l_range.make (1, 3)
			create l_enum.make (l_range)

				-- Test joining without separator
			l_result := l_enum.join
			assert ("joined without separator", l_result.same_string ("123"))

				-- Test joining with separator
			l_result := l_enum.join_with (" = ")
			assert ("joined with separator", l_result.same_string ("1 = 2 = 3"))

				-- Test joining single element
			create l_range.make (1, 1)
			create l_enum.make (l_range)
			l_result := l_enum.join_with (" = ")
			assert ("single element joined", l_result.same_string ("1"))

				-- Test joining empty list
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			l_result := l_enum.join_with (" = ")
			assert ("empty list joined to empty string", l_result.is_empty)
		end

	test_for_all
			-- Test if all elements satisfy predicate
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: BOOLEAN
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Test when some elements don't satisfy predicate (x < 4)
			l_result := l_enum.for_all (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("not all elements are less than 4", not l_result)

				-- Test when all elements satisfy predicate (x > 0)
			l_result := l_enum.for_all (agent (x: INTEGER): BOOLEAN
						do
							Result := x > 0
						end)
			assert ("all elements are greater than 0", l_result)

				-- Test with empty enumerable (should return true)
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			l_result := l_enum.for_all (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("empty enumerable returns true", l_result)

				-- Test with single element that satisfies predicate
			create l_range.make (1, 1)
			create l_enum.make (l_range)
			l_result := l_enum.for_all (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("single element less than 4", l_result)
		end

	test_there_is_any
			-- Test if any element satisfies predicate
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: BOOLEAN
		do
			create l_range.make (1, 5)
			create l_enum.make (l_range)

				-- Test when some elements satisfy predicate (x < 4)
			l_result := l_enum.there_is_any (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("some elements are less than 4", l_result)

				-- Test when no elements satisfy predicate (x < 0)
			l_result := l_enum.there_is_any (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 0
						end)
			assert ("no elements are less than 0", not l_result)

				-- Test with empty enumerable (should return false)
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			l_result := l_enum.there_is_any (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("empty enumerable returns false", not l_result)

				-- Test with single element that satisfies predicate
			create l_range.make (1, 1)
			create l_enum.make (l_range)
			l_result := l_enum.there_is_any (agent (x: INTEGER): BOOLEAN
						do
							Result := x < 4
						end)
			assert ("single element less than 4", l_result)
		end

	test_member
			-- Test checking if element is member of enumerable
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_real_enum: ENUM [REAL]
			l_real_list: ARRAYED_LIST [REAL]
		do
				-- Test with integer range
			create l_range.make (1, 10)
			create l_enum.make (l_range)

				-- Test element that exists
			assert ("5 is a member of 1..10",
				l_enum.has (5))

				-- Test element that doesn't exist
			assert ("11 is not a member of 1..10",
				not l_enum.has (11))

				-- Test with real numbers
			create l_real_list.make (3)
			l_real_list.extend (1.0)
			l_real_list.extend (2.0)
			l_real_list.extend (3.0)
			create l_real_enum.make (l_real_list)

				-- Test exact real number match
			assert ("2.0 is a member of [1.0, 2.0, 3.0]",
				l_real_enum.has (2.0))

				-- Test with empty enumerable
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			assert ("element not found in empty enumerable",
				not l_enum.has (5))

				-- Test with single element enumerable
			create l_range.make (5, 5)
			create l_enum.make (l_range)
			assert ("5 is a member of single element enumerable",
				l_enum.has (5))
			assert ("6 is not a member of single element enumerable",
				not l_enum.has (6))
		end

	test_is_empty
			-- Test if enumerable is empty
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
		do
				-- Test with empty range
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			assert ("empty range is empty", l_enum.is_empty)

				-- Test with non-empty range
			create l_range.make (1, 5)
			create l_enum.make (l_range)
			assert ("non-empty range is not empty", not l_enum.is_empty)

				-- Test with single element
			create l_range.make (1, 1)
			create l_enum.make (l_range)
			assert ("single element range is not empty", not l_enum.is_empty)
		end

	test_zip
			-- Test zipping two enumerables together
		local
			l_enum: ENUM [INTEGER]
			l_strings: ARRAYED_LIST [STRING]
			l_range: INTEGER_INTERVAL
			l_merger: ENUM_MERGE [INTEGER, STRING]
			l_result: LIST [TUPLE [INTEGER, STRING]]
		do
				-- Create first enumerable (1,2,3)
			create l_range.make (1, 3)
			create l_enum.make (l_range)

				-- Create second enumerable ("a","b","c")
			create l_strings.make (3)
			l_strings.extend ("a")
			l_strings.extend ("b")
			l_strings.extend ("c")

				-- Create merger and test basic zipping
			create l_merger.make (l_enum.iterable, l_strings)
			l_result := l_merger.zip.to_list

				-- Verify size
			assert ("result has correct size", l_result.count = 3)

				-- Verify first tuple
			assert ("first tuple first is 1", l_result.first.item (1) = 1)
			assert ("first tuple second is a", l_result.first.item (2) ~ "a")

				-- Verify last tuple
			assert ("last tuple first is 3", l_result.last.item (1) = 3)
			assert ("last tuple second is c", l_result.last.item (2) ~ "c")

				-- Test with longer first enumerable
			create l_range.make (1, 5)
			create l_enum.make (l_range)
			create l_merger.make (l_enum.iterable, l_strings)
			l_result := l_merger.zip.to_list
			assert ("result size limited by shorter enumerable", l_result.count = 3)

				-- Test with longer second enumerable
			create l_range.make (1, 2)
			create l_enum.make (l_range)
			create l_merger.make (l_enum.iterable, l_strings)
			l_result := l_merger.zip.to_list
			assert ("result size limited by shorter enumerable (2)", l_result.count = 2)

				-- Test with empty first enumerable
			create l_range.make (1, 0)
			create l_enum.make (l_range)
			create l_merger.make (l_enum.iterable, l_strings)
			l_result := l_merger.zip.to_list
			assert ("empty result with empty first enumerable", l_result.is_empty)

				-- Test with empty second enumerable
			create l_range.make (1, 3)
			create l_enum.make (l_range)
			create l_strings.make (0)
			create l_merger.make (l_enum.iterable, l_strings)
			l_result := l_merger.zip.to_list
			assert ("empty result with empty second enumerable", l_result.is_empty)
		end

	test_with_index
			-- Test indexing operations
		local
			l_enum: ENUM [STRING]
			l_strings: ARRAYED_LIST [STRING]
			l_result: LIST [TUPLE [elem: STRING; index: INTEGER]]
		do
				-- Create test enumerable ("a","b","c")
			create l_strings.make (3)
			l_strings.extend ("a")
			l_strings.extend ("b")
			l_strings.extend ("c")
			create l_enum.make (l_strings)

				-- Test basic with_index
			l_result := l_enum.with_index.to_list
			assert ("basic index size correct", l_result.count = 3)
			assert ("first index is 0", l_result.first.index = 0)
			assert ("first item is a", l_result.first.elem ~ "a")
			assert ("last index is 2", l_result.last.index = 2)
			assert ("last item is c", l_result.last.elem ~ "c")

				-- Test with_index_offset
			l_result := l_enum.with_index_offset (3).to_list
			assert ("offset index size correct", l_result.count = 3)
			assert ("first offset index is 3", l_result.first.index = 3)
			assert ("last offset index is 5", l_result.last.index = 5)

		end

	test_with_index_mapper
			-- Test indexing operations with custom mapping function
		local
			l_enum: ENUM [STRING]
			l_strings: ARRAYED_LIST [STRING]
			l_function: ENUM_INDEX_FUNCTION [STRING, TUPLE [INTEGER, STRING]]
			l_result: LIST [TUPLE [INTEGER, STRING]]
		do
				-- Create test enumerable ("a","b","c")
			create l_strings.make (3)
			l_strings.extend ("a")
			l_strings.extend ("b")
			l_strings.extend ("c")
			create l_enum.make (l_strings)

				-- Create function that maps (element, index) to {index, element}
			create l_function.make (
					agent (element: STRING; index: INTEGER): TUPLE [INTEGER, STRING]
						do
							Result := [index, element]
						end
				)

				-- Apply function with index
			l_result := l_function.with_index (l_enum.iterable).to_list

				-- Verify results
			assert ("result has correct size", l_result.count = 3)

				-- Check first element
			assert ("first tuple index is 0", l_result.first.item (1) = 0)
			assert ("first tuple element is 'a'", l_result.first.item (2) ~ "a")

				-- Check last element
			assert ("last tuple index is 2", l_result.last.item (1) = 2)
			assert ("last tuple element is 'c'", l_result.last.item (2) ~ "c")

				-- Check middle element
			assert ("middle tuple index is 1", l_result.i_th (2).item (1) = 1)
			assert ("middle tuple element is 'b'", l_result.i_th (2).item (2) ~ "b")

				-- Test with empty enumerable
			create l_strings.make (0)
			create l_enum.make (l_strings)
			l_result := l_function.with_index (l_enum.iterable).to_list
			assert ("empty enumerable gives empty result", l_result.is_empty)
		end

	test_reduce
			-- Test reducing enumerable to single value
		local
			l_enum: ENUM [INTEGER]
			l_range: INTEGER_INTERVAL
			l_result: INTEGER
		do
				-- Test reducing 1..5 by summing
			create l_range.make (1, 5)
			create l_enum.make (l_range)

			l_result := l_enum.reduce (agent (acc, x: INTEGER): INTEGER
						do
							Result := acc + x
						end)

				-- Verify sum is correct (1+2+3+4+5 = 15)
			assert ("sum exists", attached l_result)
			if attached l_result as l_sum then
				assert ("sum of 1..5 is 15", l_sum = 15)
			end

				-- Test reducing 1..100
			create l_range.make (1, 100)
			create l_enum.make (l_range)

			l_result := l_enum.reduce (agent (acc, x: INTEGER): INTEGER
						do
							Result := acc + x
						end)

				-- Verify sum is correct (sum of 1..100 = 5050)
			assert ("sum exists", attached l_result)
			if attached l_result as l_sum then
				assert ("sum of 1..100 is 5050", l_sum = 5050)
			end

				-- Test with single element
			create l_range.make (42, 42)
			create l_enum.make (l_range)

			l_result := l_enum.reduce (agent (acc, x: INTEGER): INTEGER
						do
							Result := acc + x
						end)

				-- Single element should return itself
			assert ("result exists", attached l_result)
			if attached l_result as l_single then
				assert ("reducing single element returns element", l_single = 42)
			end

				-- Test with empty enumerable
			create l_range.make (1, 0)
			create l_enum.make (l_range)

			l_result := l_enum.reduce (agent (acc, x: INTEGER): INTEGER
						do
							Result := acc + x
						end)

				-- Empty enumerable should return Void
			assert ("empty enumerable returns void", l_result = 0)
		end

	test_reduce_longest_word
			-- Test reducing strings to find longest word
		local
			l_enum: ENUM [STRING]
			l_strings: ARRAYED_LIST [STRING]
			l_result: detachable STRING
		do
				-- Create test enumerable with words
			create l_strings.make (4)
			l_strings.extend ("now")
			l_strings.extend ("is")
			l_strings.extend ("the")
			l_strings.extend ("time")
			create l_enum.make (l_strings)

				-- Reduce to find longest word
			l_result := l_enum.reduce (
						agent (word, longest: STRING): STRING
							do
								if word.count > longest.count then
									Result := word
								else
									Result := longest
								end
							end
					)

				-- Verify result
			assert ("result exists", l_result /= Void)
			if attached l_result as l_word then
				assert ("longest word is 'time'", l_word ~ "time")
			end

				-- Test with single word
			create l_strings.make (1)
			l_strings.extend ("solo")
			create l_enum.make (l_strings)

			l_result := l_enum.reduce (
						agent (word, longest: STRING): STRING
							do
								if word.count > longest.count then
									Result := word
								else
									Result := longest
								end
							end
					)

				-- Verify single word result
			assert ("single word result exists", l_result /= Void)
			if attached l_result as l_word then
				assert ("single word is 'solo'", l_word ~ "solo")
			end

				-- Test with empty list
			create l_strings.make (0)
			create l_enum.make (l_strings)

			l_result := l_enum.reduce (
						agent (word, longest: STRING): STRING
							do
								if word.count > longest.count then
									Result := word
								else
									Result := longest
								end
							end
					)

				-- Verify empty list returns Void
			assert ("empty list returns void", l_result = Void)
		end

	test_frequencies
			-- Test the frequencies feature with various scenarios
		local
			l_enum: ENUM [INTEGER]
			l_result: ENUM [TUPLE [element: INTEGER; len: INTEGER]]
			l_list: ARRAYED_LIST [INTEGER]
		do
				-- Test case 1: Empty list
			create l_list.make (0)
			create l_enum.make (l_list)
			l_result := l_enum.frequencies (agent (a, b: INTEGER): BOOLEAN do Result := a = b end)
			assert ("Empty list should have no frequencies", l_result.count = 0)

				-- Test case 2: List with single element
			create l_list.make (1)
			l_list.extend (1)
			create l_enum.make (l_list)
			l_result := l_enum.frequencies (agent (a, b: INTEGER): BOOLEAN do Result := a = b end)
			assert ("Single element should have one frequency", l_result.count = 1)
			assert ("Single element should have count 1",
				across l_result as ic some
				ic.element = 1 and then ic.len = 1
 end)

				-- Test case 3: List with multiple elements, some repeated
			create l_list.make (5)
			l_list.extend (1)
			l_list.extend (2)
			l_list.extend (1)
			l_list.extend (3)
			l_list.extend (2)
			create l_enum.make (l_list)
			l_result := l_enum.frequencies (agent (a, b: INTEGER): BOOLEAN do Result := a = b end)

			assert ("Should have three unique elements", l_result.count = 3)
			assert ("Element 1 should appear twice",
				across l_result as ic some
				ic.element = 1 and then ic.len = 2
 end)
			assert ("Element 2 should appear twice",
				across l_result as ic some
				ic.element = 2 and then ic.len = 2
 end)
			assert ("Element 3 should appear once",
				across l_result as ic some
				ic.element = 3 and then ic.len = 1
 end)
		end

	test_frequencies_with_strings
			-- Test frequencies with string elements
		local
			l_enum: ENUM [STRING]
			l_result: ENUM [TUPLE [element: STRING; len: INTEGER]]
			l_list: ARRAYED_LIST [STRING]
		do
				-- Create list with repeated strings
			create l_list.make (6)
			l_list.extend ("ant")
			l_list.extend ("buffalo")
			l_list.extend ("ant")
			l_list.extend ("ant")
			l_list.extend ("buffalo")
			l_list.extend ("dingo")
			create l_enum.make (l_list)

				-- Get frequencies with string comparison
			l_result := l_enum.frequencies (agent (a, b: STRING): BOOLEAN
						do
							Result := a.same_string (b)
						end)

				-- Verify total count of unique elements
			assert ("Should have three unique elements", l_result.count = 3)

				-- Verify individual frequencies
			assert ("'ant' should appear three times",
				across l_result as ic some
				ic.element.same_string ("ant") and then ic.len = 3
 end)

			assert ("'buffalo' should appear twice",
				across l_result as ic some
				ic.element.same_string ("buffalo") and then ic.len = 2
 end)

			assert ("'dingo' should appear once",
				across l_result as ic some
				ic.element.same_string ("dingo") and then ic.len = 1
 end)
		end

	test_zip_multiple
			-- Test zipping multiple enumerables together
		local
			l_numbers: ARRAYED_LIST [INTEGER]
			l_letters: ARRAYED_LIST [CHARACTER]
			l_words: ARRAYED_LIST [STRING]
			l_iterables: ARRAYED_LIST [ITERABLE [ANY]]
			l_result: LIST [ITERABLE [ANY]]
			l_enum: ENUM [ANY]
			l_zipped_items: ITERABLE [ANY]
			l_zipped_enum: ENUM [ANY]
		do
				-- Create first enumerable (1,2,3)
			create l_numbers.make (3)
			l_numbers.extend (1)
			l_numbers.extend (2)
			l_numbers.extend (3)

				-- Create second enumerable ('a','b','c')
			create l_letters.make (3)
			l_letters.extend ('a')
			l_letters.extend ('b')
			l_letters.extend ('c')

				-- Create third enumerable ("one","two","three")
			create l_words.make (3)
			l_words.extend ("one")
			l_words.extend ("two")
			l_words.extend ("three")

				-- Create list of iterables
			create l_iterables.make (3)
			l_iterables.extend (l_numbers)
			l_iterables.extend (l_letters)
			l_iterables.extend (l_words)

				-- Create enum and zip
			create l_enum.make (l_iterables.first)
			l_result := l_enum.zip (l_iterables).to_list

				-- Verify size
			assert ("result has correct size", l_result.count = 3)

				-- Verify first set of items
			l_zipped_items := l_result.first
			create l_zipped_enum.make (l_zipped_items)
			assert ("first set has correct size", l_zipped_enum.count = 3)
			assert ("first item is 1", l_zipped_enum.at (1) ~ 1)
			assert ("second item is 'a'", l_zipped_enum.at (2) ~ 'a')
			assert ("third item is 'one'", l_zipped_enum.at (3) ~ "one")

				-- Verify last set of items
			l_zipped_items := l_result.last
			create l_zipped_enum.make (l_zipped_items)
			assert ("last set has correct size", l_zipped_enum.count = 3)
			assert ("first item is 3", l_zipped_enum.at (1) ~ 3)
			assert ("second item is 'c'", l_zipped_enum.at (2) ~ 'c')
			assert ("third item is 'three'", l_zipped_enum.at (3) ~ "three")

				-- Test with iterables of different lengths
			l_numbers.extend (4) -- Make first iterable longer
			l_result := l_enum.zip (l_iterables).to_list
			assert ("result limited by shortest iterable", l_result.count = 3)

				-- Test with empty iterables list
			create l_iterables.make (0)
			l_result := l_enum.zip (l_iterables).to_list
			assert ("empty iterables returns empty result", l_result.is_empty)

		end

	test_chunk_by
			-- Test chunking elements based on a function
		local
			l_enum: ENUM [INTEGER]
			l_numbers: ARRAYED_LIST [INTEGER]
			l_result: LIST [ENUM [INTEGER]]
		do
				-- Test case similar to example: [1, 2, 2, 3, 4, 4, 6, 7, 7]
			create l_numbers.make (9)
			l_numbers.extend (1)
			l_numbers.extend (2)
			l_numbers.extend (2)
			l_numbers.extend (3)
			l_numbers.extend (4)
			l_numbers.extend (4)
			l_numbers.extend (6)
			l_numbers.extend (7)
			l_numbers.extend (7)

			create l_enum.make (l_numbers)

				-- Chunk by odd/even (similar to rem(&1, 2) == 1)
			l_result := l_enum.chunk_by (agent (x: INTEGER): BOOLEAN
						do
							Result := (x \\ 2 = 1)
						end).to_list

				-- Verify number of chunks
			assert ("correct number of chunks", l_result.count = 5)

				-- Verify first chunk [1]
			assert ("first chunk has size 1", l_result.first.count = 1)
			assert ("first chunk starts with 1", l_result.first.at (1) = 1)

				-- Verify second chunk [2, 2]
			assert ("second chunk has size 2", l_result.i_th (2).count = 2)
			assert ("second chunk contains 2", l_result.i_th (2).at (1) = 2)
			assert ("second chunk contains 2", l_result.i_th (2).at (2) = 2)

				-- Verify third chunk [3]
			assert ("third chunk has size 1", l_result.i_th (3).count = 1)
			assert ("third chunk contains 3", l_result.i_th (3).at (1) = 3)

				-- Verify fourth chunk [4, 4, 6]
			assert ("fourth chunk has size 3", l_result.i_th (4).count = 3)
			assert ("fourth chunk starts with 4", l_result.i_th (4).at (1) = 4)
			assert ("fourth chunk contains 4", l_result.i_th (4).at (2) = 4)
			assert ("fourth chunk ends with 6", l_result.i_th (4).at (3) = 6)

				-- Verify last chunk [7, 7]
			assert ("last chunk has size 2", l_result.last.count = 2)
			assert ("last chunk contains 7", l_result.last.at (1) = 7)
			assert ("last chunk contains 7", l_result.last.at (2) = 7)
		end

	test_chunk_every
			-- Test chunking with various configurations
		local
			l_enum: ENUM [INTEGER]
			l_numbers: ARRAYED_LIST [INTEGER]
			l_result: LIST [ENUM [INTEGER]]
			l_leftover: ARRAYED_LIST [INTEGER]
		do
				-- Test basic chunking (count = step)
			create l_numbers.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every(2, 2, Void).to_list

			assert ("basic chunking count", l_result.count = 3)
			assert_arrays_equal ("first chunk correct", <<1, 2>>, l_result.first.to_array)
			assert_arrays_equal ("last chunk correct", <<5, 6>>, l_result.last.to_array)

			l_result := l_enum.chunk_every(2, 3, Void).to_list
			assert ("basic chunking count", l_result.count = 2)
			assert_arrays_equal ("first chunk correct", <<1, 2>>, l_result.first.to_array)
			assert_arrays_equal ("last chunk correct", <<4, 5>>, l_result.last.to_array)


				-- Test with step different from count
			create l_numbers.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every (3, 2, Void).to_list

			assert ("overlapping chunks count", l_result.count = 3)
			assert_arrays_equal ("first chunk correct", <<1, 2, 3>>, l_result.first.to_array)
			assert_arrays_equal ("last chunk correct", <<5, 6>>, l_result.last.to_array)

			create l_numbers.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every_discard (3, 2).to_list

			assert ("overlapping chunks count", l_result.count = 2)
			assert_arrays_equal ("first chunk correct", <<1, 2, 3>>, l_result.first.to_array)
			assert_arrays_equal ("last chunk correct", <<3, 4, 5>>, l_result.last.to_array)


				-- Test with leftover
			create l_numbers.make_from_array (<<1, 2, 3, 4>>)
			create l_leftover.make_from_array (<<7>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every (3, 3, l_leftover).to_list

			assert ("chunks with leftover count", l_result.count = 2)
			assert_arrays_equal ("first chunk correct", <<1, 2, 3>>, l_result.first.to_array)
			assert_arrays_equal ("last chunk with leftover", <<4, 7>>, l_result.last.to_array)

				-- Test with discard
			create l_numbers.make_from_array (<<1, 2, 3, 4, 5, 6>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every_discard (3, 2).to_list

			assert ("discard incomplete count", l_result.count = 2)
			assert_arrays_equal ("first chunk correct", <<1, 2, 3>>, l_result.first.to_array)
			assert_arrays_equal ("second chunk correct", <<3, 4, 5>>, l_result.i_th (2).to_array)

				-- Test with larger count than elements
			create l_numbers.make_from_array (<<1, 2, 3, 4>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.chunk_every_default (10).to_list

			assert ("single chunk for small list", l_result.count = 1)
			assert_arrays_equal ("all elements in chunk", <<1, 2, 3, 4>>, l_result.first.to_array)
		end

	test_uniq
			-- Test removing duplicate elements
		local
			l_enum: ENUM [INTEGER]
			l_numbers: ARRAYED_LIST [INTEGER]
			l_result: ARRAY [INTEGER]
		do
				-- Test with duplicates
			create l_numbers.make_from_array (<<1, 2, 3, 3, 2, 1>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.uniq.to_array

			assert ("correct number of unique elements", l_result.count = 3)
			assert_arrays_equal ("unique elements in order", <<1, 2, 3>>, l_result)

				-- Test with no duplicates
			create l_numbers.make_from_array (<<1, 2, 3>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.uniq.to_array

			assert ("same count when no duplicates", l_result.count = 3)
			assert_arrays_equal ("same elements when no duplicates", <<1, 2, 3>>, l_result)

				-- Test with all duplicates
			create l_numbers.make_from_array (<<1, 1, 1>>)
			create l_enum.make (l_numbers)
			l_result := l_enum.uniq.to_array

			assert ("single element when all duplicates", l_result.count = 1)
			assert_arrays_equal ("single unique element", <<1>>, l_result)

				-- Test with empty list
			create l_numbers.make (0)
			create l_enum.make (l_numbers)
			l_result := l_enum.uniq.to_array

			assert ("empty result for empty input", l_result.count = 0)
		end


	test_uniq_by
            -- Test removing duplicates based on function result
        local
            l_enum: ENUM [TUPLE [x: INTEGER; y: CHARACTER]]
            l_tuples: ARRAYED_LIST [TUPLE [x: INTEGER; y: CHARACTER]]
            l_result: ARRAY [TUPLE [x: INTEGER; y: CHARACTER]]
        do
           	 -- Test with tuples, keeping first occurrence of each x value
            create l_tuples.make (3)
            l_tuples.extend ([1, 'x'])
            l_tuples.extend ([2, 'y'])
            l_tuples.extend ([1, 'z'])

            create l_enum.make (l_tuples)
            l_result := l_enum.uniq_by (agent (t: TUPLE [x: INTEGER; y: CHARACTER]): INTEGER
                do
                    Result := t.x
                end).to_array

            	-- Should keep {1, 'x'} and {2, 'y'}, dropping {1, 'z'}
            assert ("correct number of unique elements", l_result.count = 2)
            assert ("first element kept", l_result[1].x = 1 and l_result[1].y = 'x')
            assert ("second element kept", l_result[2].x = 2 and l_result[2].y = 'y')

            	-- Test with tuples, keeping first occurrence of each y value
            create l_tuples.make (3)
            l_tuples.extend ([1, 'a'])
            l_tuples.extend ([2, 'a'])
            l_tuples.extend ([3, 'b'])

            create l_enum.make (l_tuples)
            l_result := l_enum.uniq_by (agent (t: TUPLE [x: INTEGER; y: CHARACTER]): CHARACTER
                do
                    Result := t.y
                end).to_array

            	-- Should keep {1, 'a'} and {3, 'b'}, dropping {2, 'a'}
            assert ("correct number of unique elements", l_result.count = 2)
            assert ("first element kept", l_result[1].x = 1 and l_result[1].y = 'a')
            assert ("last element kept", l_result[2].x = 3 and l_result[2].y = 'b')
        end

	test_uniq_by_complex
			-- Test removing duplicates based on function result
		local
			l_enum: ENUM [TUPLE [label: STRING; data: TUPLE [name: STRING; i: INTEGER]]]
			l_tuples: ARRAYED_LIST [TUPLE [label: STRING; data: TUPLE [name: STRING; i: INTEGER]]]
			l_result: ARRAY [TUPLE [label: STRING; data: TUPLE [name: STRING; i: INTEGER]]]
		do
			-- Test with nested tuples, keeping first occurrence of each count value
			create l_tuples.make (3)
			l_tuples.extend (["a", ["tea", 2]])      -- a: {:tea, 2}
			l_tuples.extend (["b", ["tea", 2]])      -- b: {:tea, 2}
			l_tuples.extend (["c", ["coffee", 1]])   -- c: {:coffee, 1}

			create l_enum.make (l_tuples)
			l_result := l_enum.uniq_by (agent (t: TUPLE [label: STRING; data: TUPLE [name: STRING; i: INTEGER]]):  TUPLE [name: STRING; i: INTEGER]
				do
					Result := t.data
				end).to_array

				-- Should keep [a: {:tea, 2}, c: {:coffee, 1}], dropping b: {:tea, 2}
			assert ("correct number of unique elements", l_result.count = 2)
			assert ("first element kept",
				l_result[1].label ~ "a" and
				l_result[1].data.name ~ "tea" and
				l_result[1].data.i = 2)
			assert ("last element kept",
				l_result[2].label ~ "c" and
				l_result[2].data.name ~ "coffee" and
				l_result[2].data.i = 1)
		end


    test_map_hash_values
            -- Test mapping over hash table values and transforming them
        local
            l_enum: ENUM [TUPLE [key: READABLE_STRING_GENERAL; value: STRING]]
            l_hash: STRING_TABLE [STRING]
            l_result: ARRAY [STRING_GENERAL]
        do
            	-- Create and populate hash table
            create l_hash.make (2)
            l_hash.put ("willy", "name")
            l_hash.put ("wonka", "last_name")

            	-- Create enum from converted hash table
            create l_enum.make (hash_to_list (l_hash))

            	-- Map over the values and convert to uppercase
            l_result := l_enum.map_to_string (agent (t: TUPLE [key: READABLE_STRING_GENERAL; value: STRING_8]): STRING_8
                do
                    Result := t.value.as_upper
                end).to_array

            	-- Verify results (note: hash order is not guaranteed)
            assert ("correct number of elements", l_result.count = 2)
            assert ("contains WILLY", across l_result as s some s ~ "WILLY" end)
            assert ("contains WONKA", across l_result as s some s ~ "WONKA" end)
        end


      test_map_hash_values_with_factory
            -- Test mapping over hash table values and transforming them
        local
            l_enum: ENUM [TUPLE [key: READABLE_STRING_GENERAL; value: STRING]]
            l_hash: STRING_TABLE [STRING]
            l_result: ARRAY [STRING_GENERAL]
        do
            	-- Create and populate hash table
            create l_hash.make (2)
            l_hash.put ("willy", "name")
            l_hash.put ("wonka", "last_name")

            	-- Create enum from converted hash table
            l_enum := {ENUM_TABLE_FACTORY[STRING]}.from_string_table(l_hash)

            	-- Map over the values and convert to uppercase
            l_result := l_enum.map_to_string (agent (t: TUPLE [key: READABLE_STRING_GENERAL; value: STRING_8]): STRING_8
                do
                    Result := t.value.as_upper
                end).to_array

            	-- Verify results (note: hash order is not guaranteed)
            assert ("correct number of elements", l_result.count = 2)
            assert ("contains WILLY", across l_result as s some s ~ "WILLY" end)
            assert ("contains WONKA", across l_result as s some s ~ "WONKA" end)
        end



feature {NONE} -- Implementation

    hash_to_list (a_hash: STRING_TABLE [STRING]): ARRAYED_LIST [TUPLE [key: READABLE_STRING_GENERAL; value: STRING]]
            -- Convert hash table to list of tuples
        do
            create Result.make (a_hash.count)
            from
            	a_hash.start
            until
            	a_hash.after
            loop
                Result.extend (a_hash.key_for_iteration, a_hash.item_for_iteration)
                a_hash.forth
            end
        end



end

