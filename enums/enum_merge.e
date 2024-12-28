note
	description: "Summary description for {ENUM_MERGE}."
	date: "$Date$"
	revision: "$Revision$"

class
    ENUM_MERGE [F, S]
    -- Handles operations that merge/combine two enumerables of different types

create
    make

feature {NONE} -- Initialization

    make (a_first: ITERABLE [F]; a_second: ITERABLE [S])
            -- Create a merge operation with two iterables
        do
            first := a_first
            second := a_second
        end

feature -- Access

    first: ITERABLE [F]
            -- First iterable

    second: ITERABLE [S]
            -- Second iterable

feature -- Operations

    zip: ENUM [TUPLE [F, S]]
            -- Zips corresponding elements from both iterables into tuples
        local
            l_result: ARRAYED_LIST [TUPLE [F, S]]
            l_first_cursor: ITERATION_CURSOR [F]
            l_second_cursor: ITERATION_CURSOR [S]
        do
            create l_result.make (count_of_shortest)
            l_first_cursor := first.new_cursor
            l_second_cursor := second.new_cursor

            from
            until
                l_first_cursor.after or l_second_cursor.after
            loop
                l_result.extend ([l_first_cursor.item, l_second_cursor.item])
                l_first_cursor.forth
                l_second_cursor.forth
            end

            create Result.make (l_result)
        end

feature {NONE} -- Implementation

    count_of_shortest: INTEGER
            -- Returns count of shorter iterable
        local
            l_first_count, l_second_count: INTEGER
        do
            across first as ic loop
                l_first_count := l_first_count + 1
            end
            across second as ic loop
                l_second_count := l_second_count + 1
            end
            Result := l_first_count.min (l_second_count)
        end

end
