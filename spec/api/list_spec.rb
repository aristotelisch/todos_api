require "rails_helper"


describe Lists::API do
  before do
    @headers = {
      "Authorization" => "Basic #{Base64::encode64('beta:beta')}"
    }
  end
  let(:list) {List.create name: 'list_name'}
  let(:item) {list.items.create description: 'item_description', completed: false}

  describe 'GET /lists' do
    it 'shows all available lists' do
      lists = List.includes(:items)
      get '/lists', {}, @headers
      expect(response.body).to eq lists.to_json
    end
  end

  describe 'POST /lists' do
    it "creates a new list" do
      expect { post '/lists', {name: 'list-name'}, @headers }.to change{ List.count }.by 1
    end

    describe 'if a list is invalid' do
      before(:each) do
        List.create name: 'non-unique-name'
      end

      it "doesn't create a new list" do
        expect { post '/lists', {name: 'non-unique-name'}, @headers }.to change{ List.count }.by 0
      end

      it "returns a 422 status code" do
        post '/lists', {name: 'non-unique-name'}, @headers
        expect(response.status).to eq 422
      end
    end
  end

  describe 'GET /lists/:name' do
    it "returns a json representation of the list and its associated items" do
      list.items.create description: 'some description', completed: false
      get "/lists/#{list.name}", {}, @headers
      expect(response.body).to eq list.to_json
    end

    it "returns a 422 if the list could not be found" do
       get "/lists/bad_name", {}, @headers
       expect(response.status).to eq 422
    end
  end

  describe 'POST /lists/:name/item' do
    it 'creates a new item for the associated list' do
      expect {
        post "/lists/#{list.name}/items", {description: 'some description', completed: false }, @headers
      }.to change{ Item.count }.by 1
    end

    it 'returns a json representation of the item' do
      post "/lists/#{list.name}/items", {description: 'some description', completed: false }, @headers
      expect(response.body).to eq Item.last.to_json
    end

    it "returns a 422 if the list could not be found" do
      post "/lists/bad_list/items", {description: 'some description', completed: false }, @headers
      expect(response.status).to eq 422
    end
  end

  describe 'PUT /lists/:name/items/:item_id' do
    it 'updates the specified item' do
      put "/lists/#{list.name}/items/#{item.id}", {completed: true}, @headers
      item.reload
      expect(item.completed).to eq true
    end

    it 'returns a json representation of the item' do
      put "/lists/#{list.name}/items/#{item.id}", {completed: true}, @headers
      expect(response.body).to eq item.reload.to_json
    end

    it "returns a 422 if the list could not be found" do
      put "/lists/bad_list/items/#{item.id}", {completed: true}, @headers
      expect(response.status).to eq 422
    end

    it "returns a 422 if the item could not be found" do
      put "/lists/#{list.name}/items/0", {completed: true}, @headers
      expect(response.status).to eq 422
    end
  end

  describe 'DELETE /lists/:name/items/:item_id' do
    it 'updates the specified item' do
      expect {
        delete "/lists/#{list.name}/items/#{item.id}", {}, @headers
        }.to change{Item.count}.by 0
    end

    it "returns a 422 if the list could not be found" do
      delete "/lists/bad_list/items/#{item.id}", {}, @headers
      expect(response.status).to eq 422
    end

    it "returns a 422 if the item could not be found" do
      delete "/lists/#{list.name}/items/0", {}, @headers
      expect(response.status).to eq 422
    end
  end

end