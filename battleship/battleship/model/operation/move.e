note
	description: "Summary description for {MOVE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MOVE

feature{NONE}

	game: GAME
		local
			ma: ETF_MODEL_ACCESS
		do
			Result := ma.m.g
		end

	model:ETF_MODEL
		local
			ma: ETF_MODEL_ACCESS
		do
			Result := ma.m
		end
feature -- attributes
	old_game_msg, old_board_msg: STRING
	state, old_state: INTEGER

feature --commands
	execute
		deferred
		end
	undo
		deferred
		end
	redo
		deferred
		end

	game_message:STRING
		deferred
		end
	board_message:STRING
		deferred
		end
	state_number:INTEGER
		deferred
		end
	old_state_number:INTEGER
		deferred
		end
	prev_state_number:INTEGER
		deferred
		end
	prev_game_msg:STRING
		deferred
		end
	prev_board_msg:STRING
		deferred
		end
end
