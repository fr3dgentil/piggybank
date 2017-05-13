class AppController < ApplicationController
  
  before_action :confirm_logged_in

  #INDEX CONTROLLER
  def index 

    #valid_date == true or false ('date' param)
    if params[:date]
      if params[:date].length == 4
        params[:date][0,4].to_i.to_s.length == 4 ? valid_date = true : valid_date = false
      elsif params[:date].length == 7
        params[:date][4,1] == '-' && params[:date][5,2].to_i < 13 ? valid_date = true : valid_date = false  
      elsif params[:date].length == 10
        params[:date][4,1] == '-' && params[:date][5,2].to_i < 13 && params[:date][7,1] == '-' && params[:date][8,2].to_i < 32 ? valid_date = true : valid_date = false
      elsif params[:date].length == 5 || params[:date].length == 6 || params[:date].length == 8 || params[:date].length == 9 || params[:date].length > 10
        valid_date = false
      end
    end

    #valid_date == true or false ('to' param)
    if params[:to]
      if params[:to].length == 4
        params[:to][0,4].to_i.to_s.length == 4 ? valid_date = true : @title = valid_date = false
      elsif params[:to].length == 7
        params[:to][4,1] == '-' && params[:to][5,2].to_i < 13 ? valid_date = true : valid_date = false
      elsif params[:to].length == 10
        params[:to][4,1] == '-' && params[:to][5,2].to_i < 13 && params[:to][7,1] == '-' && params[:to][8,2].to_i < 32 ? valid_date = true : valid_date = false
      elsif params[:to].length == 5 || params[:to].length == 6 || params[:to].length == 8 || params[:to].length == 9 || params[:to].length > 10
        valid_date = false
      end
    end

    @title = 'Invalid Date' if valid_date == false

    #Variables
    @user_id = session[:user_id]
    @big_total_amount = 0
    @categories = Category.where(:user_id => @user_id).order(:position)
    @today = Time.new
    time = Time.new(params[:date][0, 4], params[:date][5, 2], params[:date][8, 2]) if params[:date].present? && valid_date == true
    time = @today if params[:date].nil?
    time_to = Time.new(params[:to][0, 4], params[:to][5, 2], params[:to][8, 2]) if params[:to].present? && valid_date == true
  
    #DB Requests
    if params[:date] && params[:to]
      @transactions = Transaction.where(user_id: @user_id).where("date >= :params_date AND date <= :params_to", 
      {:params_date => "#{params[:date]}%", :params_to => "#{params[:to]}%"}).order(:date)
    elsif params[:date]
      @transactions = Transaction.where(user_id: @user_id).where("date LIKE :params_date", 
      {:params_date => "#{params[:date]}%"}).order(:date)
    else
      #We add a 0 to the month if it's less than 10 (01 instead of 1)
      time_month_string = time.month.to_s
      time_month_string = '0' + time_month_string if time_month_string.length == 1

      @transactions = Transaction.where(user_id: @user_id).where("date LIKE :params_date", 
      {:params_date => "#{time.year.to_s+'-'+time_month_string}%"}).order(:date)
    end

    #3. Transactions Hashes
    @transactions_hash = {}

    #If it's the view 2
    if params[:view] == '2'
      @transactions_hash['Income'] = []
      @transactions_hash['Outcome'] = []
      @transactions.each do |transaction|
        transaction.amount.to_s[0,1] == '-' ? 
        @transactions_hash['Outcome'] << transaction : 
        @transactions_hash['Income'] << transaction
      end

    #If it's the view 3
    elsif params[:view] == '3' 
      @transactions_hash['All'] = []
      @transactions.each do |transaction|
          @transactions_hash['All'] << transaction
      end

    else #It's the view 1 if it's not the view 2 or 3
      params[:view] = '1' if params[:view].present?
      @categories.each do |category|
        @transactions_hash[category.id] = []
      end
      @transactions_hash[nil] = []
      @transactions.each do |transaction|
        @transactions_hash[transaction.category_id] << transaction
      end
    end

    @not_empty_categories_count = 0
    @transactions_hash.each do |category, transactions|
      if transactions.count > 0
        @not_empty_categories_count = @not_empty_categories_count + 1
      end
    end


    #4. Dates Titles with Last & Next Links
    if params[:date].nil?
      @last_date = @today.last_month.strftime("%Y-%m")
      @title = @today.strftime("%B, %Y")
      @next_date = @today.next_month.strftime("%Y-%m")

    elsif params[:date].present?

      if valid_date == true
        if params[:to].nil? 

          if params[:date].length == 7 #month year
            @last_date = time.last_month.strftime("%Y-%m")
            @title = time.strftime("%B, %Y")
            @next_date = time.next_month.strftime("%Y-%m")

          elsif params[:date].length == 10 #day month year
            @last_date = time.yesterday.strftime("%Y-%m-%d")
            @title = time.strftime("%a, %b %e, %Y")
            @next_date = time.tomorrow.strftime("%Y-%m-%d")

          elsif params[:date].length == 4 #year
            @last_date = time.last_year.strftime("%Y")
            @title = time.strftime("%Y")
            @next_date = time.next_year.strftime("%Y")
          end
    
          #If it's a date with Param 'To' (for the weeks and custom dates)
          elsif params[:to].present? 

            #We create the Last & Next Links
            if time.monday? && time.end_of_week.strftime("%Y-%m-%d") == time_to.strftime("%Y-%m-%d") 
              @last_date = time.last_week.strftime("%Y-%m-%d")
              @last_to = time.last_week.end_of_week.strftime("%Y-%m-%d")
              @next_date = time.next_week.strftime("%Y-%m-%d")
              @next_to = time.next_week.end_of_week.strftime("%Y-%m-%d")
            end
        
            #We create the title
            #If it's this week, last week or next week
            if params[:date] == @today.beginning_of_week.strftime("%Y-%m-%d") && params[:to] == @today.end_of_week.strftime("%Y-%m-%d")
              @title = 'This Week'
            elsif params[:date] == @today.last_week.strftime("%Y-%m-%d") && params[:to] == @today.last_week.end_of_week.strftime("%Y-%m-%d")
              @title = 'Last Week'
            elsif params[:date] == @today.next_week.strftime("%Y-%m-%d") && params[:to] == @today.next_week.end_of_week.strftime("%Y-%m-%d")
              @title = 'Next Week'

            #If it's a long title, we make it more clear (ex. 10 dec 2010 to 20 dec 2015 becomes: 10 to 20 december 2015)
            elsif params[:date].length == 10 && params[:to].length == 10
              
              if time.month == time_to.month && time.year == time_to.year
                @title = time.strftime("%b %e") + ' to ' + time_to.strftime("%e, %Y")
              elsif time.month != time_to.month && time.year == time_to.year
                @title = time.strftime("%b %e") + ' to ' + time_to.strftime("%b %e, %Y")
              else @title = time.strftime("%b %e, %Y") + ' to ' + time_to.strftime("%b %e, %Y")
            
            end
          
          else #Else we create a simple title
            date_strftime_value = "%e %b %Y" if params[:date].length == 10
            date_strftime_value = "%b %Y" if params[:date].length == 7
            date_strftime_value = "%Y" if params[:date].length == 4
            to_strftime_value = "%e %b %Y" if params[:to].length == 10
            to_strftime_value = "%b %Y" if params[:to].length == 7
            to_strftime_value = "%Y" if params[:to].length == 4
            @title = time.strftime(date_strftime_value) + ' to ' + time_to.strftime(to_strftime_value) 
          end
        end
      end
    end
  end

  #TRANSACTION_FORM CONTROLLER
  def transaction_form 
    @user_id = session[:user_id]
    @categories = Category.where(:user_id => @user_id).order('position')
    
    if params[:id]
      @transaction = Transaction.find(params[:id])
    else
      #We ajust the param date if needed
      if params[:date].present?
        param_date = params[:date] #If we change to real params, its gonna be affected on the next page too.
        if params[:date].length == 4
        #if its not the current year, dont put the current month and day
          param_date = param_date + '-01-01' if param_date != Time.now.year.to_s
        elsif params[:date].length == 7
          #We parse the year
          time_year = param_date[0,4]
          #We parse the month and we add a 0 to the string if needed
          param_date[5,2].to_i < 10 ? time_month = '0' + param_date[6,1] : time_month = param_date[5,2]
          #We create the day
          time_year + '-' + time_month == Time.now.to_s[0,7] ? time_day = Time.now.day.to_s : time_day = '1'
          #We add a 0 to the day if needed
          time_day = '0' + time_day if time_day.to_i < 10
          #We create the param_date
          param_date = time_year + '-' + time_month + '-' + time_day
        end
      end
      @transaction = Transaction.new(:category_id => params[:category], :date => param_date)
    end
  end

  #SAVE TRANSACTION CONTROLLER
  def save_transaction 
    params[:transaction][:amount] = 0 if params[:transaction][:amount].empty?
    transaction = params[:transaction].permit('date', 'description', 'category_id', 'amount', 'user_id')
    if params[:transaction][:transaction_id] == '' #New
      Transaction.create(transaction)
      #flash[:success] = params[:transaction][:description] + ' Saved!'
    else #Update
      Transaction.find(params[:transaction][:transaction_id]).update(transaction)
      #flash[:success] = params[:transaction][:description] + ' Updated!'
    end
    redirect_to(:action => 'index', :date => params[:date], :to => params[:to], :view => params[:view])
  end

  #DELETE TRANSACTION CONTROLLER
  def delete_transaction
    if params[:id]
      @transaction = Transaction.find(params[:id])
      if params[:delete]
        @transaction.destroy
        #flash[:success] = @transaction.description + ' deleted!'
        redirect_to(:action => 'index', :date => params[:date], :to => params[:to], :view => params[:view])
      end
   end
  end

  #CATEGORIES CONTROLLER
  def categories
    @categories = Category.where(:user => User.find(session[:user_id])).order('position')
  end

  #MOVE CATEGORY CONTROLLER
  def move_category

    @categories = Category.where(:user => User.find(session[:user_id])).order('position')

    #Move category DOWN
    if params[:move_down]
      #If it's the last position we want to put it first and vice versa
      if @categories.count == params[:move_down].to_i 
        category1 = @categories.where(:position => params[:move_down].to_i).first
        category2 = @categories.where(:position => 1).first
        category1.update(:position => 1)
        category2 .update(:position => params[:move_down].to_i)
      else #If we want to move x to y, we move x to y and y to x
        category1 = @categories.where(:position => params[:move_down].to_i + 1).first
        category2 = @categories.where(:position => params[:move_down]).first
        category1.update(:position => params[:move_down].to_i)
        category2 .update(:position => params[:move_down].to_i + 1)
      end
    #Move category UP
    elsif params[:move_up]
      #If it's the first position we want to put it last and vice versa
      if params[:move_up].to_i == 1 
        category1 = @categories.where(:position => @categories.count).first
        category2 = @categories.where(:position => 1).first
        category1.update(:position => 1)
        category2 .update(:position => @categories.count)
      else #If we want to move x to y, we move x to y and y to x
        category1 = @categories.where(:position => params[:move_up].to_i - 1).first
        category2 = @categories.where(:position => params[:move_up]).first
        category1.update(:position => params[:move_up].to_i)
        category2 .update(:position => params[:move_up].to_i - 1)
      end
    end

    redirect_to(:action => 'categories', :id => params[:id], :back => params[:back], :date => params[:date], :to => params[:to], :view => params[:view])

  end

  #SAVE CATEGORY CONTROLLER
  def save_category

    params[:user_id] = session[:user_id]
    
    #If its a new category
    if params[:id] == ''
      
      params[:name] = params[:new] #Because we wanted a label just for this input
      params[:position] = Category.where(:user => User.find(session[:user_id])).count + 1

      Category.create(params.permit('name', 'user_id', 'position'))
      flash[:success] = "Category added"

    #Else it's a modification
    else
      Category.find(params[:id]).update(params.permit('name', 'user_id', 'position'))
      flash[:success] = "Category updated"
    end
    redirect_to(:action => 'categories', :back => params[:back], :date => params[:date], :to => params[:to], :view => params[:view])  
  end

  #DELETE CATEGORY CONTROLLER
  def delete_category

    @user_id = session[:user_id]
    @category = Category.find(params[:id])
    @categories = Category.where(:user_id => @user_id)
    @transactions = Transaction.where(:user_id => @user_id)
    @transactions_count = @category.transactions.count

    if @transactions_count == 0


      #Delete the category
      @category.destroy
      flash[:success] = 'The category has been deleted.'
      redirect_to(:action => 'categories', :back => params[:back], :date => params[:date], :to => params[:to], :view => params[:view])

    elsif @transactions_count > 0

      #Destroy the category and the transfer the transactions
      if params[:transfer_transactions] == 'yes'
        @transactions.where(:category_id => params[:id]).update_all(params.permit('category_id'))
        @category.destroy
        flash[:success] = 'The Category has been deleted and the transactions have been moved.'
        redirect_to(:action => 'index', :date => params[:date], :to => params[:to], :view => params[:view])

      #Destroy the category and delete the transactions
      elsif params[:transfer_transactions] == 'no'
        @transactions.where(:category_id => params[:id]).destroy_all
        @category.destroy
        flash[:success] = 'The category and his transactions have been deleted.'
        redirect_to(:action => 'index', :date => params[:date], :to => params[:to], :view => params[:view])
      end
    end

    #We update the positions of the categories that need it 
    #(Because, for the category page, we can't jump a number (ex 1-2-4) for the up & down buttons to work.) 
    categories_to_update_position = @categories.where("position > ?", @category.position.to_i)
    categories_to_update_position.each do |c|
      c.update('position' => c.position.to_i - 1)
    end
  end
    
  private

  def confirm_logged_in
    if session[:user_id].nil?
      flash[:error] = 'Please log in.'
      redirect_to(:controller => 'user', :action => 'login')
    end
  end
end