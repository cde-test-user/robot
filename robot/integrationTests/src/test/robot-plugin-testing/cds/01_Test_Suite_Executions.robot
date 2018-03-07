*** Settings ***
Documentation     A testing suite for cds test suite executions
Force Tags    PROGRESSION  cds  premonly
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/applications_rest_api.robot
Resource      ${LIBRARIES}/application_versions_rest_api.robot
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/test_suite_executions_rest_api.robot
Resource      ${LIBRARIES}/cds_configuration.robot
Resource      ${LIBRARIES}/common.robot
Test Timeout  5 minutes
Suite Setup  Custom suite setup
Suite Teardown  Teardown



*** Keywords ***

Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
    ${time}=  Get Time  epoch
    ${test_suite_execution_id}=  Generate Random Value  10  true  true
    set suite variable  ${test_suite_execution_id}  ${test_suite_execution_id}
    ${application}=  Create application by name "app - ${time}" description "description"
    set suite variable  ${application}  ${application}
    ${release}=  Create a release by name "release for test suite executions - ${time}" description "description" version "1.0"
    set suite variable  ${release}  ${release}
    Assign Single Application "${application.id}" to Release "${release.id}"
    ${application_version}=  Create application version by application id "${application.id}" release id "${release.id}" and version "${time}"
    set suite variable  ${application_version}  ${application_version}

    ${cdsEnabled}=  Is CDS Enabled
    Set Suite Variable  ${cdsEnabled}
    ${cdsEnablementStatus}=  Set Variable If  ${cdsEnabled}  ok  microServiceDisabled
    Set Suite Variable  ${cdsEnablementStatus}

Teardown
    Delete application by id "${application.id}"
    delete a release by id "${release.id}"


validate test suite execution contatins applicaton
    [Arguments]  ${application_id}  ${application_version_id}  @{test_suite_executions}
    :for  ${test_suite_execution}  IN  @{test_suite_executions}
    \  Should Be Equal As Integers  ${test_suite_execution.application.id}  ${application_id}
    \  Should Be Equal As Integers  ${test_suite_execution.applicationVersion.id}  ${application_version_id}



*** Test Cases ***

01 - get test suite executions
    [Tags]  DEV
    ${output}=  Get application version test suite execution  ${application.id}  ${application_version.id}  ${cdsEnablementStatus}
    Run Keyword If  ${cdsEnabled}  validate test suite execution contatins applicaton  ${application.id}  ${application_version.id}  @{output}
    ...             ELSE           Validate CDS Disabled Error  ${output}

02 - get test suite executions
    [Tags]  DEV
    ${output}=  get test suite execution by id  ${application.id}  ${application_version.id}  ${test_suite_execution_id}  ${cdsEnablementStatus}
    Run Keyword If  ${cdsEnabled}  Should Be Equal As Integers  ${output.application.id}  ${application.id}
    Run Keyword If  ${cdsEnabled}  Should Be Equal As Integers  ${output.applicationVersion.id}  ${application_version.id}
    Run Keyword Unless  ${cdsEnabled}  Validate CDS Disabled Error  ${output}
