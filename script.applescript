-- Get the directory of the script in a way that is compatible across different macOS versions
set scriptFilePath to POSIX path of (path to me as text)
set scriptDirectory to do shell script "dirname " & quoted form of scriptFilePath

-- Use the system to locate an .mp4 file in the directory of the script
set videoFile to do shell script "find " & quoted form of scriptDirectory & " -maxdepth 1 -name '*.mp4' | head -n 1"

-- Check if a video file was found
if videoFile is equal to "" then
    display dialog "No MP4 file found in the script's directory."
else
    tell application "QuickTime Player"
        -- Open and play the video file
        activate -- This ensures QuickTime Player is running
        open POSIX file videoFile
        set theDoc to the first document
        present theDoc
        delay 5 -- Wait for 5 seconds for the video to be ready
        play theDoc
    end tell

    -- Wait for QuickTime Player to start and check if it's running
    tell application "System Events"
        if (exists process "QuickTime Player") then
            tell process "QuickTime Player"
                try
                    -- Attempt to select Loop from the menu, this part is not reliable if UI changes
                    click menu item "Loop" of menu 1 of menu bar item "View" of menu bar 1
                on error
                    display notification "Could not click 'Loop' menu item in QuickTime Player."
                end try
            end tell
        else
            display notification "QuickTime Player is not running."
        end if
    end tell

    -- Close other visible applications except for Finder and QuickTime Player
    tell application "System Events"
        set openApps to name of every application process where visible is true
        repeat with appName in openApps
            if appName is not "Finder" and appName is not "QuickTime Player" then
                tell application appName to quit
            end if
        end repeat
    end tell
end if