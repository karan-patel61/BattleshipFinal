note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ETF_CUSTOM_SETUP_INTERFACE
inherit
	ETF_COMMAND
		redefine 
			make 
		end

feature {NONE} -- Initialization

	make(an_etf_cmd_name: STRING; etf_cmd_args: TUPLE; an_etf_cmd_container: ETF_ABSTRACT_UI_INTERFACE)
		do
			Precursor(an_etf_cmd_name,etf_cmd_args,an_etf_cmd_container)
			etf_cmd_routine := agent custom_setup(? , ? , ? , ?)
			etf_cmd_routine.set_operands (etf_cmd_args)
			if
				attached {INTEGER_64} etf_cmd_args[1] as dimension and then attached {INTEGER_64} etf_cmd_args[2] as ships and then attached {INTEGER_64} etf_cmd_args[3] as max_shots and then attached {INTEGER_64} etf_cmd_args[4] as num_bombs
			then
				out := "custom_setup(" + etf_event_argument_out("custom_setup", "dimension", dimension) + "," + etf_event_argument_out("custom_setup", "ships", ships) + "," + etf_event_argument_out("custom_setup", "max_shots", max_shots) + "," + etf_event_argument_out("custom_setup", "num_bombs", num_bombs) + ")"
			else
				etf_cmd_error := True
			end
		end

feature -- command precondition 
	custom_setup_precond(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64): BOOLEAN
		do  
			Result := 
				         is_grid_size(dimension)
					-- (4 <= dimension) and then (dimension <= 12)
				and then is_number_of_ships(ships)
					-- (1 <= ships) and then (ships <= 7)
				and then is_max_shots(max_shots)
					-- (1 <= max_shots) and then (max_shots <= 144)
				and then is_number_of_bombs(num_bombs)
					-- (1 <= num_bombs) and then (num_bombs <= 7)
		ensure then  
			Result = 
				         is_grid_size(dimension)
					-- (4 <= dimension) and then (dimension <= 12)
				and then is_number_of_ships(ships)
					-- (1 <= ships) and then (ships <= 7)
				and then is_max_shots(max_shots)
					-- (1 <= max_shots) and then (max_shots <= 144)
				and then is_number_of_bombs(num_bombs)
					-- (1 <= num_bombs) and then (num_bombs <= 7)
		end 
feature -- command 
	custom_setup(dimension: INTEGER_64 ; ships: INTEGER_64 ; max_shots: INTEGER_64 ; num_bombs: INTEGER_64)
		require 
			custom_setup_precond(dimension, ships, max_shots, num_bombs)
    	deferred
    	end
end
