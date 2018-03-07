*** Settings ***
Documentation     A testing suite for applications
Force Tags    PROGRESSION  DEV
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/phases_rest_api.robot
Resource      ${LIBRARIES}/tasks_rest_api.robot
Library  Dialogs
Library  Collections
Metadata      Author:turer02
Test Timeout  5 minutes
Suite Setup  Custom suite setup



*** Keywords ***
Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
    ${time}=  Get Time


Create tasks "${tasks}" under phase id "${phase_id}" in release "${release_id}"
        ${task}=  Remove From List  ${tasks}  0
        ${name} =	Get From Dictionary  ${task}  name
        ${description} =	Get From Dictionary  ${task}  description
        ${prev_task}=  Create a task by name "${name}" description "${description}" at phase "${phase_id}" at release "${release_id}"
         :for  ${task}  in  @{tasks}
                \  ${name} =	Get From Dictionary  ${task}  name
                \  ${description} =	Get From Dictionary  ${task}  description
                \  ${dto}=  Create Next task by name "${name}" description "${description}" with prev task "${prev_task.id}" at phase "${phase_id}" at release "${release_id}"
                \  Set suite variable  ${prev_task}  ${dto}

*** Test Cases ***


demo-create release with content
#    Set suite variable  ${version}  1.9
    ${version}=  Get Value From User  Enter version:  1.0
    Set suite variable  ${release_name}  R1 - Demo
    Set suite variable  ${release_desc}  Very real demo release
    ${dto}=  Create a release by name "${release_name}" description "${release_desc}" version "${version}"

    Set suite variable  ${release_id}  ${dto.id}
    Set suite variable  ${phase1}  Development
    Set suite variable  ${phase2}  Testing
    Set suite variable  ${phase3}  Production

    # Create 3 phases
    ${dto}=  Create first phase by name "${phase1}" description "This phase ... 1" at release "${release_id}"
    Set suite variable  ${phase1_id}  ${dto.id}
    ${dto}=  Create non first phase by name "${phase2}" previous phase ID "${dto.id}" description "This phase ... 2" at release "${release_id}"
    Set suite variable  ${phase2_id}  ${dto.id}
    ${dto}=  Create non first phase by name "${phase3}" previous phase ID "${dto.id}" description "This phase ... 3" at release "${release_id}"
    Set suite variable  ${phase3_id}  ${dto.id}


    # Create tasks for phase 1
    ${T1_1} =  Create Dictionary  name=Breakdown stories and asign to scrum teams  description=task1_1
    ${T1_2} =  Create Dictionary  name=Implementation by teams  description=task1_2
    ${T1_3} =  Create Dictionary  name=All teams should prepare deployment plans with what they have finished. All should be under proj. newsPortal-5.2  description=task1_3
    ${T1_4} =  Create Dictionary  name=Deploy CalcRoute  description=task1_4
    ${T1_5} =  Create Dictionary  name=Deploy Flights  description=task1_5
    ${T1_6} =  Create Dictionary  name=Deploy Hotels  description=task1_6
    @{task_list1} =  Create List  ${T1_1}  ${T1_2}  ${T1_3}  ${T1_4}  ${T1_5}  ${T1_6}
    Create tasks "${task_list1}" under phase id "${phase1_id}" in release "${release_id}"

    # Create tasks for phase 2
    ${T2_1} =  Create Dictionary  name=Raise debug level  description=task2_1
    ${T2_2} =  Create Dictionary  name=Deploy CalcRoute  description=task2_2
    ${T2_3} =  Create Dictionary  name=Deploy Flights  description=task2_3
    ${T2_4} =  Create Dictionary  name=Deploy Hotels  description=task2_4
    ${T2_5} =  Create Dictionary  name=CalcRoute-Registration  description=task2_5
    ${T2_6} =  Create Dictionary  name=Flights-Registration  description=task2_6
    ${T2_7} =  Create Dictionary  name=E2E-fullTest  description=task2_7
    ${T2_8} =  Create Dictionary  name=Notify Teams  description=task2_8
    @{task_list2} =  Create List  ${T2_1}  ${T2_2}  ${T2_3}  ${T2_4}  ${T2_5}  ${T2_6}  ${T2_7}  ${T2_8}
    Create tasks "${task_list2}" under phase id "${phase2_id}" in release "${release_id}"

    #  Create tasks for phase 3
    ${T3_1} =  Create Dictionary  name=Open Firewall  description=task3_1
    ${T3_2} =  Create Dictionary  name=Deploy CalcRoute  description=task3_2
    ${T3_3} =  Create Dictionary  name=Deploy Flights  description=task3_3
    ${T3_4} =  Create Dictionary  name=Deploy Hotels  description=task3_4
    ${T3_5} =  Create Dictionary  name=Cofigure firewall back to normal  description=task3_5
    @{task_list3} =  Create List  ${T3_1}  ${T3_2}  ${T3_3}  ${T3_4}  ${T3_5}
    Create tasks "${task_list3}" under phase id "${phase3_id}" in release "${release_id}"