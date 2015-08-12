class History < ActiveRecord::Base
  belongs_to :song
  belongs_to :user
  attr_accessible :user, :song
end
