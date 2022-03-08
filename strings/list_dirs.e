note
	description: "Summary description for {LIST_DIRS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LIST_DIRS

create
	make

feature {NONE} -- Implementation

	make
		local
			dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
		do
			print ("%N List dirs")
			create dir.make_with_path (create {PATH}.make_current)
			create stream.make (dir.entries)
			stream.filter (agent (p:PATH):BOOLEAN do Result := (create {RAW_FILE}.make_with_path (p)).is_directory end)
			      .for_each (agent (p: PATH) do print ("%N"); print (p) end)
		end

end
