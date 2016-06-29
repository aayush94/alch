class ShowingSessionClosedSerializer < ActiveModel::Serializer
  attributes :id, :status, :attempts_remaining
  has_one :showing
end
