note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_DEBUG_TEST
inherit
	ETF_DEBUG_TEST_INTERFACE
		redefine debug_test end
create
	make
feature -- command
	debug_test(level: INTEGER_64)
		require else
			debug_test_precond(level)
    	do
			-- perform some update on the model state
			if model.g.board.history.count >= 1 and (not model.undo_used) and (not model.redo_used) then
				model.set_state
			end
			model.default_update
			if model.g.board.history.count = 0 then
				model.set_state
			end
			if level = 13 then
				model.debug_game (True, 4, 2,8,2)

			elseif level = 14 then
				model.debug_game (True, 6, 3,16,3)

			elseif level = 15 then
				model.debug_game (True, 8, 5,24,5)

			elseif level = 16 then
				model.debug_game (True, 12, 7,44,7)

			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
