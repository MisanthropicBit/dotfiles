use framework "Foundation"
use scripting additions

on run
	set arguments to (current application's NSProcessInfo's processInfo's arguments) as list
	
	if (count arguments) < 3 or (count arguments) > 4 then
		tell me to error "Expected between 2 and 3 arguments" number 1
	end if
	
	if (count arguments) is 4 then
		display notification (item 2 of arguments) with title (item 3 of arguments) sound name (item 4 of arguments)
	else
		display notification (item 2 of arguments) with title (item 3 of arguments)
	end if
end run
