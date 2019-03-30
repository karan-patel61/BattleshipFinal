note
	description: "Summary description for {BOMB_MOVE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BOMB_MOVE
inherit
	MOVE

create
	make

feature{NONE}
	make(a_coord1,a_coord2:COORDINATE;game_msg,board_msg:STRING;old_state_num,state_num:INTEGER)
		do
			create c1.make_from_coordinate (a_coord1)
			create c2.make_from_coordinate (a_coord2)
			create old_game_msg.make_from_string (game_msg)
			create old_board_msg.make_from_string (board_msg)
			state := model.i
			old_state := model.state
		end
feature --attribute
	c1,c2: COORDINATE


feature
	execute
		do
			game.board.bomb (c1.row.item, c1.column.item, c2.row.item, c2.column.item)
		end
	undo
		local
			temp:STRING
		do
			game.board.undo_bomb (c1,c2)
			create temp.make_from_string ("(= state ")
			temp.append_integer (old_state)
			model.new_state(old_state)
			temp.append (") ")
			temp.append (old_game_msg)
		--	if game.board.history.is_second  then
			--	temp.append ("OK -> ")
		--		if game.board.history.item.old_state_number >= 1 then
					--temp.append ("Hit! ")
		--		end
		--		temp.append (game.board.history.item.prev_game_msg)
		--	else
			if game.board.num_of_shots_fired = 0 and game.board.num_of_bombs_fired = 0 then
				temp.append ("Fire Away!")
			else
				temp.append (old_board_msg)
			end

			--temp.append (game.board.history.item.prev_board_msg)


			game.set_message (temp)
			game.board.set_message ("")
		end
	redo
		local
			temp:STRING
		do
			execute
			create temp.make_from_string ("(= state ")
			temp.append_integer (state)
			model.new_state (state)
			temp.append (") ")
			temp.append (old_game_msg)
			game.set_message (temp)
		end

	game_message:STRING
		do
			Result := old_game_msg
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
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.state_number
			end
		end
	prev_game_msg:STRING
		do
			create Result.make_empty
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.game_message
			end
		end
	prev_board_msg:STRING
		do
			create Result.make_empty
			if not game.board.history.is_first then
				game.board.history.back
				Result:= game.board.history.item.board_message
			end
		end

end
