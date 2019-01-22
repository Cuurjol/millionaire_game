require 'rails_helper'

RSpec.describe Question, type: :model do
  context 'validations check' do
    # Создание теста к какому-то полю на проверку свойства uniqueness невозможно без явного создания
    # объекта тестируемой модели. Если явно не создавать объект, то тест на validate_uniqueness_of падает.
    #
    # Существует два способа, как можно сделать такой тест:
    # 1. Создание явно объекта тестируемой модели со всеми его полями:
    # subject { Question.new(text: 'some', level: 0, answer1: '1', answer2: '1', answer3: '1', answer4: '1') }
    #
    # 2. Если исполуется gem FactoryBot для тестирования и существует factory тестируемой модели, то:
    # subject { FactoryBot.create(:question) }
    #
    # Ссылка на метод validate_uniqueness_of:
    # http://matchers.shoulda.io/docs/v4.0.0.rc1/Shoulda/Matchers/ActiveRecord.html#validate_uniqueness_of-instance_method

    subject { FactoryBot.create(:question) }

    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:level) }
    it { should validate_inclusion_of(:level).in_range(0..14) }
    it { should allow_value(14).for(:level) }
    it { should_not allow_value(15).for(:level) }
    it { should validate_uniqueness_of(:text) }
  end
end
