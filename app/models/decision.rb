class Decision < ActiveRecord::Base
  attr_accessor :width

  enum result: [:failure, :neutral, :success]

  validates_presence_of :showing_session_id, :from_node, :to_node

  validates :justification, presence: true, 
  							length: { minimum: 5 }, 
  							if: :justification_required?

  validate :connected

  belongs_to :showing_session
  belongs_to :from_node, class_name: "Node"
  belongs_to :to_node, class_name: "Node"

  before_save :set_result

  def connected
  	if self.from_node.choices.where(to_node_id: self.to_node).empty?
  		errors[:base] << "Not a valid decision from this node"
  	end
  end

  def justification_required?
  	self.from_node.requires_justification?
  end

 
  private
    def set_result
      if to_node.is_goal?
        self.result = Decision.results[:success]
      elsif to_node.is_failure?
        self.result = Decision.results[:failure]
      else
        self.result = Decision.results[:neutral]
      end
    end
end
