class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name, unique: true, null: false
      t.string :slug, unique: true, null: false
      t.string :location, null: false
      t.integer :timezone, null: false
      t.timestamps

      # validate that the timezone is a valid timezone number ie: (035 for EST). (0-300)
      t.check_constraint 'timezone >= 0 AND timezone <= 300', name: 'valid_timezone'

      # validate that the slug is a valid slug
      #   * contains lowercase letters, numbers, underscores, and dashes
      #   * between 3 and 20 characters
      t.check_constraint "slug ~* '^[a-z0-9_-]{3,20}$'", name: 'valid_slug'
    end

    # Add unique index on slug
    add_index :organizations, :slug, unique: true
  end
end