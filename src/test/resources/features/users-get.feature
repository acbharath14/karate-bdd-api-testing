Feature: Reading users from the ReqRes API

  Background:
    # baseUrl comes from karate-config.js (https://reqres.in/api by default).
    * url baseUrl

  @users @smoke
  Scenario: Getting one user returns the expected name and email
    Given path 'users', 2
    When method get
    Then status 200
    And match response.data.id == 2
    And match response.data.first_name == 'Janet'
    And match response.data.last_name == 'Weaver'
    And match response.data.email == 'janet.weaver@reqres.in'

  @users
  Scenario: Getting the user list returns paginated data
    Given path 'users'
    And param page = 2
    When method get
    Then status 200
    And match response.page == 2
    And match response.per_page == 6
    And match response.total == 12
    And match response.data == '#[6]'
    And match response.data[0].id == '#present'

  @users @negative
  Scenario: Getting a user that does not exist returns 404 with an empty body
    Given path 'users', 23
    When method get
    Then status 404
    And match response == {}
