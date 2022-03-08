note
	description: "Summary description for {LIST_HIDDEN_FILES}."
	date: "$Date$"
	revision: "$Revision$"

class
	LIST_HIDDEN_FILES

create
	make

feature {NONE} -- Implementation

	make
		local
			dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
		do
			print ("%N List Hidden Files")
			create dir.make_with_path ((create {PATH}.make_current).extended("strings"))
			create stream.make (dir.entries)
			stream.filter (agent is_hidden)
			      .for_each (agent (p: PATH) do print ("%N"); print (p) end)
		end


	is_hidden (p: PATH): BOOLEAN
		local
			l_file: FILE
		do
			create {RAW_FILE} l_file.make_with_path (p)
			Result := l_file.path.name.starts_with (".")
		end


end

