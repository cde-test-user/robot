*** Settings ***
Documentation     A testing reports
Force Tags    PROGRESSION  DEV
# *** NOTE ***
# This suite is marked as DEV because its use cases are tested within the cdd integrations projects where it belongs.
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/applications_rest_api.robot
Resource      ${LIBRARIES}/application_versions_rest_api.robot
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/cds_configuration.robot
Resource      ${LIBRARIES}/phases_rest_api.robot
Resource      ${LIBRARIES}/service_providerd_rest_api.robot
Resource      ${LIBRARIES}/plugin_rest_api.robot
Resource      ${LIBRARIES}/dsl_manifests_api.robot
Resource      ${LIBRARIES}/test_suite_api.robot
Resource      ${LIBRARIES}/service_providerd_rest_api.robot
Resource      ${LIBRARIES}/phases_rest_api.robot
Resource      ${LIBRARIES}/execution_rest_api.robot
Resource      ${LIBRARIES}/releases_rest_api.robot
Resource      ${LIBRARIES}/tasks_rest_api.robot
Resource      ${LIBRARIES}/test_suite_report_rest_api.robot
Resource      ${LIBRARIES}/plugin_service_template_parameter_api.robot
Resource      ${LIBRARIES}/plugin_service_api.robot
Resource      ${LIBRARIES}/tar_helper_rest_api.robot
Resource      ${LIBRARIES}/common.robot
Resource      ${LIBRARIES}/test_source_api.robot
Library  Collections
Library  OperatingSystem
Test Timeout  5 minutes

Suite Setup  Custom suite setup
Suite Teardown  Teardown

*** Variables ***
${blazeMeterApi}=  ngyggie6czlqzb26vx1t
${BM_workspace}=  Default workspace
${BM_Project}=  Tar_Tests_Results
${release_ver}=  1
${blazeMetrePluginName}=  BlazeMeter
${tags}=  ["t1", "t2", "t3"]
${phaseName}=  Phase_1


*** Test Cases ***

01- Execute TAR TASK with BlazeMeter Tests
     Update phase-execution of phase "${phasesId}" of release "${releaseId}" with status "RUNNING"
     ${taskDto}=  Get All Tasks at phase "${phasesId}" at release "${releaseId}"
     Wait For Task status  ${taskDto[0].id}  ${phasesId}  ${releaseId}  FAILED

02 - Get Data For Insights Reports Main page By Application Version
    ${response}=  Get Reports By Application Version  ${application.id}  ${app_ver}  ok
    ${numOfFailedTestSuite}=  Convert To String  ${response[0].pluginExecutionCounterDtos[0].numberOfFailedTestSuiteExecutions}
    ${numOfSuccessfulExec}=  Convert To String  ${response[0].pluginExecutionCounterDtos[0].numberOfSuccessfulTestSuiteExecutions}
    Should be equal  ${numOfFailedTestSuite}  1
    Should be equal  ${numOfSuccessfulExec}  0
    Should be equal  ${response[0].pluginExecutionCounterDtos[0].name}  ${blazeMetrePluginName}

03 - Get application insight report per phase and plugin
    ${response}=  Get Application Insight Report Per Phase and Plugin  ${application.id}  ${app_ver}  ${phasesId}  ${bmPluginDto.id}  ok
    ${numOfFailedTestSuite}=  Convert To String  ${response.pluginTestExecutions[0].numberOfFailedTestSuites}
    ${numOfSuccessfulSuite}=  Convert To String  ${response.pluginTestExecutions[0].numberOfSuccessfulTestSuites}
    Should be equal  ${numOfFailedTestSuite}  1
    Should be equal  ${numOfSuccessfulSuite}  1
    Should be equal  ${response.application.name}  ${application.name}
    Should be equal  ${response.applicationVersion.name}  1
    Should be equal  ${response.phase.name}  ${phaseName}
    Should be equal  ${response.name}  ${blazeMetrePluginName}

*** Keywords ***

Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
    ${time}=  Get Time  epoch
    Set suite variable  ${time}  ${time}
    Craete Application and Environment
    Import Release with Tar Task
    Get Application version ID
    Create BlazeMeter endpoint with Specific API
    Import BlazeMeterTests

Craete Application and Environment
    ${application}=  Create application by name "app insight- ${time}" description "description"
    set suite variable  ${application}  ${application}
    Create Environment by name "env_tar_${time}" description "TAR test" under application with id "${application.id}"

Create BlazeMeter endpoint with Specific API
    ${endpointDto1}=  create Blaze Meter endpoint with specific user  ${blazeMeterApi}  BM_EP_${time}
    Set suite variable  ${bmEndpointDto}  ${endpointDto1}
    ${bmPluginDto}=  Get Plugin by Name  ${blazeMetrePluginName}
    ${bmPluginTemplate}=  Get Test Source Plugin Template By Plugin Id And Name  ${bmPluginDto.id}  ${blazeMetrePluginName}
    Set suite variable  ${bmPluginTemplate}
    Set suite variable  ${bmPluginDto}

Import Release with Tar Task
    ${importJsonFile}=  Get File  ${CURDIR}/releaseWithTarTask.json
    ${importJsonFile}=  Replace String  ${importJsonFile}  @@app_name@@  app insight- ${time}
    ${importJsonFile}=  Replace String  ${importJsonFile}  @@release_name@@  TAR_release_${time}
    ${importJsonFile}=  Replace String  ${importJsonFile}  @@env_name@@  env_tar_${time}
    import entities  ${importJsonFile}  ok
    Get Release and Phase ID

Get Application version ID
    ${app_version}=  Get application versions by release id "${releaseId}"
    set suite variable  ${app_ver}  ${app_version[0].id}

Get Release and Phase ID
     ${imported_release}=  Get My Releases with filter "TAR_release_${time}"
     set suite variable  ${releaseId}  ${imported_release[0].id}
     ${phases}=  Get phase by name within release  ${phaseName}  ${releaseId}
     set suite variable  ${phasesId}  ${phases.id}

Import BlazeMeterTests
    ${testSourceJson}=  Create BlazeMEter Test Source Json with Real Data  Tar Test Source ${time}  ${BM_workspace}  ${BM_Project}  ${tags}
    ${bmTestSourceDto}=  Import Test Suites  ${application.id}  ${app_ver}  ${testSourceJson}   ok
    Wait Untill Test Source Is Synchronized  ${application.id}  ${app_ver}  ${bmTestSourceDto.id}  120
    Sleep  4 sec

Wait For Task status
    [Arguments]  ${taskId}  ${phaseId}  ${releaseId}  ${status}
    Wait Until Keyword Succeeds  180 sec  1 sec  verify task-execution "${taskId}" of phase "${phaseId}" of release "${releaseId}" is in status "${status}"

Teardown
    Delete application by id "${application.id}"
    delete a release by id "${releaseId}"
    Delete an endpoint by id "${bmEndpointDto.id}"
