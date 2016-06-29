class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :active

  def attributes
    data = super
    data[:showings] = reportable_showings
    data[:access_code] = object.access_code if abilities.can? :write, object
    data
  end

  private
    def abilities
      Ability.new(scope.current_user)
    end

    def reportable_showings
      reportable_showings = object.showings.find_all { |showing| showing.active? or showing.expired? }
      reportable_showings.map { |showing| {:id => showing.id, :display_name => showing.display_name ||= showing.scenario.name, :is_graded => showing.is_graded}  }
    end
end
