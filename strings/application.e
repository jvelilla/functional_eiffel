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
			str: LOOP_STRINGS
			files: LIST_FILES
			dirs: LIST_DIRS
			selected: LIST_SELECTED_FILES
			hidden: LIST_HIDDEN_FILES
			subdirs: LIST_SUBDIRECTORIES
		do
--			create str.make
			persons := <<create {PERSON}.make ("John", 20), create {PERSON}.make ("Sara", 21), create {PERSON}.make ("Jane", 21),  create {PERSON}.make ("Greg", 35)>>
--			print ("%NMax Element%N")
--			max_element
--			print ("%NMin Element%N")
--			min_element
--			print ("%NSorting in ascending order%N")
--			sort_asc
--			print ("%NSorting in descending order%N")
--			sort_desc
--			print ("%NFiltering Data")
--			older_than_20
--			create files.make
--			create dirs.make
--			create selected.make
--			create hidden.make
			create subdirs.make
		end


	sort_asc
		local
			l_stream: GENERAL_STREAM [PERSON]
		do
			create l_stream.make (persons)
				-- Sorted in ascending order by name.
			across l_stream.sorted (agent (p1, p2: PERSON): BOOLEAN do Result := p1.name < p2.name  end).to_arrayed_list as ic loop print ("%N"); print (ic) end

		end

	sort_desc
		local
			l_stream: GENERAL_STREAM [PERSON]
		do
			create l_stream.make (persons)
				-- Sorted in descending order by name.
			across l_stream.sorted (agent (p1, p2: PERSON): BOOLEAN do Result := p1.name > p2.name  end).to_arrayed_list as ic loop print ("%N"); print (ic) end

		end

	max_element
		local
			stream: GENERAL_STREAM [PERSON]
			res: OPTIONAL [PERSON]
		do
			create stream.make (persons)
			res := stream.reduce_with_predicate (agent (p1: PERSON; p2: PERSON): BOOLEAN do Result := p1.age > p2.age end)
			res.if_present (agent (p: PERSON) do print ("%N" + p.out) end)
		end

	min_element
		local
			stream: GENERAL_STREAM [PERSON]
			res: OPTIONAL [PERSON]
		do
			create stream.make (persons)
			res := stream.reduce_with_predicate (agent (p1: PERSON; p2: PERSON): BOOLEAN do Result := p1.age < p2.age end)
			res.if_present (agent (p: PERSON) do print ("%N" + p.out)  end)
		end


	older_than_20
		local
			stream: GENERAL_STREAM [PERSON]
			array: ARRAYED_LIST [PERSON]
		do
			create array.make (1)
			create stream.make (persons)
			stream.filter (agent (p: PERSON): BOOLEAN do Result := p.age > 20 end)
				  .for_each (agent array.force )
			print ("%NPeople older than 20")
			across array as ic loop print ( "%N" + ic.out) end

			create stream.make (persons)
			create array.make_from_iterable (stream.filter (agent (p: PERSON): BOOLEAN do Result := p.age > 20 end)
				  								   .collect (agent array_factory))
			print ("%NPeople older than 20")
			across array as ic loop print ( "%N" + ic.out) end
		end


	group_by_age
		local
			people_by_age: HASH_TABLE [LIST[PERSON], NATURAL_8]
			collector: COLLECTOR [PERSON, NATURAL_8]
		do
			create collector.make (persons, {NATURAL_8})
			people_by_age := collector.group_by_map (agent {PERSON}.age)
		end


	same_age (p, q: NATURAL_8): BOOLEAN
		do
			Result := p = q
		end

	property (a_person: PERSON): NATURAL_8
		do

		end

	array_factory: ARRAYED_LIST [PERSON]
		do
			create Result.make (0)
		end
	persons: ARRAYED_LIST [PERSON]

end
