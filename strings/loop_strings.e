note
	description: "Summary description for {LOOP_STRINGS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOOP_STRINGS

create
	make

feature -- Initialization

	make
		do
				-- iterate over the string's characters.
			print ("%NIterate Strings_32%N")
			iterate_string_32
			print ("%NIterate Strings_8%N")
			iterate_string_8
			print ("%NFilter Digits %N")
			filter_digits

		end

	iterate_string_32
		local
			it_str: STRING_32_ITERATION_CURSOR
			l_str: STRING_32
		do
			l_str := "w00t"
				-- new_cursor returns an iterator over wich we can iterate.
			it_str := l_str.new_cursor
			across it_str as ic loop
				print ("%N" + ic.out)
			end
		end

	iterate_string_8
		local
			it_str: STRING_8_ITERATION_CURSOR
			l_str: STRING_8
		do
			l_str := "w00t"
			it_str := l_str.new_cursor
			across it_str as ic loop
				print ("%N" + ic.out)
			end
		end


	filter_digits
		local
			stream: GENERAL_STREAM [CHARACTER_32]
			l_str: STRING_32
		do
			l_str := "w00t"
			create stream.make (l_str.new_cursor)
			stream.filter (agent (item: CHARACTER_32): BOOLEAN do Result := item.is_digit end)
				  .for_each( agent (item: CHARACTER_32) do print (item.to_character_8.out) end)
		end


end
