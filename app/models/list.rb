class List < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :items
  validate :name_must_be_uri_encoded

  def name_must_be_uri_encoded
    unless name == URI.encode(name)
      errors.add(:name, "must be URI encodable")
    end
  end

  def last_item
    items.last if items.present?
  end

  def as_json(options={})
    super except: :id, methods: [:items, :last_item]
  end
end