note
	description: "Summary description for {REAL_32_STREAM}."
	date: "$Date$"
	revision: "$Revision$"

class
	REAL_32_STREAM

inherit

	GENERAL_STREAM [REAL_32]
		rename
			reduce as reduce_stream,
			reduce_with_identity as reduce_with_identity_stream
		redefine
			new_cursor
		end

create
	make

feature -- Reduce

	reduce (a_function: FUNCTION [REAL_32, REAL_32, REAL_32]): REAL_32
			-- Reduce the items of the stream using the identity value 	`REAL_32`
			-- and apply the function `a_function`.
		local
			l_res: OPTIONAL [REAL_32]
		do
			l_res := reduce_stream (a_function)
			Result := l_res.or_else (0.0)
		end

	reduce_with_identity (identity: REAL_32; a_function: FUNCTION [REAL_32, REAL_32, REAL_32]): REAL_32
			-- Reduce the items of the stream using the identity value 	`REAL_32`
			-- and apply the function `a_function`.
		do
			Result := reduce_with_identity_stream (identity, a_function)
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [REAL_32]
			-- Fresh cursor associated with current structure
		do
			Result := iterable.new_cursor
		end

end
