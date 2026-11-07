Feature: Creating and updating users on the ReqRes API

  Background:
    # baseUrl comes from karate-config.js (https://reqres.in/api by default).
    * url baseUrl

  @users @smoke
  Scenario: Creating a user returns 201 with an id and a creation timestamp
    Given path 'users'
    And request { name: 'morpheus', job: 'leader' }
    When method post
    Then status 201
    And match response.name == 'morpheus'
    And match response.job == 'leader'
    And match response.id == '#present'
    And match response.createdAt == '#notnull'

  @users
  Scenario: Updating a user with PUT returns 200 with an updated timestamp
    Given path 'users', 2
    And request { name: 'morpheus', job: 'zion resident' }
    When method put
    Then status 200
    And match response.name == 'morpheus'
    And match response.job == 'zion resident'
    And match response.updatedAt == '#notnull'

  @users
  Scenario: Updating a user with PATCH returns 200 with an updated timestamp
    Given path 'users', 2
    And request { name: 'morpheus', job: 'zion resident' }
    When method patch
    Then status 200
    And match response.name == 'morpheus'
    And match response.job == 'zion resident'
    And match response.updatedAt == '#notnull'
