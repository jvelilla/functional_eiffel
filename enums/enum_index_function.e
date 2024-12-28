note
	description: "Summary description for {ENUM_INDEX_FUNCTION}."
	date: "$Date$"
	revision: "$Revision$"

class
    ENUM_INDEX_FUNCTION [G, R]
    -- Handles function application with index for enumerable elements

create
    make

feature {NONE} -- Initialization

    make (a_function: FUNCTION [G, INTEGER, R])
            -- Create with mapping function
        do
            mapper := a_function
        end

feature -- Access

    mapper: FUNCTION [G, INTEGER, R]
            -- Function to map element and index to result

feature -- Operations

    with_index (a_iterable: ITERABLE[G]): ENUM [R]
            -- Maps each element with its index using provided function
            -- Index is zero-based
        local
            l_result: ARRAYED_LIST [R]
            l_index: INTEGER
        do
            create l_result.make (count_of_iterable(a_iterable))
            across a_iterable as ic loop
                l_result.extend (mapper.item ([ic, l_index]))
                l_index := l_index + 1
            end
            create Result.make (l_result)
        end

feature {NONE} -- Implementation

    count_of_iterable (a_iterable: ITERABLE [G]): INTEGER
            -- Count elements in iterable
        do
            across a_iterable as ic loop
                Result := Result + 1
            end
        end
end
