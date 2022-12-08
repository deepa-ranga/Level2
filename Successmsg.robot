*** Settings ***
Library     Dialogs
Library     RPA.Browser.Selenium


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Success Dialog


*** Keywords ***
Success Dialog
    ${users} =    Get Selection From User    You want to close the browser    Yes    No
    IF    ${users} == "Yes"    Close Browser
