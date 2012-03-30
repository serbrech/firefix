

# FireFix script for Firefox on MAC 
## enables PDF's and InDesign to be opended through browser

The script is compatible with ruby 1.8.6 and up which is installed by default on every system running MacOs X 
(Mac os uses ruby 1.8.6 internally)

The scripts will attempt to update firefox settings for all the users on the machine.
Running the script first creates backups of the 2 targeted files prefs.js and mimetypes.js
If the backups files are already present, the script will tell you that and will not execute again. (the fix is already in place)

## IMPORTANT!
1. Firefox needs to be CLOSED before running the script!
2. Remember to open the config.rb file in a texteditor and change/enter the URL to the PagePlanner 3 
3. Run the script as administrator (sudo)

### To run the script
In the terminal : 

Navigate to the folder that contains the script and type the command: 
    sudo ruby firefix.rb

to rollback the backup files: 
    sudo ruby firefix.rb rollback