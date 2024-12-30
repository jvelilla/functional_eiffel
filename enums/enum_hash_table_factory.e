note
	description: "Summary description for {ENUM_HASH_TABLE_FACTORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENUM_HASH_TABLE_FACTORY [G, K -> detachable HASHABLE]


feature -- factory

	from_table (a_table: HASH_TABLE [G, K]): ENUM [TUPLE [key: K; value: G]]
			-- Create a new enum from a hash table
		do
			create Result.make (hash_to_list (a_table))
		ensure
			instance_free: class
		end


feature {NONE} -- Implementation

	hash_to_list (a_hash: HASH_TABLE [G, K]): ARRAYED_LIST [TUPLE [key: K; value: G]]
            -- Convert hash table to list of tuples
        do
            create Result.make (a_hash.count)
            from
            	a_hash.start
            until
            	a_hash.after
            loop
                Result.extend (a_hash.key_for_iteration, a_hash.item_for_iteration)
                a_hash.forth
            end
        ensure
        	instance_free: class
        end


end
