note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
		redefine fire end
create
	make
feature -- command
	fire(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
		require else
			fire_precond(coordinate)
    	do
			-- perform some update on the model state
			if model.g.board.history.count >= 1 and (not model.g.undo_used) and (not model.g.redo_used) then
				model.set_state
			end
			model.default_update
			model.fire (coordinate.row.as_integer_32, coordinate.column.as_integer_32)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
