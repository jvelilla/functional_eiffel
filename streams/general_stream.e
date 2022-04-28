note
	description: "[
			General Class implementing map reduce pattern
			Note: the current implementation does not implement
			As a proof of concept, every operation loops through all the elements of the streams.
			TODO: Implement the Pipeline desing pattern, so we can chain different operations, until
			we reach a terminal operation. So all the intermediate opertions are delayed until we 
			invoke the terminal operation (Lazy evaluation.)


		]"
	date: "$Date$"
	revision: "$Revision$"

class
	GENERAL_STREAM [T]

inherit

 	ITERABLE [T]


create
	make

feature {NONE} -- Initialization

	make (a_iterable: ITERABLE [T])
			-- Create a new function stream from an iterable
			-- `a_iterable`.
		do
			iterable := a_iterable
		end

feature {GENERAL_STREAM}

	iterable: ITERABLE [T]
			-- Current iterable.

feature -- Filter

	filter (a_predicate: PREDICATE [T]): GENERAL_STREAM [T]
			-- Return new function stream consisting of the results that match the given
			-- predicate `a_predicate` to the items of this stream.
		local
			l_result: ARRAYED_LIST [T]
		do
			create {ARRAYED_LIST [T]} l_result.make (2)
			across iterable as ic loop
				if a_predicate.item (ic) then
					l_result.force (ic)
				end
			end
			create Result.make (l_result)
		end

	filter_with_args (a_predicate: PREDICATE [T, T]): GENERAL_STREAM [T]
			-- Return new function stream consisting of the results that match the given
			-- predicate `a_predicate` to the items of this stream.
		local
			l_result: ARRAYED_LIST [T]
			l_res: T
			found: BOOLEAN
		do
			create {ARRAYED_LIST [T]} l_result.make (2)
			across iterable as ic loop
				if found and attached l_res as res then
					if a_predicate.item (res, ic) then
						l_res := res
					else
						l_res := ic
					end
				else
					l_res := ic
					found := True
				end
			end
			create Result.make (l_result)
		end

feature -- Sorted

	sorted (comparator: PREDICATE [T, T]): GENERAL_STREAM [T]
			-- Sort a stream using `comparator`.
		local
			l_sorter: SORTER [T]
			l_iterable: ARRAYED_LIST [T]
		do
			create l_iterable.make_from_iterable (iterable)
			create {QUICK_SORTER [T]} l_sorter.make ((create {AGENT_EQUALITY_TESTER [T]}.make (comparator)))
			l_sorter.sort (l_iterable)
			create Result.make (l_iterable)
		end


feature -- Stream

	of (value: T): GENERAL_STREAM [T]
			-- Return a stream `GENERAL_STREAM` with a single element.
		do
			create Result.make (create {ARRAYED_LIST [T]}.make_from_array ({ARRAY [T]}<<value>>))
		ensure
			is_class: class
		end

	of_values (values: ITERABLE [T]): GENERAL_STREAM [T]
			-- Return an stream from `values`.
		do
			create Result.make (values)
		ensure
			is_class: class
		end


feature -- Map

	map (a_function: FUNCTION [T, T]): GENERAL_STREAM [T]
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [T]
		do
			create {ARRAYED_LIST [T]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_any (a_function: FUNCTION [T, ANY]): GENERAL_STREAM [ANY]
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [ANY]
		do
			create {ARRAYED_LIST [ANY]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_integer_64 (a_function: FUNCTION [T, INTEGER_64]): INTEGER_64_STREAM
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [INTEGER_64]
		do
			create {ARRAYED_LIST [INTEGER_64]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_integer_32 (a_function: FUNCTION [T, INTEGER_32]): INTEGER_32_STREAM
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [INTEGER_32]
		do
			create {ARRAYED_LIST [INTEGER_32]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_natural_8 (a_function: FUNCTION [T, NATURAL_8]): NATURAL_8_STREAM
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [NATURAL_8]
		do
			create {ARRAYED_LIST [NATURAL_8]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_real_64 (a_function: FUNCTION [T, REAL_64]): REAL_64_STREAM
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [REAL_64]
		do
			create {ARRAYED_LIST [REAL_64]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	map_to_real_32 (a_function: FUNCTION [T, REAL_32]): REAL_32_STREAM
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [REAL_32]
		do
			create {ARRAYED_LIST [REAL_32]} l_result.make (2)
			across iterable as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

	flat_map (a_function: FUNCTION [T, GENERAL_STREAM[T]]): GENERAL_STREAM [T]
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [T]
		do
			create {ARRAYED_LIST [T]} l_result.make (2)
			across iterable as ic loop
				l_result.append (create {ARRAYED_LIST [T]}.make_from_iterable (a_function.item (ic).iterable))
			end
			create Result.make (l_result)
		end

feature -- Reduce

	reduce (a_function: FUNCTION [T, T, T]): OPTIONAL [T]
			-- Reduce the items of the stream applying the function `a_function`.
		local
			l_result: T
			found: BOOLEAN
		do
			across iterable as ic loop
				if found and attached l_result as res then
					l_result := a_function.item (res, ic)
				else
					l_result := ic
					found := True
				end
			end
			if attached l_result then
				create Result.make_with_value (l_result)
			else
				create Result.make
			end
		end

	reduce_with_predicate (a_predicate: PREDICATE [T, T]): OPTIONAL [T]
			-- Reduce the items of the stream applying the predicate `a_predicate`.
		local
			l_result: T
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
			if attached l_result then
				create Result.make_with_value (l_result)
			else
				create Result.make
			end
		end

	reduce_with_identity (a_identity: T; a_function: FUNCTION [T, T, T]): T
			-- Reduce the items of the stream using the identity value `a_identity` and apply the function `a_function`.
		local
			l_result: T
		do
			l_result := a_identity
			across iterable as ic loop
				if attached l_result as res then
					l_result := a_function.item (res, ic)
				end
			end
			Result := l_result
		end

feature -- Iteration

	for_each (action: PROCEDURE [T])
			-- Apply an action `action` for each element in Current.
		do
			across iterable as ic loop
				action.call (ic)
			end
		end

feature -- Collect

	to_arrayed_list: ARRAYED_LIST [T]
			-- Convert Current to an arrayed list implementation.
		do
			create Result.make_from_iterable (iterable)
		end

	find_first: OPTIONAL [T]
			-- Return the first element of Current if any, otherwise
			-- a default value.
		local
			item: T
		do
			across iterable as ic from
			until
				attached item
			loop
				item := ic
			end

			if attached item then
				create Result.make_with_value (item)
			else
				create Result.make
			end
		end

	collect (target: FUNCTION[ITERABLE[T]]):ITERABLE [T]
		do
			create {ARRAYED_LIST [T]} Result.make_from_iterable(target.item)
			if attached {ARRAYED_LIST [T]} Result as l_arrayed_list then
				l_arrayed_list.copy ((create {ARRAYED_LIST [T]}.make_from_iterable (iterable)))
			end
		end


feature -- Status Report

	count: INTEGER
			-- Count the elemens int current.
		do
			Result := 0
			across iterable as ic loop Result := Result + 1 end
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [T]
			-- Fresh cursor associated with current structure
		do
			Result := iterable.new_cursor
		end

end
