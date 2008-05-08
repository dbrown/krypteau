class KrypteaukeyMigration < ActiveRecord::Migration
  def self.up
    create_table :krypteaukeys do |t|
      t.string      :name 
      t.string      :text 
      t.string      :iv 
      t.string      :algorithm 
      t.integer     :user_id 

      t.timestamps
    end 
  end

  def self.down
    drop_table :krypteaukeys
  end
end
