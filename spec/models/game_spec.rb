require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_with_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Game Factory' do
    it 'Game.create_game_for_user! new correct game' do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(change(GameQuestion, :count).by(15).and(change(Question, :count).by(0)))

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues' do
      level = game_with_questions.current_level
      q = game_with_questions.current_game_question
      expect(game_with_questions.status).to eq(:in_progress)

      game_with_questions.answer_current_question!(q.correct_answer_key)
      expect(game_with_questions.current_level).to eq(level + 1)
      expect(game_with_questions.current_game_question).not_to eq(q)
      expect(game_with_questions.status).to eq(:in_progress)
      expect(game_with_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      q = game_with_questions.current_game_question
      game_with_questions.answer_current_question!(q.correct_answer_key)

      game_with_questions.take_money!
      prize = game_with_questions.prize
      expect(prize).to be > 0

      expect(game_with_questions.status).to eq :money
      expect(game_with_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end

    it '.current_game_question' do
      expect(game_with_questions.current_game_question).to eq(game_with_questions.game_questions[0])
      game_with_questions.current_level = 10
      expect(game_with_questions.current_game_question).to eq(game_with_questions.game_questions[10])
    end

    it '.previous_level' do
      expect(game_with_questions.previous_level).to eq(-1)
      game_with_questions.current_level = 10
      expect(game_with_questions.previous_level).to eq(9)
    end
  end

  context '.status' do
    before(:each) do
      game_with_questions.finished_at = Time.now
      expect(game_with_questions.finished?).to be_truthy
    end

    it ':won' do
      game_with_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_with_questions.status).to eq(:won)
    end

    it ':fail' do
      game_with_questions.is_failed = true
      expect(game_with_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_with_questions.created_at = 1.hour.ago
      game_with_questions.is_failed = true
      expect(game_with_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_with_questions.status).to eq(:money)
    end
  end

  describe '#answer_current_question!' do
    context 'when the answer is right and the question is not last' do
      it 'returns true' do
        expect(game_with_questions.answer_current_question!('d')).to be_truthy
        expect(game_with_questions.status).to eq(:in_progress)
        expect(game_with_questions.current_level).to eq(1)
      end
    end

    context 'when answer is wrong and the question is not last' do
      it 'returns false' do
        expect(game_with_questions.answer_current_question!('a')).to be_falsey
        expect(game_with_questions.status).to eq(:fail)
        expect(game_with_questions.current_level).to eq(0)
      end
    end

    context 'when answer is gotten after timeout' do
      it 'returns false' do
        game_with_questions.created_at -= 40.minutes
        expect(game_with_questions.answer_current_question!('d')).to be_falsey
        expect(game_with_questions.status).to eq(:timeout)
        expect(game_with_questions.current_level).to eq(0)
      end
    end

    context 'when answer is last' do
      before(:each) do
        game_with_questions.current_level = 14
      end

      it 'returns true if answer is right and user gets 1 million' do
        expect(game_with_questions.answer_current_question!('d')).to be_truthy
        expect(game_with_questions.status).to eq(:won)
        expect(game_with_questions.prize).to eq(Game::PRIZES.last)
      end

      it 'returns false if answer is wrong and user gets 32 thousands' do
        expect(game_with_questions.answer_current_question!('a')).to be_falsey
        expect(game_with_questions.status).to eq(:fail)
        expect(game_with_questions.prize).to eq(Game::PRIZES[Game::FIREPROOF_LEVELS[1]])
      end
    end
  end
end