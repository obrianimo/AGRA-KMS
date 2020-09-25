class CreatePublicUsageStats < ActiveRecord::Migration[5.1]
  def change
    create_table :public_usage_stats do |t|
      t.string   :file_id, :null => false
      t.text     :title
      t.integer  :downloads
      t.integer  :views
      t.datetime :created_at
      t.datetime :last_viewed_at
      t.datetime :last_downloaded_at
    end
  end
end
