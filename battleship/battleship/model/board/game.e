note
	description: "Summary description for {GAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GAME
inherit
	ANY
		redefine
			out
		end
create
	make

feature
	make(game_mode:BOOLEAN;board_size,max_ships,max_shots,max_bombs:INTEGER)
		do
			create message.make_from_string ("")
			create board.make (game_mode,board_size,max_ships,max_shots,max_bombs)
			num_of_games := 0
			num_of_debug_games := 0
			num_of_games := 0
			total_score := 0
			old_total_score := 0
			total_out_of := 0
			old_total_out_of := 0
			in_game := False
			undo_used := False
			redo_used := False
			give_up_used := False
		end

feature -- attributes
	board:BOARD
	num_of_games,num_of_debug_games, total_score,old_total_score, total_out_of,old_total_out_of: INTEGER
	message: STRING
	in_game, undo_used, redo_used,give_up_used: BOOLEAN
	num_undo_used, num_redo_used :INTEGER
feature -- new game / custom game
	new_game(board_mode:BOOLEAN;board_size,num_of_ships,num_of_shots,num_of_bombs,old_state_num,state_num:INTEGER_32)
		local
			op: NEW_GAME_MOVE
			temp: STRING
		do
			if in_game then
				if board.num_of_bombs_fired  > 0 or board.num_of_shots_fired > 0 then
					create temp.make_from_string ("Keep Firing!")
				else
					create temp.make_from_string ("Fire Away!")
				end
				create op.make (board.history.item.prev_game_msg, board.e, "Game already started -> ", temp, old_state_num,state_num)
				board.history.extend_history (op)
				set_message ("Game already started -> ")
				if board.num_of_bombs_fired  > 0 or board.num_of_shots_fired > 0 then
					board.set_message ("Keep Firing!")
				end

			elseif num_of_ships < (board_size // 3) then
				set_message ("Not enough ships -> ")
				board.set_message ("Start a new game")
			elseif num_of_ships > ((board_size // 2)+1) then
				set_message ("Too many ships -> ")
				board.set_message ("Start a new game")
			elseif num_of_shots < ((num_of_ships * (num_of_ships+1))//2) then
				set_message ("Not enough shots -> ")
				board.set_message ("Start a new game")
			elseif num_of_shots > (board_size^2) then
				set_message ("Too many shots -> ")
				board.set_message ("Start a new game")
			elseif num_of_bombs < (board_size // 3) then
				set_message ("Not enough bombs -> ")
				board.set_message ("Start a new game")
			elseif num_of_bombs > ((board_size // 2)+1) then
				set_message ("Too many bombs -> ")
				board.set_message ("Start a new game")
			else

				if num_of_games = 0 then
					 make (board_mode,board_size,num_of_ships,num_of_shots,num_of_bombs)
				else
					set_game (board_mode ,board_size,num_of_ships,num_of_shots,num_of_bombs)
				end
				new_game_started
				set_message("OK -> ")
				board.set_message ("Fire Away!")
				if board.history.count = 0 then
					create op.make ("OK -> ","Fire Away!", "OK -> ","Fire Away!", old_state_num,state_num)
				else
					create op.make (board.history.item.prev_game_msg, board.history.item.prev_board_msg, message, board.e, board.history.item.prev_state_number,state_num)
				end

				board.history.extend_history (op)
				undo_used := False
				redo_used := False
				give_up_used := False
			end
		end


	debug_game(board_mode:BOOLEAN;board_size,num_of_ships,num_of_shots,num_of_bombs,old_state_num,state_num:INTEGER_32)
		local
			op: NEW_GAME_MOVE
			temp: STRING
		do
			if (board.num_of_bombs_fired + board.num_of_shots_fired) = 0 then
					create temp.make_from_string ("Fire Away!")
				else
					create temp.make_from_string ("Keep Firing!")
				end
			if in_game then

				set_message ("Game already started -> ")
				board.set_message (temp)
				if board.num_of_bombs_fired  > 0 or board.num_of_shots_fired > 0 then
					board.set_message ("Keep Firing!")
				end
				create op.make (board.history.item.prev_game_msg, board.history.item.prev_board_msg, message, board.e, board.history.item.prev_state_number,state_num)
				board.history.extend_history (op)
			elseif num_of_ships < (board_size // 3) then
				set_message ("Not enough ships -> ")
				board.set_message ("Start a new game")
			elseif num_of_ships > ((board_size // 2)+1) then
				set_message ("Too many ships -> ")
				board.set_message ("Start a new game")
			elseif num_of_shots < ((num_of_ships * (num_of_ships+1))//2) then
				set_message ("Not enough shots -> ")
				board.set_message ("Start a new game")
			elseif num_of_shots > (board_size^2) then
				set_message ("Too many shots -> ")
				board.set_message ("Start a new game")
			elseif num_of_bombs < (board_size // 3) then
				set_message ("Not enough bombs -> ")
				board.set_message ("Start a new game")
			elseif num_of_bombs > ((board_size // 2)+1) then
				set_message ("Too many bombs -> ")
				board.set_message ("Start a new game")
			else

				if num_of_debug_games = 0 then
					 make (board_mode,board_size,num_of_ships,num_of_shots,num_of_bombs)
				else
					set_game (board_mode ,board_size,num_of_ships,num_of_shots,num_of_bombs)
				end

				debug_game_started
				set_message("OK -> ")
				board.set_message ("Fire Away!")
				if board.history.count = 0 then
					create op.make ("OK -> ","Fire Away!", "OK -> ","Fire Away!", old_state_num,state_num)
				else
					create op.make (board.history.item.prev_game_msg, board.history.item.prev_board_msg, message, board.e, board.history.item.prev_state_number,state_num)
				end

				board.history.extend_history (op)
				undo_used := False
				redo_used := False
				give_up_used := False
			end
		end

feature --fire and bomb

	fire(a_row,a_col,old_state_num,state_num:INTEGER)
		local
			op: FIRE_MOVE
			cord: COORDINATE
			temp: STRING
		do
			if (board.num_of_bombs_fired + board.num_of_shots_fired) = 0 then
					create temp.make_from_string ("Fire Away!")
				else
					create temp.make_from_string ("Keep Firing!")
				end
			if not in_game then
				set_message("Game not started -> ")
				board.set_message ("Start a new game")
			elseif board.num_of_shots = board.num_of_shots_fired then
				set_message("No shots remaining -> ")

				board.set_message ("Keep Firing!")
			elseif not(a_row >=1 and a_row <= board.b_size and a_col >=1 and a_col <= board.b_size) then
				set_message("Invalid coordinate -> ")
				board.set_message (temp)

			elseif board.cord_on_board_hit (a_row,a_col) then
				set_message("Already fired there -> ")
				board.set_message ("Keep Firing!")
			else
				set_message("OK -> ")
				board.set_message (temp)
				create cord.make (a_row, a_col)
				create op.make (cord,board.history.item.prev_game_msg,board.history.item.prev_board_msg,old_state_num,state_num)

				board.history.extend_history (op)
				op.execute
				undo_used := False
				redo_used := False
				give_up_used := False
				if board.valid_hit then
					old_total_score := total_score
					set_total_score(board.size1 + board.size2)
				end

				if board.game_over then
					in_game := not board.game_over
				end
			end
		end

	bomb(a_row1,a_column1,a_row2,a_column2,old_state_num,state_num:INTEGER)
		local
			op: BOMB_MOVE
			cord1,cord2: COORDINATE
			temp_row, temp_col: INTEGER
			temp: STRING
		do
			create cord1.make (a_row1, a_column1)
			create cord2.make (a_row2, a_column2)
			if (board.num_of_bombs_fired + board.num_of_shots_fired) = 0 then
					create temp.make_from_string ("Fire Away!")
			else
					create temp.make_from_string ("Keep Firing!")
			end
			temp_row := a_row2 - a_row1
			temp_col := a_column1 - a_column2
			if not in_game then
				set_message("Game not started -> ")
				board.set_message ("Start a new game")
			elseif board.num_of_bombs_fired = board.num_of_bombs then
				set_message("No bombs remaining -> ")
				board.set_message ("Keep Firing!")
			elseif (temp_row.abs > 1 and a_column1 = a_column2) or (temp_col.abs > 1 and a_row1 = a_row2) or
					(a_row1 = a_row2 and a_column1 = a_column2) or (temp_row.abs >1 and temp_col.abs > 1)then
				set_message("Bomb coordinates must be adjacent -> ")
				board.set_message(temp)
				create op.make (cord1,cord2,board.history.item.prev_game_msg,board.history.item.prev_board_msg, old_state_num, state_num)
				board.history.extend_history (op)
			elseif  not((a_row1 >=1 and a_row1 <= board.b_size and a_column1 >=1 and a_column1 <= board.b_size) and
						(a_row2 >=1 and a_row2 <= board.b_size and a_column2 >=1 and a_column2 <= board.b_size))  then
				set_message("Invalid coordinate -> ")
				board.set_message (temp)
			elseif board.cord_on_board_hit(a_row1,a_column1) or board.cord_on_board_hit(a_row2,a_column2) then
				set_message("Already fired there -> ")
				board.set_message (temp)
			else
				set_message("OK -> ")
				--board.set_message (temp)

				create op.make (cord1,cord2,message,board.e,old_state_num,state_num)

				board.history.extend_history (op)
				op.execute
				undo_used := False
				redo_used := False
				give_up_used := False
				if board.hit_2_ships or board.valid_hit then
					set_total_score(board.size1 + board.size2)
				end

				if board.game_over then
					in_game := not board.game_over

				end

			end
		end

feature -- UNDO
	undo
		do
			if board.history.after then
				board.history.back
			end
			if not in_game then
				set_message("Nothing to undo -> ")
				board.set_message ("Start a new game")
			elseif in_game and board.history.count = 0 then
				set_message("Nothing to undo -> ")
				board.set_message ("Fire Away!")
			elseif in_game and board.history.count = 1 then
				set_message("Nothing to undo -> ")
				board.set_message ("Fire Away!")
			elseif in_game and board.history.count > 1 then
				if board.history.is_first then
					set_message("Nothing to undo -> ")
					board.set_message ("Fire Away!")
				else

					if board.history.on_item then

						--set_message("")
						--board.set_message ("")

						board.history.item.undo
						if total_score >0 then
							total_score := total_score - (board.size1 + board.size2)
						end
						undo_used := True
						redo_used := False
						if not board.history.is_first then
							board.history.back
						end

					else
						set_message("Nothing to undo -> ")
						board.set_message ("Keep Firing!")
					end--end of on_item IF
				end -- End of history.before IF

			end-- end of Outer IF


		end

	redo
		do

			if not in_game then
				set_message("Nothing to redo -> ")
				board.set_message ("Start a new game")
			elseif in_game and board.history.count = 0 then
				set_message("Nothing to redo -> ")
				board.set_message ("Fire Away!")
			elseif in_game and board.history.count = 1 then
				set_message("Nothing to redo -> ")
				board.set_message ("Fire Away!")

			elseif in_game and board.history.count > 1 then
				if board.history.is_last and (board.num_of_bombs_fired + board.num_of_shots_fired) =0 then
					set_message("Nothing to redo -> ")
					board.set_message ("Fire Away!")
				elseif board.history.is_last and (board.num_of_bombs_fired + board.num_of_shots_fired) >0 then
					set_message("Nothing to redo -> ")
					board.set_message ("Keep Firing!")
				else

					if board.history.on_item then
						set_message("")
						board.set_message ("")
						if not board.history.is_last then
							board.history.forth
						end
						board.history.item.redo

						if total_score >=0  then
							total_score := total_score + (board.size1 + board.size2)
						end
						undo_used := False
						redo_used := True
					else
						set_message("Nothing to redo -> ")
						board.set_message ("Keep Firing!")
					end-- End of on_item IF
				end-- End of history.after IF
			end
		end

feature -- giveup command
	give_up
	do
		if not in_game then
			set_message("Game not started -> ")
			board.set_message ("Start a new game")
		else
			set_message("OK -> ")
			old_total_out_of := board.num_of_coordinates
			board.give_up
			board.history.empty_history

			give_up_used := True
			in_game := False
		end
	end

feature -- helper features

	new_game_started
		do
			in_game := True
			update_total
			update_num_of_games
		end
	debug_game_started
		do
			in_game := True
			update_total
			update_num_of_debug_games
		end

	update_total
	-- updates the total_score and total_out_of
		do
			total_out_of := total_out_of + board.num_of_coordinates
			if give_up_used then
				total_out_of := total_out_of - old_total_out_of
			end
		end

	set_total_score(new_total_score:INTEGER)
		local
			i:INTEGER
		do
			 from
			 	i := 1
			 until
			 	i > new_total_score
			 loop
				update_total_score
				i := i+1
			 end
		end

	update_total_score
		do
			total_score := total_score +1
		end
	update_num_of_games
		do
			num_of_games := num_of_games + 1
			if give_up_used and  num_of_games >= 2 then
				num_of_games := num_of_games - 1
			end

		end

	update_num_of_debug_games
		do
			num_of_debug_games := num_of_debug_games +1
			if give_up_used and num_of_debug_games >= 2 then
				num_of_debug_games := num_of_debug_games - 1
			end

		end

	set_message(txt:STRING)
		do
			message.make_from_string (txt)
		end

	set_game(game_mode:BOOLEAN;board_size,max_ships,max_shots,max_bombs:INTEGER)
		do
			board.set_board (game_mode,board_size,max_ships,max_shots,max_bombs)
		end

	board_message:STRING
		do
			create Result.make_from_string (board.e)
		end

	print_ships: STRING
		do
			create Result.make_empty
			Result.append ("  Ships: ")
			Result.append_integer (board.num_ships_sunk)
			Result.append ("/")
			Result.append_integer (board.ships_on_board.count)
			Result.append ("%N")
			across
				board.ships_on_board as a_ship
			loop
				Result.append ("    ")
				Result.append_integer (a_ship.item.size)
				Result.append ("x1: ")
				-- if debug mode is on then print the ship coordinates
				if board.board_mode then
					across
						a_ship.item.ship_location as ship_loc
					loop
						if ship_loc.cursor_index > 1 then
							Result.append (";")
						end
						Result.append(ship_loc.item.out)
						if  ship_loc.cursor_index = a_ship.item.ship_location.count and
								a_ship.cursor_index /= board.ships_on_board.count then
							Result.append ("%N")
						end
					end

				else
					if board.ship_sunk(a_ship.item) then

						Result.append("Sunk")

					else
						Result.append("Not Sunk")
					end
					if a_ship.cursor_index /= board.ships_on_board.count then
						Result.append("%N")
					end
				end

			end
		end

feature --output

	out:STRING
		do
			create Result.make_empty
			if num_of_games > 0 or num_of_debug_games > 0 then

				Result.append (board.out)
				Result.append ("%N")
				Result.append ("  Current Game")
				if board.board_mode then
					Result.append (" (debug)")
					Result.append (": "+num_of_debug_games.out)
				else
					Result.append (": "+num_of_games.out)
				end

				Result.append (board.print_ammo)
				Result.append ("%N")
				Result.append ("  Score: ")
				Result.append (board.scoreboard)
				Result.append (" (Total: ")
				Result.append_integer (total_score)
				Result.append ("/")
				Result.append_integer (total_out_of)
				Result.append (")")
				Result.append ("%N")
				Result.append (print_ships)
			end -- End of Outer If
		end

invariant
	size_of_board: board.b_size >= 4 and board.b_size <= 12
end
