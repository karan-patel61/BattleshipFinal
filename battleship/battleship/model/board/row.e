note
	description: "Summary description for {ROW}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ROW
inherit
	ANY
		redefine
			out,
			is_equal
		end
create
	make

feature {NONE} -- Initialization

	make(row:INTEGER)
			-- Initialization for `Current'.
		do
			item := row
		end

feature -- Attributes
	item: INTEGER

feature --Query
	is_equal(other: like Current):BOOLEAN
		do
			Result := item = other.item
		end

feature --output
	out: STRING
		local
			temp: CONSTANT
		do
			create Result.make_empty
			Result.append (temp.indicies[item])
		end

invariant
	invariant_clause: item >=1 and item <=12

end
