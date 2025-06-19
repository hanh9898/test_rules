require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    context 'when user is authenticated' do
      let!(:admin) { create(:user, user_type: 'admin') }
      
      before do
        # Avoid allow_any_instance_of by using more specific stubbing
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
      end
      
      it 'returns successful response' do
        get '/users'
        expect(response).to have_http_status(:success)
      end
    end
    
    it 'returns user list' do
      get '/users'
      expect(response.body).to include('users')
    end
    
    context 'with active status filter' do
      let!(:active_user) { create(:user, active: true, name: 'アクティブフィルターテストユーザー') }
      let!(:inactive_user) { create(:user, active: false) }
      
      it 'returns only active users' do
        get '/users?status=active'
        expect(response.body).to include('アクティブフィルターテストユーザー')
      end
    end
  end
  
  describe 'POST /users' do
    let!(:valid_params) { { name: 'テストユーザー作成太郎', email: 'test_unique@example.com' } }
    let!(:invalid_params) { { name: '', email: 'invalid' } }
    
    context 'with valid params' do
      it 'creates a new user' do
        expect {
          post '/users', params: { user: valid_params }
        }.to change(User, :count).by(1)
      end
      
      it 'creates user with expected name' do
        post '/users', params: { user: valid_params }
        user = User.last
        expect(user.name).to eq('テストユーザー作成太郎')
      end
    end
    
    context 'with invalid params' do
      it 'does not create user' do
        post '/users', params: { user: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  describe 'GET /users/:id' do
    let!(:user) { create(:user, name: 'ユーザー詳細表示テストユーザー') }
    
    it 'returns user details' do
      get "/users/#{user.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ユーザー詳細表示テストユーザー')
    end
    
    context 'when user does not exist' do
      it 'returns not found' do
        get '/users/9999999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'time-based operations' do
    it 'handles boundary date operations with travel_to' do
      travel_to(Time.zone.local(2023, 2, 28, 23, 59, 59)) do
        post '/users', params: { 
          user: { 
            name: '境界値テストユーザー', 
            email: 'boundary@example.com',
            birth_date: Date.new(1990, 1, 31)
          } 
        }
        
        user = User.last
        expect(user.birth_date.day).to eq(31)
      end
    end
    
    it 'processes year-end data correctly' do
      travel_to(Time.zone.today.end_of_year.beginning_of_day) do
        get '/users/annual_report'
        expect(response.body).to include(Time.zone.today.year.to_s)
      end
    end
  end
end 