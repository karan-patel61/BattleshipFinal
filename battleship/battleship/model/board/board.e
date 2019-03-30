note
	description: "Summary description for {BOARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BOARD

inherit
	ANY
		redefine
			out
		end
create
	make

feature -- random generators

	rand_gen: RANDOM_GENERATOR
			-- random generator for normal mode
			-- it's important to keep this as an attribute
		attribute
			create result.make_random
		end

	debug_gen: RANDOM_GENERATOR
			-- deterministic generator for debug mode
			-- it's important to keep this as an attribute
		attribute
			create result.make_debug
		end

feature {NONE} -- Initialization

	make(mode:BOOLEAN;n_size,num_of_ships,number_of_shots,number_of_bombs: INTEGER)
			-- Initialize a n x n board including
			-- the # of shots,bombs and score
		do
			create implementation.make_filled (create {SHIP_ALPHABET}.make ('_'), n_size, n_size)
			game_over := False
			valid_hit := False
			hit_2_ships := False
			give_up_used := False
			board_mode := mode
			create e.make_from_string ("Fire Away!")
			create sunk.make_empty
			--e := "Fire Away!"
			b_size := n_size
			num_of_shots := number_of_shots
			num_of_bombs := number_of_bombs
			num_of_shots_fired := 0
			num_of_bombs_fired := 0
			num_ships_sunk := 0
			score := 0
			old_score := 0
			num_of_coordinates := 0
			size1 := 0
			size2 := 0
			create history.make
			create ships_on_board.make_from_array (generate_ships(mode,n_size,num_of_ships))
			create old_ships.make_from_array(ships_on_board)
			across
				ships_on_board as a_ship
			loop
				across
					a_ship.item.ship_location as ship_loc
					loop
						num_of_coordinates := num_of_coordinates +1
					end
			end
			if mode then
				place_ships(implementation, ships_on_board)
			end

		end



feature -- Attributes
	implementation: ARRAY2[SHIP_ALPHABET]
	b_size, num_of_shots, num_of_bombs, num_ships_sunk, num_of_coordinates,num_of_shots_fired,num_of_bombs_fired, score, old_score: INTEGER
	ships_on_board, old_ships: ARRAY[SHIP]
	game_over, board_mode, valid_hit, hit_2_ships, give_up_used: BOOLEAN
	history: HISTORY
	e,sunk: STRING
	size1,size2:INTEGER

