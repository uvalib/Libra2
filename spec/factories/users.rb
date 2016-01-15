require 'factory_girl'

FactoryGirl.define do

  factory :user do |f|
    f.email 'user3@virginia.edu'
    f.password 'passw0rd'
    f.password_confirmation 'passw0rd'
  end

  factory :another_user do |f|
    f.email 'user4@virginia.edu'
    f.password 'p@ssword'
    f.password_confirmation 'p@ssword'
  end

end

