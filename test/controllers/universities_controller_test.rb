require 'test_helper'

class UniversitiesControllerTest < ActionController::TestCase

  test 'should list in alphabetical order' do
    get :index

    data = [universities(:ubc), universities(:waterloo), 
            universities(:sfu), universities(:mit)]

    data.sort_by! { |h| h[:name] }
    expected = serialize(data, UniversitySerializer)

    assert_equal expected, response.body
  end
end
