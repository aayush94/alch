class Showing < ActiveRecord::Base
  scope :visible, -> { where(hidden: false) }

  validates_presence_of :course_id, :scenario_id, :start_time, :end_time

  validate :validate_scenario, on: :create
  validate :validate_dates_on_update, on: :update
  validate :validate_dates_on_create, on: :create
  validates :max_attempts,
            :allow_nil => false,
            :numericality => {:greater_than => 0, :less_than_or_equal_to => 1000},
            :unless => :practice?

  has_many :sessions, class_name: "ShowingSession"
  has_many :decisions, through: :sessions

  belongs_to :scenario
  belongs_to :course

  ##
  # Calculates how common a choice was for each node based
  # on the decisions made for this showing.
  #
  # @return [Choice] where choice.width = num_times choice taken
  #                        choice.label = % chosen over other choices at node
  def choices_with_stats
    # group by decisions taken [ { [from_node, to_node] : occurences } ..]
    dec_groups = self.decisions.group_by { |d| [d.from_node_id, d.to_node_id] }
    dec_groups_with_counts = dec_groups.keys.sort.map { |k| { k => dec_groups[k].length } }

    # group by nodes visited [ { node_id : occurences } ..]
    node_groups = self.decisions.group_by { |d| d.from_node_id }
    node_group_with_counts = node_groups.keys.sort.map { |k| { k => node_groups[k].length } }

    # increase edge width and calc % if choice was visited
    self.scenario.complete_choices.map { |choice|
      num_chosen_pair = dec_groups_with_counts.find { |dec_group|
        dec_group.has_key? [choice.node_id, choice.to_node_id]
      }

      if num_chosen_pair.nil?
        # no decisions made for this choice
        choice.width = 1
        choice.label = "0%"
        choice
      else
        # at least 1 decision was mode for this choice
        num_chosen = num_chosen_pair[num_chosen_pair.keys[0]]
        total_node_visits_pair = node_group_with_counts.find { |node_group|
          node_group.has_key? choice.node_id
        }

        total_node_visits = total_node_visits_pair[total_node_visits_pair.keys[0]]
        percent_chosen = ((num_chosen * 1.0 / total_node_visits) * 100).to_i

        choice.width = num_chosen
        choice.label = "#{percent_chosen}%"
        choice
      end
    }
  end

  ##
  # Return the unique set of decisions where the decision returned
  # is the last one made and contains an account for the total
  # amount of times it was made.
  def decisions_with_stats_for(student_id)
    decisions = decisions_for(student_id)
    grouped = decisions.group_by { |d| [d.from_node_id, d.to_node_id] }
    groups_with_counts = grouped.keys.sort.map { |k| { k => grouped[k].length } }
    uniq_decisions = grouped.keys.map { |k| grouped[k].last }
    uniq_decisions.map { |d|
      count_pair = groups_with_counts.find { |group| group.has_key? [d.from_node_id, d.to_node_id] }
      d.width = count_pair[count_pair.keys[0]]
      d
    }
  end

  def decisions_for(student_ids)
    Decision.joins(:showing_session).where("showing_sessions.user_id in (?)", student_ids).order(:created_at)
  end

  def avg_student_failures
    completed_and_failed_sessions = student_sessions.find_all{ |session| session.completed? or session.failed? }

    avg_failures(completed_and_failed_sessions)
  end

  def avg_failures_for(student_ids)
    avg_failures(sessions_for(student_ids))
  end

  def avg_failures(sessions)
    fail_sum = sessions.inject(0) { |sum, s|
      sum + s.num_failures
    }

    if sessions.any?
      fail_sum / sessions.count
    else
      0
    end
  end

  def sessions_for(student_ids)
    self.sessions.where("user_id in (?)", student_ids)
  end

  def student_sessions
    self.sessions.joins(:user).where(users: { role: User.roles[:student] })
  end

  def expired?
    DateTime.now.to_date > self.end_time
  end

  def active?
    not expired? and started? and not hidden?
  end

  def started?
    self.start_time <= DateTime.now
  end

  def practice?
    not self.is_graded?
  end

  def student_sessions_by_type
    self.student_sessions.group_by { |s| s.status }
  end

  def get_average(sid = nil)
    if sid.nil?
      completed_sessions = self.student_sessions.find_all {
          |showing_session| showing_session.finished?
      }
    else
      completed_sessions = self.student_sessions.find_all {
          |showing_session| sid == showing_session.user_id and showing_session.finished?
      }
    end

    if completed_sessions.empty?
      return -1
    end

    total_score = 0

    completed_sessions.each do |showing_session|
      total_score += showing_session.attempts_remaining
    end

    (total_score * 1.0) / (self.max_attempts * completed_sessions.length)
  end

  def validate_scenario
    scenario = self.scenario

    if scenario.unconnected_nodes?
      errors.add(:scenario, "cannot have unconnected nodes.")
    end

    if scenario.incomplete_choices?
      errors.add(:scenario, "must connect all choices to another node or be removed.")
    end

    if scenario.no_goal_nodes?
      errors.add(:scenario, "must have at least one goal node.")
    end

    if scenario.regular_leaf_nodes?
      errors.add(:scenario, "cannot have non goal or failure leaf nodes.")
    end

    if scenario.unlabeled_choices?
      errors.add(:scenario, "must have text for all its choices.")
    end
  end

  def validate_dates_on_create
    validate_start_date_on_create
    validate_end_date
  end

  def validate_start_date_on_create
    validate_start_time_before_end_time

    if self.start_time < DateTime.now.to_date
      errors.add("start date", "cannot be before the current date.")
    end
  end

  def validate_start_time_before_end_time
    if self.start_time > self.end_time
      errors.add("start date", "cannot be later than the end date")
    end
  end

  def validate_end_date
    if self.end_time_changed?
      if self.end_time < DateTime.now.to_date
        errors.add("end date", "cannot be in the past")
      end

      if self.end_time < self.start_time
        errors.add("end date", "cannot be before than the start date")
      end
    end
  end

  def validate_dates_on_update
    validate_start_date_on_update
    validate_end_date
  end

  def validate_start_date_on_update
    if self.start_time_changed?
      validate_start_time_before_end_time

      if self.start_time < DateTime.now.to_date
        errors.add("start date", "cannot be before today")
      end

      if self.start_time_was <= DateTime.now and self.start_time > self.start_time_was
        errors.add("start date", "cannot be updated after the scenario has started")
      end
    end
  end
end