feature -- Commands
	generate_ships(is_debug_mode: BOOLEAN; board_size: INTEGER; num_ships: INTEGER): ARRAY[SHIP]
		-- generate ships randomly
		local
			c,r,size : INTEGER
			d: BOOLEAN
			gen: RANDOM_GENERATOR
			new_ship: SHIP
			coord: COORDINATE
		do
			create Result.make_empty
			if is_debug_mode then
				gen := debug_gen
			else
				gen := rand_gen
			end
			from
				size := num_ships
			until
				size = 0
			loop
				d := (gen.direction \\ 2 = 1)
				if d then
					c := (gen.column \\ board_size) + 1
					r := (gen.row \\ (board_size - size)) + 1
				else
					r := (gen.row \\ board_size) + 1
					c := (gen.column \\ (board_size - size)) + 1
				end
				create coord.make (r.abs, c.abs)
				create new_ship.make (size, coord, d)
				if not collide_with (Result, new_ship) then
					Result.force (new_ship, Result.upper+1)
					size := size - 1
				end
				gen.forth
			end
		end

	place_ships(board: ARRAY2[SHIP_ALPHABET]; new_ships: ARRAY[SHIP])
			-- Place the randomly generated positions of `new_ships' onto the `board'.
			-- Notice that when a ship's row and column are given,
			-- its coordinate starts with (row + 1, col) for a vertical ship,
			-- and starts with (row, col + 1) for a horizontal ship.
		do
			across
				ships_on_board as new_ship
			loop
				across
					new_ship.item.ship_coordinate as ship_coord
				loop
					if new_ship.item.dir then
						board[ship_coord.item.row.item, ship_coord.item.column.item] := create {SHIP_ALPHABET}.make ('v')
					else
						board[ship_coord.item.row.item, ship_coord.item.column.item] := create {SHIP_ALPHABET}.make ('h')
					end
				end
			end -- End of across
		end

		collide_with_each_other(ship1, ship2: SHIP): BOOLEAN
		do
			Result :=
			across
				ship1.ship_coordinate as ship1_coord
			some
				across
					ship2.ship_coordinate as ship2_coord
				some
					 ship1_coord.item.is_equal (ship2_coord.item)
				end
			end
		end

	collide_with(existing_ships:ARRAY[SHIP]; new_ship: SHIP): BOOLEAN
		do
			across
					existing_ships as existing_ship
				loop
					Result := Result or collide_with_each_other (new_ship, existing_ship.item)
				end
			ensure
				Result =
					across existing_ships as existing_ship
					some
						collide_with_each_other (new_ship, existing_ship.item)
					end
		end



	fire(a_row,a_column: INTEGER)
		-- fire at Row and Column
		local
			cord: COORDINATE
			i,j: INTEGER
		do
			hit_2_ships := False
			valid_hit := False
			give_up_used := False
			size1 := 0
			size2 := 0

			--old_ships.make_from_array (ships_on_board)
			old_ships := ships_on_board
			if num_of_shots_fired = num_of_shots then
				set_message("")
			end
				create cord.make (a_row, a_column)
				from
					i := ships_on_board.lower
				until
					i > ships_on_board.upper
				loop
					from
						j := ships_on_board[i].ship_location.lower
					until
						j > ships_on_board[i].ship_location.upper
					loop

						if ships_on_board[i].ship_coordinate[j].is_equal (cord) then
							ships_on_board[i].ship_location[j].hit
							e := "Hit! "

							if ship_sunk(ships_on_board[i]) then

								update_num_ships_sunk
								valid_hit := True

								e.make_from_string ("")
								e.append_integer (ships_on_board[i].size)
								e.append ("x1 ship sunk! ")
								score := score + ships_on_board[i].size
								size1 := ships_on_board[i].size
							end
							-- mark X on the board
							implementation[a_row, a_column] := create {SHIP_ALPHABET}.make ('X')
							num_of_shots_fired := num_of_shots_fired +1

							-- set the counter to their max value in order to break out of the 2 loops
							j := ships_on_board.upper
							i := ships_on_board.upper
						else
							if i = ships_on_board.upper and j = ships_on_board[i].ship_coordinate.upper then
								valid_hit := False
								implementation[a_row, a_column] := create {SHIP_ALPHABET}.make ('O')
								num_of_shots_fired := num_of_shots_fired +1
								e := "Miss! "
							end

						end-- end of if

						j := j+1
					end -- END OF J LOOP

					i := i+1
				end-- END OF I LOOP
			-- check for winner and print message
			check_winner
		end--END of FIRE

	bomb(a_row1, a_column1, a_row2, a_column2: INTEGER)
		local
			cord1,cord2: COORDINATE
			i,j,temp_row, temp_col, num_sunk: INTEGER
			hit_one: BOOLEAN
		do
			hit_2_ships := False
			valid_hit := False
			hit_one := False
			size1 := 0
			size2 := 0

			temp_row := a_row2 - a_row1
			temp_col := a_column1 - a_column2

				create cord1.make (a_row1, a_column1)
				create cord2.make (a_row2, a_column2)
				num_sunk := 0

				from
					i := ships_on_board.lower
				until
					i > ships_on_board.upper
				loop
					from
						j := ships_on_board[i].ship_location.lower
					until
						j > ships_on_board[i].ship_location.upper
					loop

						if ships_on_board[i].ship_coordinate[j].is_equal (cord1) then
							ships_on_board[i].ship_location[j].hit
							hit_one := True
							e := "Hit! "

							if ship_sunk(ships_on_board[i]) then
								update_num_ships_sunk
								num_sunk := num_sunk +1
								valid_hit := True
								e.make_from_string ("")
								e.append_integer (ships_on_board[i].size)
								e.append ("x1 ")
								score := score + ships_on_board[i].size
								size1 := ships_on_board[i].size
							end-- printing if ship(s) are sunk
							-- mark X on the board
							implementation[a_row1, a_column1] := create {SHIP_ALPHABET}.make ('X')
							-- set the counter to their max value in order to break out of the 2 loops
							j := ships_on_board.upper
							i := ships_on_board.upper
						else
							if i = ships_on_board.upper and j = ships_on_board[i].ship_coordinate.upper then
								valid_hit := False
								hit_one := False
								implementation[a_row1, a_column1] := create {SHIP_ALPHABET}.make ('O')
							end
						end-- end of if
						j := j+1
					end -- END OF J LOOP

					i := i+1
				end-- END OF I LOOP

				-- the second loop fires at second coordinate
				from
					i := ships_on_board.lower
				until
					i > ships_on_board.upper
				loop
					from
						j := ships_on_board[i].ship_location.lower
					until
						j > ships_on_board[i].ship_location.upper
					loop

						if ships_on_board[i].ship_coordinate[j].is_equal (cord2) then
							ships_on_board[i].ship_location[j].hit
							hit_one :=True
							if ship_sunk(ships_on_board[i]) then
								update_num_ships_sunk
								num_sunk := num_sunk +1
								if num_sunk =2 then
									valid_hit := False
									hit_2_ships := True
									e.append ("and ")
									e.append_integer (ships_on_board[i].size)
									e.append ("x1 ships sunk! ")
									score := score + ships_on_board[i].size
									size2 := ships_on_board[i].size
								elseif num_sunk =1  then
									valid_hit := True
									e.make_from_string("")
									e.append_integer (ships_on_board[i].size)
									e.append ("x1 ship sunk! ")
									score := score + ships_on_board[i].size
									size1 := ships_on_board[i].size

								end
							else
								e := "Hit! "
							end-- printing if ship(s) are sunk

							-- mark X on the board
							implementation[a_row2, a_column2] := create {SHIP_ALPHABET}.make ('X')

							num_of_bombs_fired := num_of_bombs_fired +1
							-- set the counter to their max value in order to break out of the 2 loops
							j := ships_on_board.upper
							i := ships_on_board.upper
						else
							if i = ships_on_board.upper and j = ships_on_board[i].ship_coordinate.upper then

								implementation[a_row2, a_column2] := create {SHIP_ALPHABET}.make ('O')
								num_of_bombs_fired := num_of_bombs_fired +1
								if num_sunk = 1 then
									e.append ("ship sunk! ")
								elseif hit_one then
									hit_one := False
									e := "Hit! "
								elseif num_sunk = 0 then
									e := "Miss! "
								end

							end
						end-- end of if
						j := j+1
					end -- END OF SECOND J LOOP

					i := i+1
				end-- END OF SECOND I LOOP
			check_winner
		end-- END of BOMB


	check_winner
		do
			-- check for winner and print message
			if num_ships_sunk = ships_on_board.count then
				e.append ("You Win!")
				game_over := True
			elseif num_of_shots_fired = num_of_shots and num_of_bombs_fired = num_of_bombs then
				e.append ("Game Over!")
				game_over := True
			else
				e.append ("Keep Firing!")
			end
		end


	set_board(a_mode:BOOLEAN;n_size,num_of_ships,number_of_shots,number_of_bombs: INTEGER)
		do
			make(a_mode,n_size,num_of_ships,number_of_shots,number_of_bombs)
		end

