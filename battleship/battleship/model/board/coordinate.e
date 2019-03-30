note
	description: "Summary description for {COORDINATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COORDINATE
inherit
	ANY
		redefine
			out,
			is_equal
		end
create
	make, make_from_coordinate, make_from_tuple

feature --attributes
	row: ROW
	column: COLUMN

feature{NONE} --constructor
	make(a_row: INTEGER_32; a_column: INTEGER_32)
		do
			create row.make (a_row)
			create column.make (a_column)
		end
	make_from_coordinate(other: like Current)
		do
			make(other.row.item, other.column.item)
		end
	make_from_tuple(a_tuple: TUPLE[a_r:INTEGER_32; a_c:INTEGER_32])
		do
			make(a_tuple.a_r, a_tuple.a_c)
		end

feature --Query
	is_equal(other: like Current):BOOLEAN
		do
			Result := (row.item = other.row.item) and (column.item = other.column.item)
		end

feature --output
	out: STRING
		do
			Result := "[" + row.out+", "+column.out+"]"
		end

invariant
	valid_column: column.item >= 1 and column.item <= 12

	valid_row: row.item >= 1 and row.item <= 12

end
