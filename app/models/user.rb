class User < ActiveRecord::Base

	has_secure_password

	has_many :categories
	has_many :transactions

	validates_presence_of :username
	validates_presence_of :password
	validates_presence_of :email

	validates_uniqueness_of :username

end