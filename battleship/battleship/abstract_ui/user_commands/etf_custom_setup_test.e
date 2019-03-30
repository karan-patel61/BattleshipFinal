note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_CUSTOM_SETUP_TEST
inherit
	ETF_CUSTOM_SETUP_TEST_INTERFACE
		redefine custom_setup_test end
create
	make
feature -- command
	custom_setup_test(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64)
		require else
			custom_setup_test_precond(dimension, ships, max_shots, num_bombs)
    	do
			-- perform some update on the model state
			if model.g.board.history.count >= 1 and (not model.undo_used) and (not model.redo_used) then
				model.set_state
			end
			model.default_update
			if model.g.board.history.count = 0 then
				model.set_state
			end
			model.debug_game (True, dimension.as_integer_32, ships.as_integer_32, max_shots.as_integer_32, num_bombs.as_integer_32)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
