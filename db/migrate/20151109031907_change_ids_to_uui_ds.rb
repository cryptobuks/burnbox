class ChangeIdsToUuiDs < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.remove :id
      t.uuid :id, primary_key: true, default: "uuid_generate_v4()"
    end
  end
end
