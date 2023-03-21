*** Settings ***
Documentation       GPT XPath Guesser
Library    RPA.Browser.Playwright
Library    RPA.FileSystem
Library    RPA.OpenAI
Library    RPA.Robocorp.Vault
Library    RPA.Assistant
Library    RPA.JSON
Library    String

*** Tasks ***
Minimal task
    Display Main Menu
    ${result}=    RPA.Assistant.Run Dialog
    ...    title=Robocorp
    ...    on_top=False
    ...    height=700
    ...    width=600
    ...    timeout=720
    ...    location=Center

*** Variables ***
&{xpath}       Buttons=//button    Inputs=//input    Buttons & Inputs=//input | //button
${correct_answers}    ${0}
${locator_counter}    ${0}

*** Keywords ***
Display Main Menu
    Clear Dialog
    Add Image    ${CURDIR}${/}logo.png   width=40   height=40
    Add Heading    GPT XPath Guesser
    Add Text Input    input_url    Url to search from    
    Add Drop-Down     locators    Buttons,Inputs,Buttons & Inputs    label=Select the locator type
    Add Drop-Down     model    gpt-3.5-turbo,gpt-4    label=Select the GPT model
    Add Text Input    sleep_time     Seconds to wait for user login or other actions.    default=0 
    Add Next Ui Button    Get locators    Window Locator Results
    Add Submit Buttons    buttons=Close    default=Close

Back To Main Menu
    [Arguments]   ${result}
    Display Main Menu
    Refresh Dialog

Window Locator Results
    [Arguments]   ${form}
    Clear Dialog
    Add Heading    Locator Results   size=Medium
    ${locators_count}   Find the Elements    ${form}
    IF    ${locators_count} > ${0}
        ${response}   Create locators    ${form}
        Add Text    ${response}
        ${result}  Validate results
    ELSE
        ${result}  Set Variable    No elements found from the website: ${form}[locators]  
    END
    Add Text    ${result}   size=Large
    Add Next Ui Button    Back    Back To Main Menu
    Refresh Dialog
    Close Browser

Find the Elements
    [Arguments]    ${form}
    Set Browser Timeout    30
    Open Browser    url=${form}[input_url]
    Sleep   ${form}[sleep_time]
    ${elements}   Get Elements    ${xpath}[${form}[locators]]  
    ${locators_found}    Get Element Count    ${xpath}[${form}[locators]]
    IF    ${locators_found} > ${0}
        Create File    output/element_htmls.txt    overwrite=True
        FOR    ${element}    IN    @{elements}
            ${entities}    Get Elements    ${element}
            FOR    ${entity}    IN    @{entities}
                ${html}   Get Property   ${entity}    outerHTML
                Append To File    output/element_htmls.txt    ${html}
            END
            Append To File    output/element_htmls.txt    \n
        END
    END
    [Return]   ${locators_found}

Create locators
    [Arguments]    ${form}
    ${secrets}   Get Secret   OpenAI
    Authorize To Openai    api_key=${secrets}[key]
    ${html}    Read File    output/element_htmls.txt
    Log To Console    \n\n Waiting for OpenAI \n   
    ${response}   @{conversation}    Chat Completion Create
    ...    user_content=Find individual xpath locators for all of the elements in the html data. Use id or name as the strategy only if they contain some common word, otherwise use some other strategy to avoid dynamic id's. Write the results into a json file without any additional comments. Give the locators good names. Html: \n ${html}
    ...    model=${form}[model]
    Create File    output/locators_found.json    ${response}    overwrite=True
    [Return]    ${response}

Validate results
    &{json}   Load JSON from file   output/locators_found.json    
    FOR    ${x}    IN    @{json}
        ${xpath}   Get value from JSON    ${json}    $.[${x}]
        ${elements_found}   Get Element Count    ${xpath}
        IF    ${elements_found} > 0
            ${correct_answers}    Evaluate   ${correct_answers}+1
        END
        ${locator_counter}   Evaluate    ${locator_counter}+1
    END
    ${result}   Set Variable   Locators matched elements on the site: ${correct_answers}/${locator_counter}
    [Return]    ${result}