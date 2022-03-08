note
	description: "intruduction application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			cities: ARRAYED_LIST [STRING_32]
			stream: GENERAL_STREAM [INTEGER]
			discount_price: INTEGER
		do
			create cities.make_from_iterable ({ARRAY[STRING_32]}<<"Albany", "Boulder", "Chicago", "Denver", "Eugene">>)
			cities.compare_objects
			find_chicago_declarative (cities)
			find_chicago_imperative (cities)
		end


	find_chicago_imperative (a_list: LIST [STRING_32])
		do
			print ("%NFound Chicago?:" + (across a_list as ic some ic.same_string ("Chicago") end).out)
		end

	find_chicago_declarative (a_list: LIST [STRING_32])
		do
			print ("%NFound Chicago?:" + a_list.has ({STRING_32}"Chicago").out)
		end

end
