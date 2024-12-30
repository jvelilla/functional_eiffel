note
	description: "Summary description for {ENUM_TABLE_FACTORY}."
	date: "$Date$"
	revision: "$Revision$"

class
	ENUM_TABLE_FACTORY [G]

inherit

	ENUM_HASH_TABLE_FACTORY [G, READABLE_STRING_GENERAL]


feature -- factory

	from_string_table (a_table: STRING_TABLE [G]): ENUM [TUPLE [key: READABLE_STRING_GENERAL; value: G]]
			-- Create a new enum from a string table
		do
			create Result.make (hash_to_list (a_table))
		ensure
			instance_free: class
		end


end
