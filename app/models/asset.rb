class Asset < ActiveRecord::Base
  has_attached_file :image, :default_style => :medium, :styles => { :medium => "500x500>", :thumb => '250x250#'}, :default_url => '/images/:style/missing.png'
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_size :image, :less_than => 3.megabytes
end
