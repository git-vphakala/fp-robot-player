*** Settings ***
Documentation     Robot playing Findpairs memory card game.
...    This robot assumes that Findpairs Users contains Sanni.

Library           Collections
Library           SeleniumLibrary

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
        Sleep          3s    Let browser render the page
        Wait Until Element Contains    css:body > div > span > div > span > div.online > div:nth-child(4)    ???    10min
        Join Game      ${first-game}
        Sleep          3s
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

    ${base}=            Convert To Integer    3
    ${nthchild}=        Evaluate    ${base} + ${cards facedown}[0][position]
    ${nthchild}=        Convert To String    ${nthchild}
    ${cardSelector}=    Set Variable    div.board > span > span:nth-child(${nthchild})
    Click Element       css:${cardSelector}
    Sleep               5s

Do Turns

    FOR    ${i}    IN RANGE    999
        Sleep    1s

        ${gameover} =           Execute JavaScript
                                ...    let gameover = document.querySelector('.screen-entity-gameover');
                                ...    if (gameover !== null) return true;
                                ...    return false;
        Exit For Loop If        ${gameover} == True

        ${playerInTurn} =       Get Element Attribute    css:div.board div.header span.turn.active    innerText    
        Log To Console          ${playerInTurn}
        Continue For Loop If    '${playerInTurn}' != '${robotUser}'

        Turn One Card
    END