feature--Query
	cord_on_board_hit(a_r,a_c:INTEGER):BOOLEAN
		local
			x,o: SHIP_ALPHABET
		do
			create x.make ('X')
			create o.make ('O')
			Result := implementation[a_r, a_c].is_equal (x) or
						implementation[a_r, a_c].is_equal (o)
		end

	ship_sunk(ship: SHIP):BOOLEAN
		local
			x: SHIP_ALPHABET
		do
			create x.make ('X')
			Result := True
			across
				ship.ship_location as ship_loc
			loop
				Result := Result and ship_loc.item.status.is_equal (x)
			end

		end

feature --giveup

	give_up
		do
			game_over := True
			set_message("You gave up!")
		end


feature	-- helper methods

	update_num_ships_sunk
		do
			num_ships_sunk := 0

			across
				ships_on_board as a_ship
			loop
				if ship_sunk(a_ship.item) then
					num_ships_sunk := num_ships_sunk +1
				end
			end

		end

	set_ships(new_ships:ARRAY[SHIP])
		do
			ships_on_board.make_from_array (new_ships)
		end

	restore_ship_on_coordinate(a_coordinate:COORDINATE)
		local
			i: INTEGER
		do
			size1 := 0
			size2 := 0
			from
				i := ships_on_board.lower
			until
				i > ships_on_board.upper
			loop

				across
					ships_on_board[i].ship_location as ship_loc
				loop
					if ship_loc.item.coordinate.is_equal (a_coordinate) then
						--first check if ship[i] has sunk
						if ship_sunk(ships_on_board[i]) then
							--valid_hit := True
							size1 := ships_on_board[i].size
							size2 := 0
						else
							--valid_hit := False
						end
						ships_on_board[i].ship_location[ship_loc.cursor_index].restore (ships_on_board[i].dir)
						if board_mode then
							-- if debug moe is true print the ship
							if ships_on_board[i].dir then
								implementation[a_coordinate.row.item,a_coordinate.column.item] := create {SHIP_ALPHABET}.make ('v')
							else
								implementation[a_coordinate.row.item,a_coordinate.column.item] := create {SHIP_ALPHABET}.make ('h')
							end
						end
						update_num_ships_sunk
						i := ships_on_board.upper
					else
						--valid_hit := False
					end
				end
				i := i+1
			end
		end

	restore_bomb_coordinates(c1,c2:COORDINATE)
		local
			i,j,num_sunk: INTEGER
		do
			-- this loop is to restore C1
			--num_sunk := 0
			size1 := 0
			size2 := 0
			from
				i := ships_on_board.lower
			until
				i > ships_on_board.upper
			loop

				across
					ships_on_board[i].ship_location as ship_loc
				loop
					if ship_loc.item.coordinate.is_equal (c1) then
						--first check if ship[i] has sunk
						if ship_sunk(ships_on_board[i]) then
							--valid_hit := True
							size1 := ships_on_board[i].size
							size2 := 0
							num_sunk := 1
						else
							--valid_hit := False
						end
						ships_on_board[i].ship_location[ship_loc.cursor_index].restore (ships_on_board[i].dir)
						if board_mode then
							-- if debug moe is true print the ship
							if ships_on_board[i].dir then
								implementation[c1.row.item,c1.column.item] := create {SHIP_ALPHABET}.make ('v')
							else
								implementation[c1.row.item,c1.column.item] := create {SHIP_ALPHABET}.make ('h')
							end
						end

						update_num_ships_sunk
						i := ships_on_board.upper
					else
						---valid_hit := False
					end-- End of IF
				end-- end of inner ACROSS loop
				i := i+1
			end-- end of outer FROM loop

			--the second FROM loop is to restore C2
			from
				j := ships_on_board.lower
			until
				j > ships_on_board.upper
			loop

				across
					ships_on_board[j].ship_location as ship_loc
				loop
					if ship_loc.item.coordinate.is_equal (c2) then
						--first check if ship[j] has sunk
						if ship_sunk(ships_on_board[j]) and num_sunk = 1 then
						--	valid_hit := False
						--	hit_2_ships := True
							size2 := ships_on_board[j].size
						elseif ship_sunk(ships_on_board[j]) and num_sunk = 0 then
						--	valid_hit := True
						--	hit_2_ships := False
							size1 := ships_on_board[j].size
							size2 := 0
						else
						--	valid_hit := False
						end
						ships_on_board[j].ship_location[ship_loc.cursor_index].restore (ships_on_board[j].dir)
						if board_mode then
							-- if debug moe is true print the ship
							if ships_on_board[j].dir then
								implementation[c2.row.item,c2.column.item] := create {SHIP_ALPHABET}.make ('v')
							else
								implementation[c2.row.item,c2.column.item] := create {SHIP_ALPHABET}.make ('h')
							end
						end

						update_num_ships_sunk
						j := ships_on_board.upper
					else
					--	valid_hit := False
					--	hit_2_ships := False
					end-- End of IF
				end-- end of inner ACROSS loop
				j := j+1
			end-- end of second(C2) outer FROM loop
		end

	undo_fire(a_coordinate:COORDINATE)
		do
			if num_of_shots_fired > 0 then
				num_of_shots_fired := num_of_shots_fired -1
			end

			erase_cord(a_coordinate)
			restore_ship_on_coordinate(a_coordinate)
			if num_of_bombs_fired = 0 and num_of_shots_fired = 0 then
				--set_message("Fire Away!")
			end
		end
	undo_bomb(c1,c2:COORDINATE)
		do

				num_of_bombs_fired := num_of_bombs_fired -1


			erase_cord(c1)
			erase_cord(c2)
			restore_bomb_coordinates(c1,c2)
		end
	erase_cord(a_coordinate:COORDINATE)
		do
			implementation[a_coordinate.row.item, a_coordinate.column.item] := create {SHIP_ALPHABET}.make ('_')
		end

	set_message(new_message:STRING)
		do
			e.make_from_string (new_message)
		end

