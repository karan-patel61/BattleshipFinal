note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_BOMB
inherit
	ETF_BOMB_INTERFACE
		redefine bomb end
create
	make
feature -- command
	bomb(coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
		require else
			bomb_precond(coordinate1, coordinate2)
    	do
			-- perform some update on the model state
			if model.g.board.history.count >= 1 and (not model.g.undo_used) and (not model.g.redo_used) then
				model.set_state
			end
			model.default_update
			model.bomb (coordinate1.row.as_integer_32, coordinate1.column.as_integer_32, coordinate2.row.as_integer_32, coordinate2.column.as_integer_32)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
