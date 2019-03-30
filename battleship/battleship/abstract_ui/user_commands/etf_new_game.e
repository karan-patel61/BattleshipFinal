note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_GAME
inherit
	ETF_NEW_GAME_INTERFACE
		redefine new_game end
create
	make
feature -- command
	new_game(level: INTEGER_64)
		require else
			new_game_precond(level)
    	do
			-- perform some update on the model state
			if model.g.board.history.count >= 1 and (not model.g.undo_used) and (not model.g.redo_used) then
				model.set_state
			end
			model.default_update
			if model.g.board.history.count = 0 then
				model.set_state
			end
				if level = 13 then
					model.new_game (False, 4, 2,8,2)
				elseif level = 14 then
					model.new_game (False, 6, 3,16,3)
				elseif level = 15 then
					model.new_game (False, 8, 5,24,5)
				elseif level = 16 then
					model.new_game (False, 12, 7,44,7)
				end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
