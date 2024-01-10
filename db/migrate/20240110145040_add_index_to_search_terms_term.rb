class AddIndexToSearchTermsTerm < ActiveRecord::Migration[7.1]
  def change
    add_index :search_terms, :search_term
  end
end
