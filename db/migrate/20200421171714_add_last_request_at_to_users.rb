class AddLastRequestAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_request_at, :datetime
    add_column :users, :logged_in, :boolean, default: false
  end
end
