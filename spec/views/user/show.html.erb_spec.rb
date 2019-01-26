require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryBot.build_stubbed :user, name: 'Cuurjol' }
  let(:games) do
    [
      FactoryBot.build_stubbed(:game, id: 3, created_at: Time.parse('2017.09.03, 10:00'), current_level: 3, prize: 3_000),
      FactoryBot.build_stubbed(:game, id: 7, created_at: Time.parse('2019.09.07, 10:00'), finished_at: Time.parse('2019.09.07, 10:30'), current_level: 7, prize: 7_000),
      FactoryBot.build_stubbed(:game, id: 11, created_at: Time.parse('2023.09.11, 10:00'), finished_at: Time.parse('2023.09.11, 10:30'), is_failed: true, current_level: 11, prize: 11_000),
      FactoryBot.build_stubbed(:game, id: 13, created_at: Time.parse('2027.09.13, 10:00'), finished_at: Time.parse('2027.09.13, 10:30'), current_level: 15, prize: 13_000),
      FactoryBot.build_stubbed(:game, id: 17, created_at: Time.parse('2029.09.17, 10:00'), finished_at: Time.parse('2029.09.17, 10:45'), is_failed: true, current_level: 14, prize: 512_000)
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
    expect(rendered).to match(/3.*в процессе.*03 сент., 10:00.*3.*3 000 ₽/m)
    expect(rendered).to match(/7.*деньги.*07 сент., 10:00.*7.*7 000 ₽/m)
    expect(rendered).to match(/11.*проигрыш.*11 сент., 10:00.*11.*11 000 ₽/m)
    expect(rendered).to match(/13.*победа.*13 сент., 10:00.*15.*13 000 ₽/m)
    expect(rendered).to match(/17.*время.*17 сент., 10:00.*14.*512 000 ₽/m)
  end
end