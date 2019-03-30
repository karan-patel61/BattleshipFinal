note
	description: "Summary description for {HISTORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HISTORY

create
	make

feature{NONE} -- create
	make
		do
			create {ARRAYED_LIST[MOVE]}history.make (10)
		end

	history: LIST[MOVE]
		-- a history list of user invoked operations
		-- implementation


feature -- queries
	item: MOVE
			-- Cursor points to this user operation
		require
			on_item
		do
			Result := history.item
		end

	on_item: BOOLEAN
			-- cursor points to a valid operation
			-- cursor is not before or after
		do
			Result := not history.before and not history.after
		end


	after: BOOLEAN
			-- Is there no valid cursor position to the right of cursor?
		do
			Result := history.index = history.count + 1
		end

	before: BOOLEAN
			-- Is there no valid cursor position to the left of cursor?
		do
			Result := history.index = 0
		end

	count: INTEGER
		do
			Result := history.count
		end

	is_first:BOOLEAN
		do
			Result := history.isfirst
		end
	is_last:BOOLEAN
		do
			Result := history.islast
		end
	is_second:BOOLEAN
		do
			Result := history.index = 2
		end
	is_empty:BOOLEAN
		do
			Result := history.is_empty
		end
	empty_history
		do
			make
		end

feature -- comands
	extend_history(a_op: MOVE)
			-- remove all operations to the right of the current
			-- cursor in history, then extend with `a_op'
		do
			remove_right
			history.extend(a_op)
			history.finish
		ensure
			history[history.count] = a_op
		end

	remove_right
			--remove all elements
			-- to the right of the current cursor in history
		do
			if not history.islast and not history.after then
				from
					history.forth
				until
					history.after
				loop
					history.remove
				end
			end
		end



	forth
		require
			not after
		do
			history.forth
		end

	back
		require
			not before
		do
			history.back
		end


end
