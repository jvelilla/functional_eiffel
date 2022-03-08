note
	description: "Summary description for {NATURAL_8_STREAM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NATURAL_8_STREAM

inherit

	GENERAL_STREAM [NATURAL_8]
		rename
			reduce as reduce_stream,
			reduce_with_identity as reduce_with_identity_stream
		redefine
			new_cursor
		end

create
	make

feature -- Reduce

	reduce (a_function: FUNCTION [NATURAL_8, NATURAL_8, NATURAL_8]): NATURAL_8
			-- Reduce the items of the stream using the identity value 	`NATURAL_8`
			-- and apply the function `a_function`.
		local
			l_res: OPTIONAL [NATURAL_8]
		do
			l_res := reduce_stream (a_function)
			Result := l_res.or_else (0)
		end

	reduce_with_identity (identity: NATURAL_8; a_function: FUNCTION [NATURAL_8, NATURAL_8, NATURAL_8]): NATURAL_8
			-- Reduce the items of the stream using the identity value 	`NATURAL_8`
			-- and apply the function `a_function`.
		do
			Result := reduce_with_identity_stream (identity, a_function)
		end

feature -- Operations

	sum_NATURAL_8: NATURAL_8
			-- Sum of elements in Current.
		do
			Result := reduce_with_identity (0, agent (x, y: NATURAL_8): NATURAL_8 do Result := x + y end (?, ?))
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [NATURAL_8]
			-- Fresh cursor associated with current structure
		do
			Result := iterable.new_cursor
		end

end
