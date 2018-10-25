# livelyVinyl — object-relational mapping with Ruby and SQLite

## Features

#### Demo
To code along with the demo snippets shown below, clone this repo, navigate to the root directory in terminal, and load `soccer.rb` in your shell. If SQLite is installed on your machine the loaded file will automatically create and connect to the database `soccer.db`.

### `SQLObject`
To map a Ruby class to your database and give it access to livelyVinyl methods, the class must inherit from `SQLObject` and call the `finalize!` class method like so.

```
class Player < SQLObject
  finalize!
end
```

#### `::all`
Returns an array of all records in the database table that corresponds to the class the method is called on. Array items are all instances of the class.

#### `::find(id)`
Returns record in database matching the id passed as an argument; return value is an instance of the class.

```
Player.find(5) # => #<Player:0x007f8c9c7c8528
 @attributes={:id=>5, :fname=>"Mo", :lname=>"Salah", :team_id=>2}>
 ```

#### `::save`
If the class instance this method is called on already exists as a record in the database, `save` will call `update`; if not, it will create an id and save the instance to the database.

### `Searchable`
The `Searchable` module extends the `SQLObject` class, adding a `::where` method analogous to the 'where' of SQL syntax. As long as search parameters are supplied as one hash, there is no limit to the number that can be chained together. Under the hood `::where` simply parses the argument hash and converts it to a stringified SQL query.

```
Team.where(league_id: 5) # => [#<Team:0x007f8c9c55ff48
  @attributes={:id=>8, :team_name=>"Paris St. Germain", :league_id=>5}>,
 #<Team:0x007f8c9c55fe80
  @attributes={:id=>9, :team_name=>"Olympique Lyon", :league_id=>5}>]
```

### `Associatable`
The `Associatable` module gives any class inheriting from `SQLObject` access to methods that emulate Rails associations. For the time being, the methods implemented are `#has_many`, `#belongs_to` and `#has_one_through`. Below, a simple example illustrates how these might be implemented:

```
require_relative 'associatable'

class Player < SQLObject
  finalize!

  belongs_to :team, foreign_key: :team_id
  has_one_through :league, :team, :league

end

class Team < SQLObject
  finalize!

  belongs_to :league, foreign_key: :league_id
  has_many :players, foreign_key: :team_id

end

class League < SQLObject
  finalize!

  has_many :teams, foreign_key: :team_id
end
```
This structure generates, for instance, '#league' (`has_one_through`) and `#team` (`belongs_to`) methods for any instance of `Player`:

```
Player.where(fname: 'Lionel').first.league.league_name # => "La Liga"

Player.where(fname: 'Lionel').first.team.team_name # => "Barcelona"
```

## Future Plans
* `includes(association)`
* `has_many_through`
