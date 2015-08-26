class RemoveRefineryNewsItemTranslations < ActiveRecord::Migration
  def change
    drop_table :refinery_news_item_translations
  end
end
