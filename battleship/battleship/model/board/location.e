note
	description: "Summary description for {LOCATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOCATION
inherit
	ANY
		redefine
			out
		end

create
	make

feature -- Attribute
	coordinate: COORDINATE
	status: SHIP_ALPHABET

feature {NONE} -- Initialization

	make(a_coor:COORDINATE; a_state:BOOLEAN)
			-- Initialization for `Current'.
		do
			create coordinate.make_from_coordinate (a_coor)
			if a_state then
				create status.make ('v')
			else
				create status.make ('h')
			end
		end

feature --Command

	hit
	-- change the status of the location to X for v or h
		do
			if not is_hit then
				status.make ('X')
			end
		end
	restore(ship_direction:BOOLEAN)
		do
			if ship_direction then
				status.make ('v')
			else
				status.make ('h')
			end
		end

feature --Query
	is_hit:BOOLEAN
		do
			if status.item.is_equal ('X') then
				Result := True
			else
				Result := False
			end
		end
	is_miss:BOOLEAN
		do
			if status.item.is_equal ('O') then
				Result := True
			else
				Result := False
			end
		end

feature--output
	out:STRING
		do
			Result := coordinate.out+ "->"+ status.out+ ""
		end

end
