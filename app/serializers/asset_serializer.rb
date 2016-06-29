class AssetSerializer < ActiveModel::Serializer
  attributes :id, :image, :thumbnail

  def thumbnail
    self.image.url(:thumb)
  end
end
