-- Get the directory of the script
tell application "Finder"
    set scriptFilePath to POSIX path of (container of (path to me) as alias)
end tell

-- Use the system to locate an .mp4 file in the directory of the script
set videoFile to do shell script "find " & quoted form of scriptFilePath & " -maxdepth 1 -name '*.mp4' | head -n 1"

-- Check if a video file was found
if videoFile is equal to "" then
    display dialog "No MP4 file found in the script's directory."
else
    tell application "QuickTime Player"
    -- Open and play the video file
    open POSIX file videoFile
    set theDoc to the first document
    present theDoc
    delay 5 -- Wait for 5 seconds for the video to be ready
    play theDoc

    -- Attempt to select Loop from the menu, this part is not reliable if UI changes
    tell application "System Events"
            tell process "QuickTime Player"
                click menu item "Loop" of menu 1 of menu bar item "View" of menu bar 1
            end tell
    end tell

    tell application "System Events"
    set openApps to name of every application process where visible is true
        repeat with appName in openApps
            if appName is not "Finder" and appName is not "QuickTime Player" then
                tell application appName to quit
            end if
        end repeat
    end tell
end tell
end if
