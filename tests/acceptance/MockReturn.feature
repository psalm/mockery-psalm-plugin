Feature: MockReturn

  Background:
    Given I have the following config
      """
      <?xml version="1.0"?>
      <psalm totallyTyped="true">
        <projectFiles>
          <directory name="."/>
          <ignoreFiles> <directory name="../../vendor"/> </ignoreFiles>
        </projectFiles>
        <plugins>
          <pluginClass class="Psalm\MockeryPlugin\Plugin"/>
        </plugins>
      </psalm>
      """
    And I have the following code preamble
      """
      <?php
      namespace NS;
      use Mockery;
      
      """

  Scenario: Defined method mocking sets proper intersection return type
    Given I have the following code
      """
      class User
      {
          /**
           * @return void
           */
          public function someMethod()
          {
          
          }
      }
      
      $user = Mockery::mock('NS\User[someMethod]', []);
      
      if (is_array($user)) {
      
      }
      """
    When I run Psalm
    Then I see these errors
      | Type            | Message                                                                                                                                 |
      | DocblockTypeContradiction | Docblock-defined type Mockery\MockInterface&NS\User for $user is never array |
    And I see no other errors

  Scenario: Alias class mocking is recognized
    Given I have the following code
      """
      class User
      {
      }

      $user = Mockery::mock('alias:NS\User')->shouldReceive('someMethod');
      """
    When I run Psalm
    Then I see no errors

  Scenario: Overload class mocking is recognized
    Given I have the following code
      """
      class User
      {
      }

      $user = Mockery::mock('overload:NS\User')->shouldReceive('someMethod');
      """
    When I run Psalm
    Then I see no errors

  Scenario: Expectations can be set on mocked instances
    Given I have the following code
      """
      class User
      {
          public function getName(): string {
            return 'name';
          }
      }
      $user = Mockery::mock(User::class);
      $user
        ->shouldReceive('getName')->andReturn('feek')
        ->shouldReceive('foo')->andReturnNull();
      """
    When I run Psalm
    Then I see no errors
