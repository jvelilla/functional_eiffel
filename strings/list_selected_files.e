note
	description: "Summary description for {LIST_SELECTED_FILES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LIST_SELECTED_FILES

create
	make

feature {NONE} -- Implementation

	make
		local
			dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
		do
			print ("%N List Selected files")
			create dir.make_with_path ((create {PATH}.make_current).extended("strings"))
			create stream.make (dir.entries)
			stream.filter (agent (p: PATH): BOOLEAN do Result := p.name.ends_with (".e") end)
				  .for_each (agent (p: PATH) do print ("%N"); print("strings"); print(p.directory_separator); print (p) end)
		end
end
