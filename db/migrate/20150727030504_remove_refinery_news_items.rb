class RemoveRefineryNewsItems < ActiveRecord::Migration
  def change
    drop_table :refinery_news_items
  end
end
