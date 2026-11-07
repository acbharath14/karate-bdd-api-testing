Feature: Login and registration on the ReqRes API

  Background:
    # baseUrl comes from karate-config.js (https://reqres.in/api by default).
    * url baseUrl

  @auth @smoke
  Scenario: Logging in with valid credentials returns 200 with a token
    Given path 'login'
    And request { email: 'eve.holt@reqres.in', password: 'cityslicka' }
    When method post
    Then status 200
    And match response.token == '#present'

  @auth @negative
  Scenario: Logging in without a password returns 400 with a Missing password error
    Given path 'login'
    And request { email: 'peter@klaven' }
    When method post
    Then status 400
    And match response.error == 'Missing password'

  @auth @negative
  Scenario: Registering without a password returns 400 with a Missing password error
    Given path 'register'
    And request { email: 'sydney@fife' }
    When method post
    Then status 400
    And match response.error == 'Missing password'

  @auth
  Scenario: Registering with valid credentials returns 200 with an id and a token
    Given path 'register'
    And request { email: 'eve.holt@reqres.in', password: 'pistol' }
    When method post
    Then status 200
    And match response.id == 4
    And match response.token == '#present'
