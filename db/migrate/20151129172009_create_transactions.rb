class CreateTransactions < ActiveRecord::Migration
  def change

    create_table :categories do |t|
      t.string :name
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
    
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.decimal :amount, precision: 8, scale: 2
      t.references :category, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
