note
	description: "Object representing a Person"
	date: "$Date$"
	revision: "$Revision$"

class
	PERSON

inherit

	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING_32; a_age: NATURAL_8)
		do
			name := a_name
			age := a_age
		ensure
			name_set: name.same_string (a_name)
			age_set: age = a_age
		end

feature -- Access

	name: STRING_32
			-- Person's name.

	age: NATURAL_8
			-- Person's age.


	age_differnce (other: PERSON): NATURAL_8
		do
			Result := if age > other.age then age - other.age else other.age - age end
		end

feature -- Output

	out: STRING
		do
			Result := name + "-" + age.out
		end
end
