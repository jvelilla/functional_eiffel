note
	description: "Summary description for {OPTIONAL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONAL [T]

create
	make,
	make_with_value

feature {NONE} -- Initialization

	make
		do
		end

	make_with_value (a_value: T)
		do
			value := a_value
		ensure
			attached_value: attached value as l_value and then value ~ a_value
		end

	value: detachable T
			-- Current value.

feature -- Status

	empty: OPTIONAL [T]
			-- Return an empty Optional object.
		do
			create Result.make
		end

	or_else (a_other: T): T
			-- If the value is present return the value, otherwise return `a_other`.
		do
			if attached value as l_value then
				Result := l_value
			else
				Result := a_other
			end
		end

	if_present (action: PROCEDURE [T])
			-- call the action `action` if the value is present, otherwise
			-- do nothing.
		do
			if attached value as l_value then
				action.call (l_value)
			end
		end

end
