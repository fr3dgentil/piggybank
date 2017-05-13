class UserController < ApplicationController

	before_action :confirm_logged_in, :except => [:login, :new_user, :forgot_password, :about]
 	
 	#LOGIN CONTROLLER
 	def login

 		#If the user is already logged in, redirect him to the app index
 		if session[:user_id].present?
 			redirect_to(:controller => 'app', :action => 'index')
 		end

		if params[:user]

			if params[:user][:username].present?

				@user = User.new(params[:user].permit('username', 'password'))
	 			
				#If the user is found in the db
				if @user_db = User.where(:username => @user.username).first
					
					#If the password match
					if @user_db.authenticate(@user.password)
						session[:user_id] = @user_db.id
						session[:user_username] = @user_db.username
						redirect_to(:controller => 'app', :action => 'index')
					else
						flash.now[:error] = "The password doesn't match..."
					end
				else
					flash.now[:error] = "The username is not found..."
				end
			elsif params[:user][:username].empty?
				flash.now[:error] = "I think you forgot something..."
 			end
		end
	end

	#NEW_USER CONTROLLER
	def new_user
		if params[:new_user]
			@new_user = User.new(params[:new_user].permit('username', 'password', 'password_confirmation', 'email'))
			if @new_user.save
				session[:user_id] = @new_user.id
				session[:user_username] = @new_user.username
				redirect_to(:controller => 'app', :action => 'index')
				flash[:new_account] = true;
			else
				flash.now[:error] = @new_user.errors.full_messages
			end
		end
	end

	#OPTIONS CONTROLLER
	def options

		@user = User.find(session[:user_id])
	
	end

	#ALTER_EMAIL CONTROLLER
	def alter_email
		@user = User.find(session[:user_id])
		@email = @user.email #We dont want the current email to change if there is an error
		if params[:email]
			if @user.authenticate(params[:password])
				if @user.update(params.permit('email', 'password'))
					flash[:success] = "Your email has been successfully changed to " + params[:email] + "."
					redirect_to(:action => 'options', :date => params[:date], :to => params[:to], :view => params[:view])
				else
					flash.now[:error] = @user.errors.full_messages
				end
			else
				flash.now[:error] = "Wrong Password"
			end
		end
	end

	#ALTER_PASSWORD CONTROLLER
	def alter_password
		@user = User.find(session[:user_id])
		if params[:old_password]
			if !@user.authenticate(params[:old_password]) 
			#If it's the wrong password
				flash[:error] = "You entered the wrong password."
				redirect_to(:action => 'alter_password', :date => params[:date], :to => params[:to], :view => params[:view])
			else #Else it's the good password
				if !params[:new_password].present? || !params[:new_password_confirmation].present? 
					#if one of the new password is missing
					flash.now[:error] = "You need to fill all the inputs."
				else #else if all the inputs are filled
					@user.password = params[:new_password]
					@user.password_confirmation = params[:new_password_confirmation]
					if !@user.save #SAVE
					#if user.save didn't work
						flash.now[:error] = "The password confirmation didn't match."
					else #else if user.save succeeds
						flash[:success] = "Password successfully changed"
						redirect_to(:action => 'options', :date => params[:date], :to => params[:to], :view => params[:view])

					end
				end
			end
		end
	end

	#FORGOT_PASSWORD CONTROLLER
	def forgot_password
	end

	#LOGOUT CONTROLLER
	def logout
		if params[:logout] = true
			session[:user_id] = nil
			session[:user_username] = nil
			redirect_to(:action => 'login')
		end
	end

	#DELETE_ACCOUNT CONTROLLER
	def delete_account
		@user = User.find(session[:user_id])
		if params[:password]
			if @user.authenticate(params[:password])
				redirect_to(:action => 'delete_account_confirmation')
			else
				flash.now[:error] = 'Wrong Password'
			end
		end
	end

	#DELETE_ACCOUNT_CONFIRMATION CONTROLLER
	def delete_account_confirmation
		@user = User.find(session[:user_id])
		if params[:confirmation] == 'yes'
			@user.transactions.destroy_all
			@user.categories.destroy_all
			@user.destroy
			flash[:success] = "Your account has been deleted."
			redirect_to(:action => 'logout', :logout => true)
		end
	end

	private

 	#CONFIRM_LOGGED_IN CONTROLLER
	def confirm_logged_in
    	if session[:user_id].nil?
      		flash[:error] = 'Please log in.'
      		redirect_to(:controller => 'user', :action => 'login')
    	end
  	end
end