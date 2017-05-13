class AddColumnPositionToCategory < ActiveRecord::Migration
  def change
  	add_column :categories, :position, :integer, after: :user_id
  end
end
