CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  team_name VARCHAR(255) NOT NULL,
  league_id INTEGER,

  FOREIGN KEY(league_id) REFERENCES league(id)
);

CREATE TABLE players (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES team(id)
);

CREATE TABLE leagues (
  id INTEGER PRIMARY KEY,
  country VARCHAR(255) NOT NULL,
  league_name VARCHAR(255) NOT NULL
);

INSERT INTO
  leagues (id, country, league_name)
VALUES
  (1, "England", "Premier League"),
  (2, "Spain", "La Liga"),
  (3, "Germany", "Bundesliga"),
  (4, "Italy", "Serie A"),
  (5, "France", "Ligue Un");

INSERT INTO
  teams (id, team_name, league_id)
VALUES
  (1, "Arsenal", 1),
  (2, "Liverpool", 1),
  (3, "Barcelona", 2),
  (4, "Real Madrid", 2),
  (5, "Borussia Dortmund", 3),
  (6, "Juventus", 4),
  (7, "Napoli", 4),
  (8, "Paris St. Germain", 5),
  (9, "Olympique Lyon", 5),
  (10, "Bayern Munich", 3);

INSERT INTO
  players (id, fname, lname, team_id)
VALUES
  (1, "Lionel", "Messi", 3),
  (2, "Luis", "Suarez", 3),
  (3, "Pierre", "Emerick Aubameyang", 1),
  (4, "Alexandre", "Lacazette", 1),
  (5, "Mo", "Salah", 2),
  (6, "Roberto", "Firmino", 2),
  (7, "Luka", "Modric", 4),
  (8, "Gareth", "Bale", 4),
  (9, "Christian", "Pulisic", 5),
  (10, "Jadon", "Sancho", 5),
  (11, "Cristiano", "Ronaldo", 6),
  (12, "Douglass", "Costa", 6),
  (13, "Marek", "Hamsik", 7),
  (14, "Dries", "Mertens", 7),
  (15, "Neymar", "Santos da Silva Jr.", 8),
  (16, "Timothy", "Weah", 8),
  (17, "Houssem", "Aouar", 9),
  (18, "Nabil", "Fekir", 9),
  (19, "Frank", "Ribery", 10),
  (20, "Corentin", "Tollisso", 10);
