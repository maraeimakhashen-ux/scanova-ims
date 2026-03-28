class CreateImsPrepRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_prep_requests do |t|
      t.references :ims_case, null: false, foreign_key: true
      t.integer :block_id
      t.string :request_type, null: false
      t.string :marker_or_stain
      t.integer :levels
      t.text :notes
      t.string :status, null: false, default: "pending"
      t.string :requested_by
      t.datetime :completed_at
      t.timestamps
    end

    add_index :ims_prep_requests, :status
  end
end
