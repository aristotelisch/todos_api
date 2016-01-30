require 'rails_helper'

describe List do
  describe 'validations' do
    it "is only valid if the name value is URI encodable" do
      list = List.create name: 'foo bar'
      expect(list).not_to be_valid
    end

    it "is only valid if the list name is unique" do
      List.create name: 'non_unique_name'

      list = List.create name: 'non_unique_name'
      expect(list).not_to be_valid
    end
  end

  describe '#last_item' do
    let(:list) { create(:list) }

    it 'returns the last associated item' do
      item1 = list.items.create description: 'test 1', completed: false
      item2 = list.items.create description: 'test 2', completed: false

      expect(list.last_item).to eq item2
    end

    it 'returns nil when there are not available items' do
      expect(list.last_item).to be_nil
    end
  end
end