class CreateSearchterms < ActiveRecord::Migration[7.1]
  def change
    create_table :search_terms do |t|
      t.string :search_term
      t.string :user_ip
      t.integer :count

      t.timestamps
    end
  end
end
