class SufiaMigrations < ActiveRecord::Migration
  def change

  # the bookmarks table
  change_column :bookmarks, :title, :binary

  # the mailboxer_receipts table
  add_column :mailboxer_receipts, :is_delivered, :boolean, default: false
  add_column :mailboxer_receipts, :delivery_method, :string
  add_column :mailboxer_receipts, :message_id, :string

  # the searches table
  change_column :searches, :query_params, :binary

  end
end
