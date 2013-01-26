class CreateBananas < ActiveRecord::Migration
  def change
    create_table :bananas do |t|
      t.integer :size
      t.integer :weight
      t.string :color

      t.timestamps
    end
  end
end
