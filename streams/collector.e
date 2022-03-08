note
	description: "Summary description for {COLLECTOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COLLECTOR [T, R  -> detachable HASHABLE]

create
	make

feature {NONE} -- Initialization

	make (a_iterable: ITERABLE [T]; a_type: TYPE[R])
		do
			iterable := a_iterable
			type := a_type
		end

	iterable: ITERABLE [T]
		-- Current iterable.

	type: TYPE [R]
		-- Current type.

feature -- features

	group_by_map (a_property: FUNCTION[T, R] ): HASH_TABLE[LIST [T], R]
		local
			r_stream: GENERAL_STREAM [R]
			mapper: STREAM_MAPPER [T, R]
			l_res: R
		do
			create mapper.make (create {GENERAL_STREAM[T]}.make (iterable), {R})
			r_stream := mapper.map_to_type (a_property)

			create Result.make (1)
			across iterable as ic loop
				l_res := a_property.item (ic)
				if Result.has (l_res) then
					-- do nothing
				else
					--create l_
				end
			end
		end
end
