*** Settings ***
Documentation     A testing suite for applications
Force Tags    DEV
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/common.robot
Resource      ${LIBRARIES}/applications_rest_api.robot
Resource      ${LIBRARIES}/invitation_rest_api.robot
Resource      ${LIBRARIES}/customer_feedback_rest_api.robot
Resource      ${LIBRARIES}/releases_rest_api.robot
Metadata      Team: Team 42, Author:argyo01
Test Timeout  5 minutes
Suite Setup  Custom suite setup
Suite Teardown  Teardown

*** Variables ***
${MESSAGE}=  Hi <b>Yonatan</b>, this is a feedback message from ROBOT

*** Keywords ***
Custom suite setup
    Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}

Teardown
    Log To Console  ****Teardown****

*** Test Cases ***
01 - Demo invite one user into the ROBOT tennant
    [Documentation]  Use this to invite a user to the ROBOTs Workspace (Tenant)
    @{emails}=  create list  cdesaasqa01@gmail.com
    ${dto}=  Invite users to tenant  ${emails}  ok

02 - Demo delete all applications in list
    @{response_dto}=  Get All Applications
    :for  ${application_dto}  in  @{response_dto}
    \  Delete application by id "${application_dto.id}"

03 - Demo create customer feedback
     ${dto}=  Send customer feedback  ${MESSAGE}  ok

04 - Demo delete all releases by name Sample Release
    Delete "100" last Releases by filter name "Sample"