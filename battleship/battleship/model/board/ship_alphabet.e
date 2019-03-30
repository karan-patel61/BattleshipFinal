note
	description: "Summary description for {SHIP_ALPHABET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHIP_ALPHABET

inherit
	ANY
		redefine
			out,
			is_equal
		end

create
	make

feature -- Commands

	make (a_char: CHARACTER)
		do
			item := a_char
		end

feature -- Attributes

	item: CHARACTER

feature --Query

	is_equal(other: like Current): BOOLEAN
		do
			Result := item = other.item
		end

feature -- output

	out: STRING
			-- Return string representation of alphabet.
		do
			Result := item.out
		end

invariant
	allowable_symbols:
		item = '_' or item = 'h' or item = 'v' or item = 'O' or item = 'X'
end
