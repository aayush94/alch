class CourseReportSerializer < ActiveModel::Serializer
  attributes :id, :students, :title

  def attributes
    data = super
    data[:report] = serialization_options[:report]
    data[:students] = serialization_options[:students]
    data
  end
end
