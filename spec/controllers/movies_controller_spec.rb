require 'spec_helper'

describe MoviesController do
  before :each do
	@fake_results = [mock('movie1'), mock('movie2')]
	@fake_movie = mock('mockmovie', :id => 1 , :director => 'thedirector', :title => 'fake_move')
  end
  describe 'add and delete movies' do
    it 'delete movie if user posts delete' do
	Movie.should_receive(:find).with('1').and_return(@fake_movie)
	@fake_movie.should_receive(:destroy)
	post :destroy, { :id => 1 }
    end
    it 'create movie if user posts create' do
	Movie.should_receive(:create!).and_return(@fake_movie)
	post :create, { :movie =>  @fake_movie }
    end
  end
  describe 'find similar movies ' do
    it 'should call the model to search similar movies' do
        Movie.should_receive(:find).with('1').and_return(@fake_movie)
        Movie.should_receive(:find_all_by_director).with('thedirector').
             and_return(@fake_results)
        post :finddirector, { :id => 1 }
    end
    it 'should make the result available rendering the correct template' do
        Movie.stub(:find).and_return(@fake_movie)
        Movie.stub(:find_all_by_director).and_return(@fake_results)
	post :finddirector, { :id => 1 }
	response.should render_template('finddirector')
    end
    it 'should render the movie_path if director is not found' do
	fake_movie_not = mock('movie_not_found', :id => 2, :director => '', :title => 'MovieWithNoDirector')
        Movie.should_receive(:find).with('2').and_return(fake_movie_not)
	post :finddirector, { :id => 2 }
	response.should redirect_to('/movies')
    end
  end
end

