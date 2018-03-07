*** Settings ***
Documentation     A testing suite for applications
Force Tags    PROGRESSION  DEV
Variables     ${RESOURCES}/sut.py
Resource      ${LIBRARIES}/applications_rest_api.robot
Library  Collections
Metadata      Author:turer02
Test Timeout  5 minutes
Suite Setup  Custom suite setup


*** Keywords ***
Custom suite setup
   Init Http Client  ${HOST}  ${PORT}  ${SCHEME}  ${USER}  ${PASSWORD}
   ${time}=  Get Time

Create environments "${envs}" under application with id "${app_id}"
         :for  ${env}  in  @{envs}
                \  ${name} =	Get From Dictionary  ${env}  name
                \  ${description} =	Get From Dictionary  ${env}  description
                \  Create environment by name "${name}" description "${description}" under application with id "${app_id}"

Create applications "${apps}"
        :for  ${app}  in  @{apps}
                 \  ${name} =	Get From Dictionary  ${app}  name
                 \  ${description} =	Get From Dictionary  ${app}  description
                 \  ${dto}=  Create application by name "${name}" description "${description}"
                 \  ${envs} =	Get From Dictionary  ${app}  envs
                 \  Create environments "${envs}" under application with id "${dto.id}"

*** Test Cases ***

demo create apps with envs
    ${ENV1_1} =  Create Dictionary  name=CalcRoute-development  description=CalcRoute - development
    ${ENV1_2} =  Create Dictionary  name=CalcRoute-testing  description=CalcRoute - testing
    ${ENV1_3} =  Create Dictionary  name=CalcRoute-production  description=CalcRoute - production
    @{env_list1} =  Create List  ${ENV1_1}  ${ENV1_2}  ${ENV1_3}

    ${ENV2_1} =  Create Dictionary  name=Flights-development  description=Flights - development
    ${ENV2_2} =  Create Dictionary  name=Flights-testing  description=Flights - testing
    ${ENV2_3} =  Create Dictionary  name=Flights-production  description=Flights - production
    @{env_list2} =  Create List  ${ENV2_1}  ${ENV2_2}  ${ENV2_3}

    ${ENV3_1} =  Create Dictionary  name=Hotels-development  description=Hotels - development
    ${ENV3_2} =  Create Dictionary  name=Hotels-testing  description=Hotels - testing
    ${ENV3_3} =  Create Dictionary  name=Hotels-production  description=Hotels - production
    @{env_list3} =  Create List  ${ENV3_1}  ${ENV3_2}  ${ENV3_3}

    ${A1} =  Create Dictionary  name  CalcRoute  description  CalcRoute..  envs  ${env_list1}
    ${A2} =  Create Dictionary  name  Flights  description  Flights..  envs  ${env_list2}
    ${A3} =  Create Dictionary  name  Hotels  description  Hotels..  envs  ${env_list3}

    @{app_list} =  Create List  ${A1}  ${A2}  ${A3}
    Create applications "${app_list}"
