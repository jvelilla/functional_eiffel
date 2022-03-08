note
	description: "Summary description for {LIST_SUBDIRECTORIES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LIST_SUBDIRECTORIES

create
	make

feature {NONE} -- Implementation

	make
		local
			dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
			list: ARRAYED_LIST [PATH]
		do
			print ("%N List subdirectories dirs")
			create dir.make_with_path (create {PATH}.make_current)
			create list.make_from_iterable ({GENERAL_STREAM [PATH]}.of_values (dir.resolved_entries)
				.filter (agent exclude_dirs)
				.flat_map (agent subdirectories).collect (agent array_factory))

			across list as ic loop
				print (ic)
				print ("%N")
			end
			print ("%NCount:" + list.count.out)
		end

	exclude_dirs (p: PATH): BOOLEAN
		do
			if p.name.ends_with ("\.") or else p.name.ends_with ("\..") then
				Result := False
			else
				Result := True
			end
		end

	subdirectories (a_path: PATH): GENERAL_STREAM [PATH]
		local
			l_dir: DIRECTORY
			stream: GENERAL_STREAM [PATH]
		do
			create l_dir.make_with_path (a_path)
			if l_dir.resolved_entries.is_empty then
				Result := {GENERAL_STREAM [PATH]}.of (a_path)
			else
				create stream.make (l_dir.resolved_entries)
				create Result.make(stream.filter (agent exclude_dirs))
			end
		end

	array_factory: ARRAYED_LIST [PATH]
		do
			create Result.make (0)
		end

end

