require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it 'requires title' do
      post = build(:post, title: nil)
      expect(post.valid?).to be false
      expect(post.errors.messages[:title]).to include("can't be blank")
    end
    
    it 'requires content with minimum length' do
      post = build(:post, content: 'short')
      expect(post.valid?).to be false
      expect(post.errors.messages[:content]).to include('is too short (minimum is 10 characters)')
    end
    
    context 'when content is long enough' do
      let!(:post) { build(:post, content: 'This is long enough content for validation') }
      
      it 'is valid' do
        expect(post).to be_valid
      end
    end
    
    it 'belongs to user' do
      post = build(:post, user: nil)
      expect(post.valid?).to be false
    end
  end
  
  describe 'scopes' do
    describe '.published' do
      let!(:published_post1) { create(:post, published: true, title: 'ユニークな公開投稿タイトル１') }
      let!(:published_post2) { create(:post, published: true, title: 'ユニークな公開投稿タイトル２') }
      let!(:unpublished_post1) { create(:post, published: false, title: 'ユニークな非公開投稿タイトル１') }
      let!(:unpublished_post2) { create(:post, published: false, title: 'ユニークな非公開投稿タイトル２') }
      
      it 'returns only published posts' do
        expect(Post.published).to match_array([published_post1, published_post2])
      end
    end
    
    describe '.recent' do
      subject(:recent_posts) { Post.recent }
      
      let!(:post3) { create(:post, created_at: 3.days.ago) }
      let!(:post1) { create(:post, created_at: 1.day.ago) }
      let!(:post2) { create(:post, created_at: 2.days.ago) }
      
      it 'returns posts in reverse chronological order' do
        expect(recent_posts).to eq([post1, post2, post3])
      end
    end
  end
  
  describe 'instance methods' do
    describe '#summary' do
      let!(:post) { create(:post) }
      
      it 'includes content' do
        expect(post.summary).to include('content')
      end
      
      it 'truncates long content' do
        long_post = create(:post, content: 'A' * 200)
        expect(long_post.summary.length).to be <= 103
      end
    end
  end
  
  describe 'time-sensitive operations' do
    it 'handles date operations with travel_to' do
      travel_to(Time.zone.local(2023, 1, 31, 10, 0, 0)) do
        post = create(:post)
        expect(post.created_at.day).to eq(31)
      end
    end
    
    it 'works with relative dates for boundary testing' do
      # Test end of month boundary
      travel_to(Time.zone.today.end_of_month) do
        post = create(:post)
        expect(post.created_at.day).to eq(Time.zone.today.day)
      end
    end
  end
end 