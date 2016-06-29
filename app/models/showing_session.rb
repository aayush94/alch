class ShowingSession < ActiveRecord::Base
  enum status: [:ongoing, :expired, :failed, :completed]

  validate :active_showing, on: :create, if: :student_session?
  validates_presence_of :showing, :node, :user
  validates_uniqueness_of :showing, :scope => :user,
                                    :message => "A session for this showing and user already exists"

  has_many :decisions

  belongs_to :showing
  belongs_to :node
  belongs_to :user

  before_save :decrease_attempts, if: :node_is_failure?
  before_save :set_status, if: :not_expired_student_session?

  def finished?
    not self.ongoing?
  end

  def game_over?
    self.showing.is_graded? and self.attempts_remaining <= 0
  end

  def victory?
    self.showing.is_graded? and self.node.is_goal? and self.user.student?
  end

  def decrease_attempts
    self.attempts_remaining -= 1
  end

  def not_expired_student_session?
    self.user.student? and not self.expired?
  end

  def num_failures
    failures = 0

    if showing.is_graded?
      failures = self.showing.max_attempts - self.attempts_remaining
    end

    failures
  end
  
  private
    def node_is_failure?
      self.showing.is_graded? and self.node.is_failure? and self.ongoing? and self.user.student?
    end

    def set_status
      if victory?
        self.status = ShowingSession.statuses[:completed]
      elsif game_over?
        self.status = ShowingSession.statuses[:failed]
      elsif self.showing.expired?
        self.status = ShowingSession.statuses[:expired]
      end
    end

    def active_showing
      unless self.showing.active?
        errors.add(:showing, "has expired.")
      end
    end

    def student_session?
      self.user.student?
    end
end
