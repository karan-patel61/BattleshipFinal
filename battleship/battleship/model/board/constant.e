note
	description: "Summary description for {CONSTANT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

expanded class
	CONSTANT
feature{ROW}
	indicies: ARRAY[STRING]
		once
			Result := <<"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L">>
		end

invariant
	indicies_size: indicies.count = 12

end
