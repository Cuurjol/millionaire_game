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
      expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
    end

    it 'kick from #create' do
      expect { post :create }.to change(Game, :count).by(0)
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
      expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
    end

    it 'kick from #answer' do
      put(:answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key })
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
      expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
    end

    it 'kick from #take_money' do
      put(:take_money, params: { id: game_w_questions.id })
      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
      expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
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
      expect(game.prize).to eq(32_000)
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

    it 'uses audience help' do
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      expect(game_w_questions.audience_help_used).to be_falsey

      put(:help, params: { id: game_w_questions.id, help_type: :audience_help })
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.audience_help_used).to be_truthy
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end

    it 'uses fifty-fifty help' do
      expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
      expect(game_w_questions.friend_call_used).to be_falsey

      put(:help, params: { id: game_w_questions.id, help_type: :fifty_fifty })
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.fifty_fifty_used).to be_truthy
      expect(game.current_game_question.help_hash[:fifty_fifty]).to be
      expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game.current_game_question.correct_answer_key)
      expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
      expect(response).to redirect_to(game_path(game))
    end

    it 'uses friend-call help' do
      expect(game_w_questions.current_game_question.help_hash[:friend_call]).not_to be
      expect(game_w_questions.friend_call_used).to be_falsey

      allow(GameHelpGenerator).to receive(:friend_call).and_return('Господин Никто считает, что это вариант А')
      put(:help, params: { id: game_w_questions.id, help_type: :friend_call })
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.friend_call_used).to be_truthy
      expect(game.current_game_question.help_hash[:friend_call]).to be
      expect(game.current_game_question.help_hash[:friend_call]).to eq('Господин Никто считает, что это вариант А')
      expect(response).to redirect_to(game_path(game))
    end
  end
end
