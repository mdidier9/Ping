class Pinga < ActiveRecord::Base
	belongs_to :creator, class_name: "User"
	has_many :user_pingas
	has_many :users, through: :user_pingas
end