feature -- printing methods

	scoreboard:STRING
	--prints the score
		local
			num,total: INTEGER
		do
			num := 0
			total := 0
			across
				ships_on_board as a_ship
			loop
				if ship_sunk(a_ship.item) then
					num := num + a_ship.item.size
				end
			end
			--old_score := score
			if  old_score /= score then
				old_score := score
			end

			score := num
			if (score - old_score) >= 1  then
				old_score := score - old_score
			end

			--num_of_coordinates := total
			create Result.make_empty
			Result.append_integer (score)
			Result.append ("/")
			Result.append_integer (num_of_coordinates)
		end

	print_ships: STRING
		do
			create Result.make_empty
			Result.append ("  Ships: ")
			Result.append_integer (num_ships_sunk)
			Result.append ("/")
			Result.append_integer (ships_on_board.count)
			Result.append ("%N")
			across
				ships_on_board as a_ship
			loop
				Result.append ("    ")
				Result.append_integer (a_ship.item.size)
				Result.append ("x1: ")
				-- if debug mode is on then print the ship coordinates
				if board_mode then
					across
						a_ship.item.ship_location as ship_loc
					loop
						if ship_loc.cursor_index > 1 then
							Result.append (";")
						end
						Result.append(ship_loc.item.out)
						if  ship_loc.cursor_index = a_ship.item.ship_location.count and
								a_ship.cursor_index /= ships_on_board.count then
							Result.append ("%N")
						end
					end

				else
					if ship_sunk(a_ship.item) then

						Result.append("Sunk")

					else
						Result.append("Not Sunk")
					end
					if a_ship.cursor_index /= ships_on_board.count then
						Result.append("%N")
					end
				end

			end
		end

	print_ammo: STRING
		do
			create Result.make_empty
			Result.append ("%N")
			Result.append ("  Shots: ")
			Result.append_integer (num_of_shots_fired)
			Result.append ("/")
			Result.append_integer (num_of_shots)
			Result.append ("%N")
			Result.append ("  Bombs: ")
			Result.append_integer (num_of_bombs_fired)
			Result.append ("/")
			Result.append_integer (num_of_bombs)

		end


feature -- Output
	out:STRING
		local
			fi: FORMAT_INTEGER
			temp: ROW
		do
			create fi.make (2)
			create Result.make_from_string ("")
			Result.append ("%N")
			Result.append ("   ")
			across 1 |..| implementation.width as i loop Result.append(" " + fi.formatted (i.item)) end
			across 1 |..| implementation.width as i loop
				create temp.make (i.item)
				Result.append("%N  "+ temp.out+ "")
				across 1 |..| implementation.height as j loop
					Result.append ("  " + implementation[i.item,j.item].out)
				end-- End of Inner Across
			end-- End of Outer Across

		end


invariant
	invariant_clause: True -- Your invariant here

end
