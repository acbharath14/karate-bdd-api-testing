Feature: Deleting users on the ReqRes API

  Background:
    # baseUrl comes from karate-config.js (https://reqres.in/api by default).
    * url baseUrl

  @users
  Scenario: Deleting a user returns 204 with no content
    Given path 'users', 2
    When method delete
    Then status 204
