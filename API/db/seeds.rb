if Rails.env.development?
    load 'db/seeds/development.rb'
elsif Rails.env.production?
    load 'db/seeds/production.rb'
end