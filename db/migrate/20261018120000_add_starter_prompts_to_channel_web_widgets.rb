class AddStarterPromptsToChannelWebWidgets < ActiveRecord::Migration[7.1]
  def change
    add_column :channel_web_widgets, :starter_prompts, :jsonb, default: [], null: false
  end
end
