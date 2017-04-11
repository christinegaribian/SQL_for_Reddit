DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);



DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,--(subject question)*/
  parent_id INTEGER, --(top level doesnt have a parent)*/
  users_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (questions_id) REFERENCES questions(id)
  FOREIGN KEY (parent_id) REFERENCES replies(id)
  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);





INSERT INTO
  users (fname, lname)
VALUES
  ("Christine", "Garibian"),
  ("Hayg", "Astourian"),
  ("AA", "BB");



INSERT INTO
  questions (title, body, users_id)
VALUES
  ("Where can I go rollerskating in SF?", "I just came to the city and
    I would love to go rollerskating", 1),
  ("What are some of the best jobs in California?", "Trying to change my
    career", 2);


INSERT INTO
  question_follows (users_id, questions_id)
VALUES
  ((SELECT id from users where fname = "Christine"), 1),
  ((SELECT id from users where fname = "Hayg"), 1),
  ((SELECT id from users where fname = "AA"), 2);
--
-- INSERT INTO
--   question_follows (questions_id, users_id)
-- VALUES
--   (SELECT id FROM questions WHERE fname = 'Christine'), (SELECT )
--   (2,1),
--   ("What are some of the best jobs in California?", "Trying to change my
--     career", 2);


INSERT INTO
  replies(questions_id, parent_id, users_id, body)
VALUES
  (1, null, 3, "I think there's a church or something"),
  (1, 1, 1, "Noooooo way really?"),
  (1, 1, 2, "Yeah I heard the same thing");
