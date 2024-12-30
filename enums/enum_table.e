note
	description: "Summary description for {ENUM_TABLE}."
	date: "$Date$"
	revision: "$Revision$"

class
	ENUM_TABLE [G, K -> detachable HASHABLE]

inherit

	TABLE_ITERABLE [G, K]

create
	make

feature {NONE} -- Initialization

	make (a_iterable: TABLE_ITERABLE [G, K])
			-- Create a new enum from an iterable
		do
			iterable := a_iterable
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

feature -- Conversion

	to_enum: ENUM [TUPLE [key: K; value: G]]
			-- Create a new enum from a hash table
		do
			create Result.make (hash_to_list)
		end

feature -- Grouping

	group_by (a_key_fun: FUNCTION [K, G]): HASH_TABLE [ARRAYED_LIST [G], K]
			-- Groups elements by key_fun, preserving order within groups
			-- TODO fix.
		local
			l_cursor: TABLE_ITERATION_CURSOR [G, K]
			l_result: G
		do
			l_cursor := new_cursor
			create Result.make (10)

			from
			until
				l_cursor.after
			loop
				l_result := a_key_fun.item (l_cursor.key)
				add_to_group (Result, l_result, l_cursor.key)
				l_cursor.forth
			end
		end

feature {NONE} -- Implementation

	hash_to_list: ARRAYED_LIST [TUPLE [key: K; value: G]]
			-- Convert hash table to list of tuples
		local
			l_cursor: TABLE_ITERATION_CURSOR [G, K]
		do
			l_cursor := new_cursor
			create Result.make (count)
			from
			until
				l_cursor.after
			loop
				Result.extend (l_cursor.key, l_cursor.item)
				l_cursor.forth
			end
		end

	add_to_group (a_groups: HASH_TABLE [ARRAYED_LIST [G], K]; a_element: G; a_key: K)
			-- Add element to its group, creating group if needed
		do
			if not a_groups.has_key (a_key) then
				a_groups.put (create {ARRAYED_LIST [G]}.make (10), a_key)
			end
			check attached a_groups.item (a_key) as l_group then
				l_group.extend (a_element)
			end
		end

feature -- Access

	iterable: TABLE_ITERABLE [G, K]

feature

	new_cursor: TABLE_ITERATION_CURSOR [G, K]
			-- Fresh cursor associated with current structure
		do
			Result := iterable.new_cursor
		end

end
