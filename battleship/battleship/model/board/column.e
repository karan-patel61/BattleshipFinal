note
	description: "Summary description for {COLUMN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COLUMN
inherit
	ANY
		redefine
			out,
			is_equal
		end

create
	make

feature {COORDINATE} -- Initialization

	make(column:INTEGER)
			-- Initialization for `Current'.
		do
			item := column
		end
feature --Attribute
	item: INTEGER

feature --Query
	is_equal(other: like Current):BOOLEAN
		do
			Result := item = other.item
		end

feature --output
	out: STRING
		do
			Result := item.out
		end

invariant
	invariant_clause: item >=1 and item <=12

end
