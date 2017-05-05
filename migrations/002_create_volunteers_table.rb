Sequel.extension :migration

Sequel.migration do
  up do
    create_table(:volunteers) do
      primary_key :id
      foreign_key :project_id, :projects
      String :name, null: false
      Time :created, null: false
      Time :modified
    end
  end

  down do
    drop_table(:volunteers)
  end
end
