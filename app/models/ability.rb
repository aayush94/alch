class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    ##########################################
    # EVERYONE
    can :enroll, Course
    can :index, Course do |course|
      enrolled?(course, user)
    end

    can :read, Showing do |showing|
      enrolled?(showing.course, user)
    end

    can :read, ShowingSession do |show_session|
      show_session.user == user
    end

    ##########################################
    # STUDENT
    if user.role? :student

      # COURSES
      can :read, Course do |course| 
        enrolled?(course, user)
      end

      can :create, ShowingSession do |show_session|
        enrolled?(show_session.showing.course, user)
      end
    end    

    ##########################################
    # INSTRUCTOR
    if user.role? :instructor
      # ROLES
      can :elevate_to_instructor, User

      # COURSES
      can :create, Course
      can [:read, :write, :report], Course do |course|
        enrolled?(course, user)
      end

	    # SCENARIOS
      can [:create, :index], Scenario
      can [:copy, :read, :update], Scenario do |scenario|
        same_university?(scenario, user)
      end

      # SHOWINGS
      can [:create, :update, :report], Showing do |showing|
        enrolled?(showing.course, user)
      end

      # NODES
      can [:create, :write, :destroy], Node

      # CHOICES
      can [:create, :write, :destroy], Choice

      # ASSETS
      can [:create], Asset
    end

    ##########################################
    # ADMIN
    if user.role? :admin
      can :manage, :all
    end

  end

  private
    def enrolled?(course, user) 
      course.users.include? user
    end

    def same_university?(scenario, user)
      scenario.university == user.university
    end

end
