# Application MILLIONAIRE

MILLIONAIRE is an application which simulate the famous game "Who Wants to Be a Millionaire?".

## Rules of the game

1. Answer 15 questions.
2. Game session time is 35 minutes.
3. You can use three hints (fifty-fifty, audience help, friend's call) if you don't know an answer on the question.
4. The game continues until the first error, end of the game session time or victory.

## Annotation

Application was created on `Ruby (v2.5.1)` and `Ruby on Rails (v5.2.2)`.

## Installation and running

Before running the application, you need to install all the necessary gems and prepare the database. In order to do this, you need to run the following comands in the terminal:
```
bundle install
bundle exec rake db:migrate
```

Then, run the local server:
```
bundle exec rails s
```

After, go to the browser at `http://localhost:3000`.

You can watch a list of all used gems in the `Gemfile`.

## Heroku deployment

Study project is ready for deployment on the Heroku. The working version of the project can be viewed at [`Heroku website`](https://cuurjol-millionaire-game.herokuapp.com/).

## Author

Study project was created by [goodprogrammer.ru](https://goodprogrammer.ru/). The TDD/BDD methods were considered and studied more details in this project.
