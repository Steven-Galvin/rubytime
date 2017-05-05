Sequel.extension :migration

Sequel.migration do
  up do
    create_table(:projects) do
      primary_key :id
      String :name, null: false
      String :description, null: false
      Time :created, null: false
      Time :modified
    end
  end

  down do
    drop_table(:projects)
  end
end
