note
	description: "Summary description for {NEW_GAME_MOVE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_GAME_MOVE

inherit
	MOVE

create
	make

feature{NONE}
	make(g_message, b_message,new_game_m, new_board_m:STRING; old_state_num, current_state_num: INTEGER)
		do
			create old_game_msg.make_from_string(g_message)
			create old_board_msg.make_from_string(b_message)
			create new_game_msg.make_from_string (new_game_m)
			create new_board_msg.make_from_string (new_board_m)
			old_state := model.state
			state := model.i
		end

feature -- Attributes
	new_game_msg,new_board_msg: STRING


feature -- Commands
	execute
		do
			-- leave empty
		end

	undo
		local
			temp:STRING
		do
			create temp.make_from_string ("(= state ")
			temp.append_integer (old_state)
			model.new_state(old_state)
			temp.append (") ")
			if game.board.history.is_second then
				temp.append ("OK -> ")
			else
				temp.append (new_game_msg)
			end


			temp.append (old_board_msg)
			game.set_message (temp)
			game.board.set_message ("")
		end

	redo
		local
			temp:STRING
		do
			create temp.make_from_string ("(= state ")
			temp.append_integer (state)
			model.new_state (state)
			temp.append (") ")
			temp.append (new_game_msg)
			temp.append (new_board_msg)
			game.set_message (temp)
		end
	game_message:STRING
		do
			Result := new_game_msg
		end

	board_message:STRING
		do
			Result := old_board_msg
		end

	state_number:INTEGER
		do
			Result := state
		end

	old_state_number:INTEGER
		do
			Result := old_state
		end

	prev_state_number:INTEGER
		do
			if game.board.history.after then
				game.board.history.back
			end
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.state_number
				game.board.history.forth
			else
				Result := state_number

			end
		end
	prev_game_msg:STRING
		do
			create Result.make_from_string ("")
			if game.board.history.after then
				game.board.history.back
			end
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.game_message
				game.board.history.forth
			end

			if game.board.history.is_first then
				Result := game_message
			end

		end
	prev_board_msg:STRING
		do
			create Result.make_empty
			if game.board.history.after then
				game.board.history.back
			end
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.board_message
				game.board.history.forth
			else
				Result := board_message
			end
		end
end
