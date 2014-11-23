class CreatePageLogs < ActiveRecord::Migration
  def change
    create_table :page_logs do |t|
      t.text :text
      t.timestamps
    end
  end
end
