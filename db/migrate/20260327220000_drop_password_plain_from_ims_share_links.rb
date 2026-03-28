class DropPasswordPlainFromImsShareLinks < ActiveRecord::Migration[8.1]
  def change
    remove_column :ims_share_links, :password_plain, :string
  end
end
