class User < ActiveRecord::Base
	attr_accessor :password
	#attr_accessible :nom, :email, :password, :password_confirmation

	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :nom, :presence => true,
					:length => { :maximum => 50 }
	validates :email, :presence => true,
					  :format => { :with => email_regex},
					  :uniqueness => true
	validates :password, :presence => true,
						 :confirmation => true,
						 :length => {:within => 6..40}
	before_save :encrypt_password

	def has_password?(sub_password)
		encrypted_password == encrypt(sub_password)
	end

	def self.authenticate(email, sub_password)
		user = find_by_email(email)
		return nit if user.nif?
		return user if user.has_password?(sub_password)
	end

	private

	def encrypt_password
		self.salt = make_salt if new_record?
		self.encrypted_password = encrypt(password)
	end

	def encrypt(string)
		secure_hash("#{salt}--#{string}")
	end

	def make_salt
		secure_hash("#{Time.now.utc}--#{password}")
	end

	def secure_hash(string)
		Digest::SHA2.hexdigest(string)
	end


end