note
	description: "Summary description for {STREAM_MAPPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STREAM_MAPPER [T, R]

create
	make

feature {NONE} -- Initialization

	make (a_stream: GENERAL_STREAM [T]; a_type: TYPE [R])
		do
			stream := a_stream
			type:= a_type
		end

	stream: GENERAL_STREAM [T]
	type : TYPE [R]


feature -- Map

	map_to_type (a_function: FUNCTION [T, R]): GENERAL_STREAM [R]
			-- Returns a function stream consisting of the results of applying the given
			-- function `a_function` to the items of this stream.
		local
			l_result: ARRAYED_LIST [R]
		do
			create {ARRAYED_LIST [R]} l_result.make (2)
			across stream as ic loop
				l_result.force (a_function.item (ic))
			end
			create Result.make (l_result)
		end

end
