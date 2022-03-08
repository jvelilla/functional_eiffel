note
	description: "Summary description for {INTEGER_64_STREAM}."
	date: "$Date$"
	revision: "$Revision$"

class
	INTEGER_64_STREAM

inherit

	GENERAL_STREAM [INTEGER_64]
		rename
			reduce as reduce_stream,
			reduce_with_identity as reduce_with_identity_stream
		redefine
			new_cursor
		end

create
	make

feature -- Reduce

	reduce (a_function: FUNCTION [INTEGER_64, INTEGER_64, INTEGER_64]): INTEGER_64
			-- Reduce the items of the stream using the identity value 	`INTEGER_64`
			-- and apply the function `a_function`.
		local
			l_res: OPTIONAL [INTEGER_64]
		do
			l_res := reduce_stream (a_function)
			Result := l_res.or_else (0)
		end

	reduce_with_identity (identity: INTEGER_64; a_function: FUNCTION [INTEGER_64, INTEGER_64, INTEGER_64]): INTEGER_64
			-- Reduce the items of the stream using the identity value 	`INTEGER_64`
			-- and apply the function `a_function`.
		do
			Result := reduce_with_identity_stream (identity, a_function)
		end

feature -- Operations


	sum_integer_64: INTEGER_64
			-- Sum of elements in Current.
		do
			Result := reduce_with_identity (0, agent (x, y: INTEGER_64): INTEGER_64 do Result := x + y end (?,?))
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [INTEGER_64]
			-- Fresh cursor associated with current structure
		do
			Result := iterable.new_cursor
		end

end
