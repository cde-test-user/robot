*** Settings ***
Documentation     A testing suite for applications
Force Tags    PROGRESSION  DEV
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/phases_rest_api.robot
Resource      ${LIBRARIES}/tasks_rest_api.robot
Resource      ${LIBRARIES}/execution_rest_api.robot
Metadata      Author:argyo01
Test Timeout  30 minutes
Suite Setup  Custom suite setup
Suite Teardown  Custom suite teardown

*** Keywords ***
Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
    ${time}=  Get Time  epoch
    ${dto}=  Create a release by name "Bugs Tests Release ${time}" description "Release for Phase transitions thesing suite" version "${time}"
    Set suite variable  ${release_id}  ${dto.id}

Custom suite teardown
    Run Keyword If All Tests Passed  Delete a release by id "${release_id}"

*** Test Cases ***
Bug 15319 Phase status update
    [Documentation]  A scenario recreation to catch a bug where the Phase status is not updated to DONE
    ...  We expect the "Wait Until Keyword Succeeds" Line to fail with RUNNING != DONE
    :FOR    ${i}    IN RANGE    100
        \  ${miliTime}=  Get Time  epoch
        \  ${phaseDto}=  Create first phase by name "P bug1 ${miliTime}" description "${miliTime}" at release "${release_id}"
        \  ${task1Dto}=  Create a task by name "T bug1 ${miliTime}" description "1 ${miliTime}" at phase "${phaseDto.id}" at release "${release_id}"
        \  ${task2Dto}=  Create Next task by name "T bug2 ${miliTime}" description "2 ${miliTime}" with prev task "${task1Dto.id}" at phase "${phaseDto.id}" at release "${release_id}"
        \  ${task3Dto}=  Create Next task by name "T bug3 ${miliTime}" description "3 ${miliTime}" with prev task "${task2Dto.id}" at phase "${phaseDto.id}" at release "${release_id}"
        \  Update phase-execution of phase "${phaseDto.id}" of release "${release_id}" with status "RUNNING"
        \  Wait Until Keyword Succeeds  10 sec  1 sec  verify task-execution "${task1Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" is in status "PENDING"
        \  Update task-execution of task "${task1Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "RUNNING"
        \  Update task-execution of task "${task1Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "DONE"
        \  Wait Until Keyword Succeeds  10 sec  1 sec  verify task-execution "${task2Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" is in status "PENDING"
        \  Update task-execution of task "${task2Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "RUNNING"
        \  Update task-execution of task "${task2Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "DONE"
        \  Wait Until Keyword Succeeds  10 sec  1 sec  verify task-execution "${task3Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" is in status "PENDING"
        \  Update task-execution of task "${task3Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "RUNNING"
        \  Update task-execution of task "${task3Dto.id}" of phase "${phaseDto.id}" of release "${release_id}" with status "DONE"
        \  Wait Until Keyword Succeeds  10 sec  1 sec  verify phase-execution of phase "${phaseDto.id}" of release "${release_id}" is in status "DONE"
        \  Delete a phase by id "${phaseDto.id}" at release "${release_id}"