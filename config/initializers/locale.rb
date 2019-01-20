# где библиотека I18n должна искать наши переводы
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]

# Белый список локалей, доступных приложению
I18n.available_locales = [:en, :ru]

# устанавливаем локаль по умолчанию на что-либо другое, чем :en
I18n.default_locale = :ru