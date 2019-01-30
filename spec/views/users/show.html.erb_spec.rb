require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryBot.build_stubbed :user, name: 'Cuurjol' }
  let(:games) do
    [
      FactoryBot.build_stubbed(:game),
      FactoryBot.build_stubbed(:game),
      FactoryBot.build_stubbed(:game),
      FactoryBot.build_stubbed(:game),
      FactoryBot.build_stubbed(:game)
    ]
  end

  before(:each) do
    assign(:user, user)
    assign(:games, games)
    render
  end

  it 'renders username' do
    expect(rendered).to match('Cuurjol')
  end

  it 'renders changing name/password button for current user' do
    allow(view).to receive(:current_user).and_return(user)
    render
    expect(rendered).to match('Сменить имя и пароль')
  end

  it 'does not render changing name/password button for other user' do
    expect(rendered).not_to match('Сменить имя и пароль')
  end

  it 'renders games list' do
    stub_template 'users/_game.html.erb' => "User has 5 games\n"
    render

    expect(rendered.scan(/User has 5 games/m).size).to eq 5
  end
end