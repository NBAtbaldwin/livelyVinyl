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
