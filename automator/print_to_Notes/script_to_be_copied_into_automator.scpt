-- This script is designed to be used in Automator to create a new note in the Notes app
-- It takes a PDF file as input, prompts the user for a note title, and creates a
-- new note with the file attached, then deletes the original file.
-- The note will be created in a specified folder within the Notes app.
-- The script also includes a timestamp and the original filename in the note body.
-- The script assumes the Notes app is available and the specified folder exists or will be created.
-- Note: This script is intended to be run in the context of Automator with a file input.

-- Heavily based on the code from: https://github.com/altercation/apple-notes-inbox


property notePrefix : ""
property notesFolder : "Resources"

on run {fileToProcess, parameters}
	try
		set theFile to fileToProcess as text
		tell application "Finder" to set noteName to name of file theFile

		-- Ask the user for a title and tags for the new note
		set noteTitleDialog to display dialog "Note title:" default answer noteName
		set noteTitle to text returned of noteTitleDialog

		set timeStamp to short date string of (current date) as string
		set noteBody to "<body><h1>" & notePrefix & noteTitle & "</h1><br><br><p><b>Filename:</b> <i>" & noteName & "</i></p><br><p><b>Automatically Imported on:</b> <i>" & timeStamp & "</i></p><br></body>"

		tell application "Notes"
			if not (exists folder notesFolder) then
				make new folder with properties {name:notesFolder}
			end if

			set newNote to make note at folder notesFolder with properties {body:noteBody}

			make new attachment at end of attachments of newNote with data (file theFile)
			(*
				Note: the following delete is a workaround because creating the attachment
				apparently creates TWO attachements, the first being a sort of "ghost" attachment
				of the second, real attachment. The ghost attachment shows up as a large empty
				whitespace placeholder the same size as a PDF page in the document and makes the
				result look empty
				*)
			delete first attachment of newNote
			show newNote
		end tell
		-- tell application "Finder" to delete file theFile
	on error errText
		display dialog "Error: " & errText
	end try
	return theFile
end run

