require 'rails_helper'

# https://devhints.io/capybara
# https://gist.github.com/tomas-stefano/6652111
# https://gist.github.com/them0nk/2166525

RSpec.feature 'User watches other account', type: :feature do
  let(:user) { FactoryBot.create(:user, name: 'Tomash') }
  let(:games) do
    [
      FactoryBot.create(:game, id: 3, created_at: Time.parse('2017.09.03, 10:00'), current_level: 3, prize: 3_000),
      FactoryBot.create(:game, id: 7, created_at: Time.parse('2019.09.07, 10:00'), finished_at: Time.parse('2019.09.07, 10:30'), current_level: 7, prize: 7_000),
      FactoryBot.create(:game, id: 11, created_at: Time.parse('2023.09.11, 10:00'), finished_at: Time.parse('2023.09.11, 10:30'), is_failed: true, current_level: 11, prize: 11_000),
      FactoryBot.create(:game, id: 13, created_at: Time.parse('2027.09.13, 10:00'), finished_at: Time.parse('2027.09.13, 10:30'), current_level: 15, prize: 13_000),
      FactoryBot.create(:game, id: 17, created_at: Time.parse('2029.09.17, 10:00'), finished_at: Time.parse('2029.09.17, 10:45'), is_failed: true, current_level: 14, prize: 512_000)
    ]
  end
  let!(:other_user) { FactoryBot.create(:user, id: 7, name: 'Cuurjol', games: games) }

  before(:each) do
    login_as(user)
  end

  scenario 'successfully' do
    visit('/')
    expect(page).to have_content('Cuurjol')

    click_link('Cuurjol')
    expect(page).to have_current_path('/users/7')
    expect(page).to have_no_content('Сменить имя и пароль')

    expect(page).to have_content(/3.*в процессе.*03 сент., 10:00.*3.*3 000 ₽/m)
    expect(page).to have_content(/7.*деньги.*07 сент., 10:00.*7.*7 000 ₽/m)
    expect(page).to have_content(/11.*проигрыш.*11 сент., 10:00.*11.*11 000 ₽/m)
    expect(page).to have_content(/13.*победа.*13 сент., 10:00.*15.*13 000 ₽/m)
    expect(page).to have_content(/17.*время.*17 сент., 10:00.*14.*512 000 ₽/m)
  end
end