class AddOrcidAuthToUsers < ActiveRecord::Migration
  def change
     add_column :users, :orcid_access_token, :string
     add_column :users, :orcid_refresh_token, :string
     add_column :users, :orcid_scope, :string
     add_column :users, :orcid_expires_at, :datetime
     add_column :users, :orcid_linked_at, :datetime
  end
end
