note
	description: "Summary description for {SHIP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHIP

inherit
	ANY
		redefine
			out,
			is_equal
		end


create
	make

feature {NONE} -- Initialization

	make(a_size: INTEGER_32; a_coor: COORDINATE; direction: BOOLEAN)
			-- Initialization for `Current'.
		local
			temp: COORDINATE
			t_loc: LOCATION
		do
			size := a_size
			dir := direction
			create ship_coordinate.make_empty
			create ship_location.make_empty
			if direction then
				--vertical ship
				across 1|..| a_size as i
				loop
					create temp.make (a_coor.row.item + i.item, a_coor.column.item)
					ship_coordinate.force (temp, i.item)
					create t_loc.make (temp, dir)
					ship_location.force(t_loc, i.item)
				end
			else
				--horizontal ship
				across 1|..| a_size as i
				loop
					create temp.make (a_coor.row.item , a_coor.column.item + i.item)
					create t_loc.make (temp, dir)
					ship_coordinate.force (temp, i.item)
					ship_location.force(t_loc, i.item)
				end
			end
		end

feature --Attributes
	size: INTEGER_32
	dir: BOOLEAN
	ship_coordinate: ARRAY[COORDINATE]
	ship_location: ARRAY[LOCATION]

feature --Query
	is_equal(other: like Current):BOOLEAN
		do
			Result := size = other.size and dir ~ other.dir and ship_coordinate.is_equal (other.ship_coordinate)
		end



feature --Output
	out:STRING
		do
			create Result.make_empty
			Result := ship_location.count.out+"x1: "
			across ship_location as loc
			loop

				Result.append (loc.item.out)
			end
		end

invariant
	correct_size: size >= 1 and size <=7
	correct_ship_coordinate_size: ship_coordinate.count >=1 and ship_coordinate.count <=7

end
