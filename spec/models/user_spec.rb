require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates name presence for regular users' do
      user = build(:user, name: nil, user_type: 'regular')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end
    
    it 'validates email format and presence' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      user.email = nil
      expect(user).not_to be_valid
    end
    
    context 'when user is guest' do
      let!(:user) { build(:user, :guest) }
      
      it 'does not validate name presence' do
        expect(user).to be_valid
      end
    end
    
    it 'validates age numericality on create' do
      user = build(:user, age: -5)
      expect(user).not_to be_valid
    end
  end
  
  describe 'associations' do
    let!(:user) { create(:user) }
    let!(:post1) { create(:post, user: user) }
    let!(:post2) { create(:post, user: user) }
    
    it 'has many posts' do
      expect(user.posts).to include(post1, post2)
    end
  end
  
  describe 'scopes' do
    describe '.active' do
      let!(:active_user1) { create(:user, active: true, name: 'アクティブユーザー１') }
      let!(:active_user2) { create(:user, active: true, name: 'アクティブユーザー２') }
      let!(:inactive_user1) { create(:user, active: false, name: 'インアクティブユーザー１') }
      let!(:inactive_user2) { create(:user, active: false, name: 'インアクティブユーザー２') }
      
      it 'returns only active users' do
        expect(User.active).to contain_exactly(active_user1, active_user2)
      end
    end
    
    describe '.sorted_by_name' do
      subject(:sorted_users) { User.sorted_by_name }
      
      let!(:user_charlie) { create(:user, name: 'Charlie') }
      let!(:user_alice) { create(:user, name: 'Alice') }
      let!(:user_bob) { create(:user, name: 'Bob') }
      
      it 'returns users sorted by name' do
        expect(sorted_users).to eq([user_alice, user_bob, user_charlie])
      end
    end
  end
  
  describe 'instance methods' do
    describe '#full_name' do
      let!(:user) { create(:user, first_name: 'テスト太郎', last_name: '山田') }
      
      it 'returns concatenated first and last name' do
        expect(user.full_name).to eq("テスト太郎 山田")
      end
    end
    
    describe '#calculate_age_next_year' do
      subject(:next_year_age) { user.calculate_age_next_year }
      
      let!(:user) { create(:user, birth_date: Date.new(1990, 3, 10)) }
      
      it 'calculates age for next year' do
        travel_to(Time.zone.local(2023, 6, 15)) do
          expect(next_year_age).to eq(34)
        end
      end
    end
    
    describe '#summary' do
      let!(:user) { create(:user, name: 'テストユーザー名前澤田信幸') }
      
      it 'includes user name in summary' do
        summary = user.to_s
        expect(summary).to include('テストユーザー名前澤田信幸')
      end
    end
  end
end 