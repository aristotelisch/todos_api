module Lists
  class API < Grape::API
    format :json

    resource :lists do
      http_basic do |user, password|
        (user == 'beta' && password == 'beta')
      end

      helpers do
        def fetch_list
          @list = List.find_by name: params[:name]
          error!({errors: ["Could not find List with name #{params[:name]}"]}, 422) unless @list
        end

        def fetch_item
          @item = Item.find params[:item_id]
        rescue ActiveRecord::RecordNotFound
          error!({errors: ["Could not find Item with name #{params[:item]}"]}, 422)
        end
      end

      #
      #  Get all available lists
      #
      get do
        @list = List.includes(:items)
      end

      params { requires :name, type: String, desc: "Your list's name." }
      post do
        list = List.create name: params[:name]
        error!({errors: list.errors.full_messages}, 422) unless list.valid?
        list
      end

      segment '/:name' do
        get do
          fetch_list
          @list
        end
        resources :items do
          params do
            requires :description, type: String, desc: "Your item's description."
            requires :completed, type: Boolean, desc: "Your item's completeness value."
          end

          post do
            fetch_list
            @list.items.create({
              description: params[:description],
              completed: params[:completed]
            })
          end

          put ':item_id' do

            params do
              optional :description, type: String, desc: "Your item's description."
              optional :completed, type: Boolean, desc: "Your item's completeness value."
            end

            fetch_list
            fetch_item
            new_attributes = {}
            new_attributes[:description] = params[:description] if params[:description]
            new_attributes[:completed]   = params[:completed]   if params[:completed]
            @item.update_attributes new_attributes
            @item.reload
          end

          delete '/:item_id' do
            fetch_list
            fetch_item
            @item.destroy
          end
        end
      end
    end
  end
end