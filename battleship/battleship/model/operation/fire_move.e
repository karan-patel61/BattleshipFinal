note
	description: "Summary description for {FIRE_MOVE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FIRE_MOVE

inherit
	MOVE

create
	make

feature{NONE}
	make(a_coord:COORDINATE; game_msg,board_msg:STRING;old_state_num,state_num:INTEGER)
		do
			create coordinate.make_from_coordinate (a_coord)
			create old_game_msg.make_from_string (game_msg)
			create old_board_msg.make_from_string (board_msg)
			state := model.i
			old_state := model.state
		end
feature --attribute
	coordinate: COORDINATE

feature
	execute
		do
			game.board.fire (coordinate.row.item,coordinate.column.item)
		end
	undo
		local
			temp:STRING
		do
			game.board.undo_fire (coordinate)
			create temp.make_from_string ("(= state ")
			temp.append_integer (old_state)
			model.new_state(old_state)
			temp.append (") ")
			if game.board.history.is_second then
				temp.append ("OK -> ")

			else
				temp.append (old_game_msg)
			end

			temp.append (old_board_msg)


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
