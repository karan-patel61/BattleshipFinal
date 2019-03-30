note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			s.make_from_string ("OK -> Start a new game")
			i := 0
			state := 1
			create g.make (True,4,2,4,2)
			undo_used := False
			redo_used := False
		end

feature -- model attributes
	s : STRING
	i,state: INTEGER
	g: GAME
	undo_used, redo_used: BOOLEAN

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
			set_s("")
		end
	new_state(state_number:INTEGER)
		do
			state := state_number
		end
	reset
			-- Reset model state.
		do
			make
		end
	new_game(board_mode:BOOLEAN;board_size,num_of_ships,num_of_shots,num_of_bombs:INTEGER_32)
		do
			undo_used := False
			redo_used := False
			g.new_game (board_mode, board_size, num_of_ships, num_of_shots, num_of_bombs,state,i)

		end
	debug_game(board_mode:BOOLEAN;board_size,num_of_ships,num_of_shots,num_of_bombs:INTEGER_32)
		do
			undo_used := False
			redo_used := False
			g.debug_game (board_mode, board_size, num_of_ships, num_of_shots, num_of_bombs,state,i)
		end

	fire(a_row,a_col:INTEGER)

		do
			undo_used := False
			redo_used := False
			g.fire (a_row, a_col,state,i)
		end
	bomb(a_row1,a_column1,a_row2,a_column2:INTEGER)
		do
			undo_used := False
			redo_used := False
			g.bomb (a_row1, a_column1, a_row2, a_column2, state,i)
		end

	undo
		do
			g.undo
			undo_used := True
			redo_used := False
		end

	redo
		do
			g.redo
			undo_used := False
			redo_used := True
		end

	give_up
		do
			g.give_up

		end

feature -- helper features
	set_state
		do
			state := i
		end

	set_s(new_text:STRING)
		do
			s.make_from_string (new_text)
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append ("state ")
			Result.append (i.out)
			Result.append (" "+s)
			if i> 0 then
				Result.append (g.message)
				Result.append (g.board_message)
			end
			Result.append(g.out)
		end

end




