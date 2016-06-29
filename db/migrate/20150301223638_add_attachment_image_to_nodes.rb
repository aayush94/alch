class AddAttachmentImageToNodes < ActiveRecord::Migration
  def self.up
    change_table :nodes do |t|

      t.attachment :image

    end
  end

  def self.down

    remove_attachment :nodes, :image

  end
end
