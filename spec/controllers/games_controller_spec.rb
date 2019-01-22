require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'when user is anonymous' do
    it 'kick from #show' do
      get(:show, params: { id: game_w_questions.id })
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #create' do
      expect { post :create }.to change(Game, :count).by(0)
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #answer' do
      put(:answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key })
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #take_money' do
      put(:take_money, params: { id: game_w_questions.id })
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  context 'when user is logged in' do
    before(:each) { sign_in user }

    it 'creates game' do
      generate_questions(60)

      post(:create)
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    it '#show game' do
      get(:show, params: { id: game_w_questions.id })
      game = assigns(:game)
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end

    it 'answers correct' do
      put(:answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key })
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy
    end

    it 'does not answer correct' do
      expect(game_w_questions.finished?).to be_falsey
      game_w_questions.update_attribute(:current_level, 14)
      put(:answer, params: { id: game_w_questions.id, letter: 'a' })

      game = assigns(:game)
      expect(game.finished?).to be_truthy
      expect(game.current_level).to eq(14)
      expect(game.status).to eq(:fail)
      expect(game.prize).to eq(Game::PRIZES[Game::FIREPROOF_LEVELS[1]])
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
    end

    it '#show alien game' do
      alien_game = FactoryBot.create(:game_with_questions)
      get(:show, params: { id: alien_game.id })

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    it '#take_money' do
      game_w_questions.update_attribute(:current_level, 2)
      put(:take_money, params: { id: game_w_questions.id })
      game = assigns(:game)
      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(Game::PRIZES[1])

      user.reload
      expect(user.balance).to eq(200)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    it 'tries to create second game' do
      expect(game_w_questions.finished?).to be_falsey
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game)
      expect(game).to be_nil

      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
  end
end
