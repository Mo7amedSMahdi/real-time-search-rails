class AddDefaultToCount < ActiveRecord::Migration[7.1]
  def change
    change_column :search_terms, :count, :integer, default: 1
  end
end
