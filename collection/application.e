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
			i: INTEGER
			fog: FUNCTION [TUPLE [INTEGER], INTEGER]
		do
				-- Old iteration
			print ("Using the old iteration style%N")
			from
				i := 1
			until
				i > friends.count
			loop
				print ({STRING_32} "%N" + friends.at (i))
				i := i + 1
			end

				-- Using across

			print ("%N%NUsing across iteration style%N")
			across friends as ic loop print ({STRING_32} "%N" + ic) end

				-- Using agents declarative way.
			print ("%N%NUsing funtctional style with agents%N")
			friends.do_all (agent accept)

				-- Using inline agents
			print ("%N%NUsing funtctional style with inline agents%N")
			friends.do_all (agent (item: STRING_32) do print ("%N" + item) end)

			print ("%N%NTransform a lists of elements to upper case, imperative%N")
			transform_list_imperative

			print ("%N%NTransform a lists of elements to upper case, functional%N")
			transform_list_functional

			print ("%N%NTransform a lists of elements to upper case, using FUNCTION_STREAMS.map%N")
			transform_list_stream


			print ("%N%NTransform a lists of elements to upper case, using FUNCTION_STREAMS.map_to_any%N")
			transform_list_stream_2


			print ("%N%NPick elements functional way%N")
			pick_elements

			print ("%N%NPick elements functional way, naive approach%N")
			pick_elements_multiple_collections

			print ("%N%NPick elements functional way, dry approach%N")
			pick_elements_multiple_collections_dry

			print ("%N%NPick different names, duplication%N")
			pick_different_names

			print ("%N%NPick different names, DRY%N")
			pick_different_names_dry

			print ("%NCurrying%N")
			fog := g(2)
			print (fog(7))

			print ("%N%NPick the first name with letter %N")
			pick_name (friends, "N")
			pick_name (friends, "Z")

			print ("%NTotal number of characters%N")
			total_number_of_characters

			print ("%NLonges name%N")
			longest_name

			print ("%NLonges name with identity%N")
			longest_name_with_identity

			print ("%N Joining Elements")
			joining_elements
		end

	transform_list_imperative
		local
			uppercase_names: LIST [STRING_32]
			l_str: STRING_32
		do
			create {ARRAYED_LIST [STRING_32]} uppercase_names.make (friends.count)
			across friends as item loop l_str := item; l_str.to_upper; uppercase_names.force (l_str) end
			across uppercase_names as item loop print ("%N" + item) end
		end

	transform_list_functional
		local
			uppercase_names: LIST [STRING_32]
		do
			create {ARRAYED_LIST [STRING_32]} uppercase_names.make_from_iterable (friends)
			uppercase_names.do_all (agent (item: STRING_32) do item.to_upper end)
			uppercase_names.do_all (agent (item: STRING_32) do print ("%N" + item) end)
		end


	transform_list_stream
		local
			stream: GENERAL_STREAM [STRING_32]
		do
			create stream.make (friends)
			stream.map (agent (item: STRING_32): STRING_32 do Result := item; Result.to_upper end)
				  .for_each (agent (item: STRING_32) do print ("%N" + item) end)
		end

	transform_list_stream_2
		local
			stream: GENERAL_STREAM [STRING_32]
		do
			create stream.make (friends)
			stream.map_to_integer_64 (agent (item: STRING_32): INTEGER_64 do Result := item.count end)
				  .for_each (agent (item: INTEGER_64) do print ("%N" + item.out) end)
		end

	pick_elements
		local
			stream: GENERAL_STREAM [STRING_32]
			list: LIST [STRING_32]
		do
			create stream.make (friends)
			list := stream.filter (agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end)
						  .to_arrayed_list
			list.do_all (agent (item: STRING_32) do print (item + " ") end)
			print ("%NFound:"  + list.count.out + " names")
		end


	pick_elements_multiple_collections
		local
			stream: GENERAL_STREAM [STRING_32]
			list: LIST [STRING_32]
			friends_start_with_N: INTEGER
			editors_start_with_N: INTEGER
			comrades_start_with_N: INTEGER
		do
				-- Naive approach filter names that start with letter `N`
				-- issues duplicated code in the inline agents.
			create stream.make (friends)
			friends_start_with_N := stream.filter (agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end).count
			print ("%NFound:"  + friends_start_with_N.out + " friends")

			create stream.make (editors)
			editors_start_with_N := stream.filter (agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end).count
			print ("%NFound:"  + friends_start_with_N.out + " editors")

			create stream.make (comrades)
			comrades_start_with_N := stream.filter (agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end).count
			print ("%NFound:"  + friends_start_with_N.out + " comrades")

		end


	pick_elements_multiple_collections_dry
		local
			stream: GENERAL_STREAM [STRING_32]
			list: LIST [STRING_32]
			friends_start_with_N: INTEGER
			editors_start_with_N: INTEGER
			comrades_start_with_N: INTEGER
			start_with_N: PREDICATE [STRING_32]
		do
				-- Dont repeat yourself, extract the inline agent in a variable start_with_N.

			start_with_N := agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end
			create stream.make (friends)
			friends_start_with_N := stream.filter (start_with_n).count
			print ("%NFound:"  + friends_start_with_N.out + " friends")

			create stream.make (editors)
			editors_start_with_N := stream.filter (start_with_n).count
			print ("%NFound:"  + friends_start_with_N.out + " editors")

			create stream.make (comrades)
			comrades_start_with_N := stream.filter (start_with_n).count
			print ("%NFound:"  + friends_start_with_N.out + " comrades")

		end


	pick_different_names
		local
			stream: GENERAL_STREAM [STRING_32]
			list: LIST [STRING_32]
			friends_start_with_N: INTEGER
			friends_start_with_B: INTEGER
			start_with_N: PREDICATE [STRING_32]
			start_with_B: PREDICATE [STRING_32]
		do
				-- Still we have some code duplication in agents definitions.

			start_with_N := agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("N") end
			start_with_B := agent (item: STRING_32): BOOLEAN do Result := item.starts_with ("B") end

			create stream.make (friends)
			friends_start_with_N := stream.filter (start_with_n).count
			print ("%NFound start with N:"  + friends_start_with_N.out + " friends")

			friends_start_with_B := stream.filter (start_with_b).count
			print ("%NFound: start with B:"  + friends_start_with_B.out + " friends")

		end


	pick_different_names_dry
		local
			stream: GENERAL_STREAM [STRING_32]
			list: LIST [STRING_32]
			friends_start_with_N: INTEGER
			friends_start_with_B: INTEGER
			x: attached STRING_32
			pred: PREDICATE [STRING_32]
		do
				-- Still we have some code duplication in agents definitions.


			create stream.make (friends)
			friends_start_with_N := stream.filter (agent start_with_letter (?, {STRING_32}"N") ).count
			print ("%NFound start with N:"  + friends_start_with_N.out + " friends")

			friends_start_with_B := stream.filter (agent start_with_letter (?, {STRING_32}"B")).count
			print ("%NFound: start with B:"  + friends_start_with_B.out + " friends")

			x := "B"
			pred:=  agent (item: STRING_32; a_letter: STRING_32): BOOLEAN
              do
                 Result := item.starts_with (a_letter)
              end (?, x)

    		friends_start_with_B := stream.filter (pred).count
			print ("%NFound: start with B:"  + friends_start_with_B.out + " friends")

		end

	pick_name (a_names: LIST [STRING_32]; a_letter: STRING_32)
		local
			stream: GENERAL_STREAM [STRING_32]
			res: OPTIONAL [STRING_32]
		do
			create stream.make (a_names)
			res := stream.filter (agent start_with_letter (?, a_letter) )
				  .find_first

			print ("%NA name starting with " + a_letter + " " + res.or_else ("Not found"))

			res.if_present (agent (item: STRING_32)do print ("%NHola: " + item) end)
		end

	total_number_of_characters
		local
			stream: GENERAL_STREAM [STRING_32]
		do
			create stream.make (friends)
			print ("%NTotal number of characters in all names: " + stream.map_to_integer_32 (agent {STRING_32}.count).sum_integer_32.out)
		end

	longest_name
		local
			stream: GENERAL_STREAM [STRING_32]
			res: OPTIONAL [STRING_32]
		do
			create stream.make (friends)
			res := stream.reduce (agent (name1, name2: STRING_32): STRING_32
									do
										Result := if name1.count >= name2.count then name1 else name2 end
								end)
			res.if_present (agent (name: STRING_32) do print ("A longes name:" + name) end)
		end

	longest_name_with_identity
		local
			stream: GENERAL_STREAM [STRING_32]
			res: STRING_32
		do
			create stream.make (friends)
			res := stream.reduce_with_identity ("Richard", agent (name1, name2: STRING_32): STRING_32
									do
										Result := if name1.count >= name2.count then name1 else name2 end
								end)
			print ("A longes name:" + res)
		end

	joining_elements
		local
			stream: GENERAL_STREAM [STRING_32]
			res: OPTIONAL [STRING_32]
		do
			create stream.make (friends)
			res := stream.map (agent (item: STRING_32): STRING_32 do Result := item; Result.to_upper end)
				  .reduce(agent (str1, str2: STRING_32): STRING_32
				  				do
				  					Result := str1
				  					Result.append (" , ")
									Result.append (str2)
								end)
			res.if_present (agent (item: STRING_32) do print ("%NJoined Strings:" + item) end)
		end
		
	start_with_letter (item: STRING_32; a_letter: STRING): BOOLEAN
		do
			Result := item.starts_with (a_letter)
		end

	accept (a_item: STRING_32)
		do
			print ("%N" + a_item)
		end

	friends: LIST [STRING_32]
		once
			create {ARRAYED_LIST [STRING_32]} Result.make_from_array (<<"Brian", "Nate", "Neal", "Raju", "Sara", "Scott">>)
		end

	editors: LIST [STRING_32]
		once
			create {ARRAYED_LIST [STRING_32]} Result.make_from_array (<<"Brian", "Jackie", "John", "Mike">>)
		end

	comrades: LIST [STRING_32]
		once
			create {ARRAYED_LIST [STRING_32]} Result.make_from_array (<<"Kate", "Ken", "Nick", "Paula", "Zach">>)
		end

	 g (x: INTEGER): FUNCTION [TUPLE [INTEGER], INTEGER]
       do
           Result := agent (closed_x: INTEGER; y: INTEGER): INTEGER
              do
                 Result := f (closed_x, y)
              end (x, ?)
       end

	f (x: INTEGER; y: INTEGER): INTEGER
		do
			Result := x + y
		end

end
