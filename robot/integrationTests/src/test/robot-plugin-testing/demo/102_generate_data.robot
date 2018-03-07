*** Settings ***
Documentation     A demo suite for auto generating data
Force Tags    DEV
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/phases_rest_api.robot
Resource      ${LIBRARIES}/tasks_rest_api.robot
Library  Dialogs
Library  Collections
Metadata      Author:argyo01
Test Timeout  5 minutes
Suite Setup  Custom suite setup



*** Keywords ***
Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
    ${time}=  Get Time  epoch
    Set suite variable  ${miliTime}  ${time}
#   Default values - change to set different amounts
    Set suite variable  ${releaseAmount}    3
    Set suite variable  ${phaseAmount}      3
    Set suite variable  ${taskAmount}       3

Create "${n}" releases
        :for  ${i}  IN RANGE  ${releaseAmount}
                \  ${dto}=  Create a release by name "Release ${i} ${miliTime}" description "Release ${i} Description" version "${i}.0"
                \  Set suite variable  ${release_id}  ${dto.id}

Create "${n}" phases under release id "${release_id}"
        ${prev_phase}=  Create first phase by name "Phase 0" description "Phase a Description" at release "${release_id}"
         :for  ${i}  IN RANGE  1  ${phaseAmount}
                \  ${dto}=  Create non first phase by name "Phase ${i}" previous phase ID "${prev_phase.id}" description "Phase ${i} Description" at release "${release_id}"
                \  Set suite variable  ${prev_phase}  ${dto}

Create "${n}" tasks under phase id "${phase_id}" in release "${release_id}"
        ${prev_task}=  Create a task by name "Task 0" description "Task a Description" at phase "${phase_id}" at release "${release_id}"
         :for  ${i}  IN RANGE  1  ${taskAmount}
                \  ${dto}=  Create Next task by name "Task ${i}" description "Task ${i} Description" with prev task "${prev_task.id}" at phase "${phase_id}" at release "${release_id}"
                \  Set suite variable  ${prev_task}  ${dto}

Loop Phases under "${release_id}"
        Create "${phaseAmount}" phases under release id "${release_id}"
        ${phaseList}=  Get All Phases in Release by id "${release_id}"
            :for  ${phase}  in  @{phaseList}
                \  Create "${taskAmount}" tasks under phase id "${phase.id}" in release "${release_id}"

*** Test Cases ***
Demo-Auto Generate RP data
    [Documentation]  Creates X releases with Y phases per Release and Z tasks per phase per release
#    Uncomment lines below to manually set amounts during test execution
#    ${releaseAmount}=   Get Value From User  How many Releases:     3
#    ${phaseAmount}=     Get Value From User  Phases per Release:    3
#    ${taskAmount}=      Get Value From User  Tasks per Phase:       3
    set suite variable  ${n}  ${releaseAmount}
    Create "${n}" releases
    ${releaseList}=  Get All Releases with name "${miliTime}"
    :for  ${release}  in  @{releaseList}
        \  Loop Phases under "${release.id}"