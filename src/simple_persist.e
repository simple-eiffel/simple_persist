note
	description: "Facade class providing simplified access to persistence operations"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_PERSIST

create
	make

feature {NONE} -- Initialization

	make
		-- Create persistence facade
		do
			create default_path.make_empty
			has_error := False
		end

feature -- Status Queries

	version: STRING = "1.0.0"
		-- Library version

feature -- File Operations

	file_exists (a_path: PATH): BOOLEAN
		-- Does persistence file exist?
		require
			path_attached: a_path /= Void
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_path (a_path)
			Result := l_file.exists
		end

	delete_file (a_path: PATH)
		-- Delete persistence file
		require
			path_attached: a_path /= Void
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_path (a_path)
			if l_file.exists then
				l_file.delete
			end
		end

feature -- Configuration

	set_default_path (a_path: PATH)
		-- Set default storage path
		require
			path_attached: a_path /= Void
		do
			default_path := a_path
		end

	default_path: PATH
		-- Default storage path

feature -- Status

	last_error: detachable READABLE_STRING_GENERAL
		-- Last error message, if any

	has_error: BOOLEAN
		-- Did last operation fail?

	clear_error
		-- Clear error state
		do
			last_error := Void
			has_error := False
		end

feature {NONE} -- Implementation

	set_error (a_message: READABLE_STRING_GENERAL)
		-- Set error state with message
		do
			last_error := a_message
			has_error := True
		end

end
