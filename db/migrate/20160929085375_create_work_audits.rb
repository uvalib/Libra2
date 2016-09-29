class CreateWorkAudits < ActiveRecord::Migration

  def up
    create_table :work_audits do |t|
      t.string :work_id, null: false
      t.string :user_id, null: false
      t.string :what, null: false

      t.timestamps null: false
    end
    add_index :work_audits, :work_id
    add_index :work_audits, :user_id
    add_index :work_audits, :created_at
  end

  def down
    drop_table :work_audits
  end
end
