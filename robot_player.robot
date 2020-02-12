*** Settings ***
Documentation     Robot playing Findpairs memory card game.
...    This robot assumes that Findpairs Users contains Sanni.

Library           Collections
Library           SeleniumLibrary
Library           RobotPlayer.py

*** Variables ***
${FINDPAIRS URL}         http://127.0.0.1:8000/findpairs/
${BROWSER}               chrome
${level-ultra}           div.select-level-row > span.spruit-field > span:nth-child(2) > span
${first-game}            div.online > div:nth-child(4) > button
${robotUser}             Sanni

*** Test Cases ***
RobotPlayer
    Open Browser To Findpairs

    &{browserMap}=    Create Dictionary
    Sign In        ${robotUser}    player1    ${browserMap}

    FOR    ${i}    IN RANGE    2
        Reset Robot Player
        Sleep          3s    Let browser render the page
        Wait Until Element Contains            css:body > div > span > div > span > div.online > div:nth-child(4)    ???    10min    # waits a game to appear
        Join Game      ${first-game}
        Sleep          3s
        Wait Until Element Does Not Contain    css:div.board    Waiting for the game to start    10min                               # waits until other players have joined to the game
        Do Turns
        Click Element    css:body > div > span > div > span > button    # Replay
    END

*** Keywords ***
Open Browser To Findpairs
    Open Browser    ${FINDPAIRS URL}    ${BROWSER}    alias=player1

Sign In
    [Arguments]    ${user}    ${browser}    ${browserMap}

    Sleep                 3s
    Switch Browser        ${browser}
    Location Should Be    ${FINDPAIRS URL}
    Input Text            css:input.name    ${user}
    Click Element         css:i.fa.fa-sign-in
    Set To Dictionary     ${browserMap}    ${user}=${browser}

Join Game
    [Arguments]    ${game}
    Click Element    css:${game}

Get Faceup Cards
    @{cards faceup} =    Execute JavaScript
                         ...    let cards = [];
                         ...    document.querySelectorAll("div.board span.card > label > i").forEach((elem, i) => {
                         ...        let labelElem = elem.parentElement;
                         ...        if (labelElem.className === "") cards.push({classes:elem.className, position:i});
                         ...    });
                         ...    cards = cards.sort((a, b) => a.classes.localeCompare(b.classes));
                         ...    return cards;
    [Return]    ${cards faceup}

Turn One Card

    @{cards facedown} =    Execute JavaScript
                           ...    let cards = [];
                           ...    document.querySelectorAll("div.board span.card > label > i").forEach((elem, i) => {
                           ...        let labelElem = elem.parentElement;
                           ...        if (labelElem.className === "facedown") cards.push({classes:elem.className, position:i});
                           ...    });
                           ...    cards = cards.sort((a, b) => a.classes.localeCompare(b.classes));
                           ...    console.log("Turn One Card", cards);
                           ...    return cards;

    @{cards faceup} =   Get Faceup Cards
    ${card ind} =       Get Card To Turn    ${cards facedown}    ${cards faceup}
    ${base}=            Convert To Integer    3
    ${nthchild}=        Evaluate    ${base} + ${cards facedown}[${card ind}][position]
    ${nthchild}=        Convert To String    ${nthchild}
    ${cardSelector}=    Set Variable    div.board > span > span:nth-child(${nthchild})

    Add Card            ${cards_facedown}[${card ind}]

    Click Element       css:${cardSelector}
    Sleep               0.5s      

    @{cards faceup} =    Get Faceup Cards
    ${faceup len} =      Get Length    ${cards faceup}
    ${sleep len} =       Calculate Waittime    ${faceup len}
    Sleep                ${sleep len}

Is Gameover
    ${gameover} =    Execute JavaScript
                     ...    let gameover = document.querySelector('.screen-entity-gameover');
                     ...    if (gameover !== null) return true;
                     ...    return false;
    [Return]         ${gameover}

Get Player In Turn
    ${player in turn} =    Execute JavaScript
                           ...    let player = document.querySelector('div.board div.header span.turn.active');
                           ...    if (player !== null) return player.innerText;
                           ...    return '';
    [Return]               ${player in turn}

Inspect Other Turns

    Log To Console    inspecting other turn...

    @{cards faceup} =    Create List
    FOR    ${i}    IN RANGE    999
        Sleep                0.1s

        ${gameover} =        Is Gameover
        Exit For Loop If     ${gameover} == True

        ${playerInTurn} =    Get Player In Turn
        Exit For Loop If     '${playerInTurn}' == '${robotUser}'
        Exit For Loop If     '${playerInTurn}' == ''

        @{cards faceup} =    Get Faceup Cards
        ${faceup len} =      Get Length    ${cards faceup}
        Exit For Loop If     ${faceup len} == 2
    END
    Add Cards            ${cards faceup}

Do Turns

    FOR    ${i}    IN RANGE    999
        Sleep    0.1s

        ${gameover} =        Is Gameover
        Exit For Loop If     ${gameover} == True

        ${playerInTurn} =    Get Player In Turn
        Log To Console       ${playerInTurn}

        Run Keyword If       '${playerInTurn}' != '${robotUser}'    
        ...             Inspect Other Turns    # Another player
        ...         ELSE    
        ...             Turn One Card          # This robot
        Print Cards
    END
