*** Settings ***
Library         SeleniumLibrary
Library         OperatingSystem
Library         Collections
Library         String
Variables       testdata.py


*** Variables ***
${BUTTON_ACCEPT_ALL_COOKIES}    //button[@id='btn-cookie-allow']
${BUTTON_SETTINGS}              //div[@class='actions pr-cookie-notice-actions']//button[2]
${BUTTON_CONFIRM}               //button[@class='action confirm primary']
${BROWSER}                      Chrome
${HEADLESS}                     True
${CHROME_DRIVER_PATH}           D:/Icube/QA/Otomation/Drivers/chromedriver/chromedriver.exe
${EDGE_DRIVER_PATH}             D:/Icube/QA/Otomation/Drivers/edgedriver/msedgedriver.exe


*** Test Cases ***
Run Cookie Test For All URLs
    Setup
    RunTestForAllUrls
    Close Browser


*** Keywords ***
Setup
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].${BROWSER.lower()}.options.Options()    sys

    IF    '${HEADLESS}' == 'True'
        Call Method    ${options}    add_argument    --headless=new
    END
    IF    '${HEADLESS}' == 'True'
        Call Method    ${options}    add_argument    --no-sandbox
    END
    IF    '${HEADLESS}' == 'True'
        Call Method    ${options}    add_argument    --disable-dev-shm-usage
    END
    IF    '${HEADLESS}' == 'True'
        Call Method    ${options}    add_argument    --disable-gpu
    END
    IF    '${HEADLESS}' == 'True'
        Call Method    ${options}    add_argument    --remote-debugging-port=9222
    END

    ${driver_path}=    Set Variable If    '${BROWSER}' == 'chrome'    ${CHROME_DRIVER_PATH}    ${EDGE_DRIVER_PATH}
    Open Browser    about:blank    ${BROWSER}    executable_path=${driver_path}    options=${options}
    Maximize Browser Window
    Set Selenium Speed    0.3

AcceptCookies
    Wait Until Element Is Enabled    ${BUTTON_ACCEPT_ALL_COOKIES}    timeout=60s
    Click Element    ${BUTTON_ACCEPT_ALL_COOKIES}
    Wait Until Element Is Not Visible    ${BUTTON_ACCEPT_ALL_COOKIES}    timeout=60s

AcceptSettings
    Wait Until Element Is Enabled    ${BUTTON_SETTINGS}    timeout=60s
    Click Element    ${BUTTON_SETTINGS}
    Wait Until Element Is Not Visible    ${BUTTON_SETTINGS}    timeout=60s
    Wait Until Element Is Enabled    ${BUTTON_CONFIRM}    timeout=60s
    Click Element    ${BUTTON_CONFIRM}
    Wait Until Element Is Not Visible    ${BUTTON_CONFIRM}    timeout=60s

MyAccountAction
    Wait Until Element Is Visible
    ...    //ul[@class='header links']//li[contains(@class,'authorization-link')]/a
    ...    timeout=30s
    Click Element    //ul[@class='header links']//li[contains(@class,'authorization-link')]/a
    Wait Until Element Is Visible    //input[@id='ajaxlogin-email']    timeout=30s

GoToUrlAndDoAction
    [Arguments]    ${url}    ${acceptKeyword}
    Delete All Cookies
    Go To    ${url}
    Run Keyword    ${acceptKeyword}
    MyAccountAction
    Delete All Cookies

RunScenarioAcceptCookies
    [Arguments]    ${url}
    GoToUrlAndDoAction    ${url}    AcceptCookies

RunScenarioAcceptSettings
    [Arguments]    ${url}
    GoToUrlAndDoAction    ${url}    AcceptSettings

RunTestForAllUrls
    ${success_log}=    Set Variable    success${BROWSER}.log
    ${fail_log}=    Set Variable    fail${BROWSER}.log
    Create File    ${success_log}
    Create File    ${fail_log}

    ${SUCCESS_URLS}=    Create List
    ${FAILED_URLS}=    Create List
    Set Suite Variable    ${SUCCESS_URLS}
    Set Suite Variable    ${FAILED_URLS}

    FOR    ${url}    IN    @{test_urls}
        Log    Running AcceptCookies on ${url}
        ${status1}    ${msg1}=    Run Keyword And Ignore Error    RunScenarioAcceptCookies    ${url}
        IF    '${status1}' == 'PASS'
            Append To List    ${SUCCESS_URLS}    ${url} (AcceptCookies)
            Append To File    ${success_log}    ${url}\n
        ELSE
            Append To List    ${FAILED_URLS}    ${url} (AcceptCookies)
            Append To File    ${fail_log}    ${url}\n
        END
    END
