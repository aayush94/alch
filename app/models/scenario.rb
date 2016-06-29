class Scenario < ActiveRecord::Base
  validates :name, 
    presence: true, 
    uniqueness: { :scope => :university, :case_sensitive => false },
    length: { in: 4..60 }

  validates_presence_of :university, on: :create

  has_many :nodes
  has_many :showings, -> { visible }
  has_many :courses, :through => :showings

  belongs_to :university

  attr_accessor :warnings

  amoeba do
    enable
    include_association [:nodes]
  end

  # These queries are expensive. TODO: Cache
  def complete_choices
    node_ids = self.nodes.map { |node| node.id }
    Choice.where("node_id IN (?) AND to_node_id IS NOT NULL", node_ids)
  end

  def complete_and_orphan_nodes
    complete_ids = Set.new
    complete_choices.each { |c| complete_ids << c.node_id << c.to_node_id }
    self.nodes.partition { |n| complete_ids.include? n.id }
  end

  def root_node
    Node.find(self.root_node_id)
  end

  def no_goal_nodes?
    self.nodes.none? { |node| node.is_goal }
  end

  def unconnected_nodes?
    orphan_nodes = self.complete_and_orphan_nodes.last
    orphan_nodes.any?
  end

  def incomplete_choices?
    nodes = self.nodes
    nodes.any? { |node| node.choices.any? { |choice| choice.to_node_id.nil? } } # TODO: Performance analysis
  end

  def regular_leaf_nodes?
    nodes = self.nodes
    nodes.any? { |node| node.leaf? and node.regular? }
  end

  def unlabeled_choices?
    nodes = self.nodes
    nodes.any? { |node| node.choices.any? { |choice| choice.text.blank? } }
  end
end
