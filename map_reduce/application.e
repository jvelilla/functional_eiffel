note
	description: "Map Reduce Example"
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
			stream: GENERAL_STREAM [INTEGER]
			discount_price: OPTIONAL [INTEGER]
		do
			create stream.make (prices)
			discount_price := stream.filter (agent greater_than_20)
				  					.map (agent multiply)
				  					.reduce (agent add)

			discount_price.if_present (agent (p: INTEGER) do print ("Total of discounted prices:" + p.out) end)
		end


	prices: ARRAYED_LIST [INTEGER]
		do
			create Result.make_from_array (<<10, 30, 17, 20, 15, 18, 45, 12>>)
		end

	greater_than_20 (a_item: INTEGER): BOOLEAN
		do
			Result := a_item > 20
		end

	multiply (a_item: INTEGER): INTEGER
		local
			l_result: REAL_64
		do
			l_result := (a_item * 0.9)
			Result := l_result.floor
		end

	add (x, y: INTEGER): INTEGER
		do
			Result :=  x + y
		end

end
