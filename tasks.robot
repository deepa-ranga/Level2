*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Excel.Files
Library     RPA.HTTP
Library     RPA.PDF
Library     RPA.Tables
Library     RPA.Robocloud.Secrets
Library     RPA.Archive
Library     Dialogs


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Looping CSV file and return as table
    Create Zip file
    Close Application


*** Keywords ***
Open the robot order website
    ${secret}=    RPA.Robocloud.Secrets.Get Secret    credentials
    Log    ${secret}[url]
    Open Available Browser    ${secret}[url]
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Looping CSV file and return as table
    ${Tables}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{Tables}
        Fill the form    ${row}
        Save as pdf    ${row}
        Collect the screenshot    ${row}
        Attach robot screenshot to the receipt PDF file    ${row}
        Order another robot
    END

Fill the form
    [Arguments]    ${row}
    Click Button    Yep
    Select From List By Index    id:head    ${row}[Head]
    Wait And Click Button    id:id-body-${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Keyword Succeeds    3x    1s    Order

Order
    Click Button    id:order
    Wait Until Page Contains Element    id:receipt

Save as pdf
    [Arguments]    ${row}
    ${reciept}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${reciept}    ${OUTPUT_DIR}${/}${row}[Order number].pdf    overwrite=True
    Html To Pdf    ${reciept}    ${OUTPUT_DIR}${/}Robot_Receipts${/}${row}[Order number].pdf    overwrite=True

Collect the screenshot
    [Arguments]    ${row}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${row}[Order number].png

Attach robot screenshot to the receipt PDF file
    [Arguments]    ${row}
    Open Pdf    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}${row}[Order number].png
    ...    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    ${pdfFiles}=    Create List    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    Add Files To Pdf    ${pdfFiles}    ${OUTPUT_DIR}${/}Robotreceipts.pdf    append=True

Order another robot
    Wait And Click Button    id:order-another

Create Zip file
    ${ReceiptsZip}=    Set Variable    ${OUTPUT_DIR}${/}Robot_Receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Robot_Receipts    ${ReceiptsZip}

Close Application
    Close Browser
