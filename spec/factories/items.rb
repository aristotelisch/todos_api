FactoryGirl.define do
  factory :uncompleted_item do
  	description 'item 1'	
  	completed false
  	list
  end

  factory :completed_item do
  	description 'item 2'	
  	completed true
  	list
  end
end
