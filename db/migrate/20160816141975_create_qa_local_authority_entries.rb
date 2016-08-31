class CreateQaLocalAuthorityEntries < ActiveRecord::Migration
  def change
    create_table :qa_local_authority_entries do |t|
      t.references :local_authority, foreign_key: { to_table: :qa_local_authorities }, index: true
      t.string :label
      t.string :uri

      t.timestamps null: false
    end
    add_index :qa_local_authority_entries, :uri, unique: true
  end
end