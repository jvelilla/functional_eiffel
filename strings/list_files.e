note
	description: "Summary description for {LIST_FILES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LIST_FILES

create
	make

feature {NONE} -- Implementation

	make
		local
			dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
		do
			print ("%N List files")
			create dir.make_with_path (create {PATH}.make_current)
			create stream.make (dir.entries)
			stream.for_each (agent (p: PATH) do print ("%N"); print (p) end)
		end
end
