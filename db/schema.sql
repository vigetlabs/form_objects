CREATE TABLE IF NOT EXISTS people (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS logins (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  person_id INTEGER NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_digest VARCHAR(255) NOT NULL,
  FOREIGN KEY (person_id) REFERENCES people(id)
);

CREATE TABLE IF NOT EXISTS states (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  name VARCHAR(255) NOT NULL,
  abbreviation CHAR(2) NOT NULL UNIQUE
);

INSERT INTO states (name, abbreviation)
VALUES             ('Colorado', 'CO')
ON CONFLICT (abbreviation) DO NOTHING;

INSERT INTO states (name, abbreviation)
VALUES             ('Virginia', 'VA')
ON CONFLICT (abbreviation) DO NOTHING;

INSERT INTO states (name, abbreviation)
VALUES             ('North Carolina', 'NC')
ON CONFLICT (abbreviation) DO NOTHING;

CREATE TABLE IF NOT EXISTS addresses (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  person_id INTEGER NOT NULL,
  street_1 VARCHAR(255) NOT NULL,
  street_2 VARCHAR(255) NULL,
  city VARCHAR(255) NOT NULL,
  state_id INTEGER NOT NULL,
  postal_code CHAR(5) NOT NULL ,
  FOREIGN KEY (person_id) REFERENCES people(id),
  FOREIGN KEY (state_id) REFERENCES states(id)
);
