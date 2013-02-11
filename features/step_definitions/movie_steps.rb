# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  end
  #flunk "Unimplemented"
end


# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body =~ /#{e1}.*#{e2}/m
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(",").each do |rating|
    rating = rating.gsub!(/"/,'')
    if uncheck == "un"
      step %Q{I uncheck "ratings_#{rating}"}
      step %Q{the "ratings_#{rating}" checkbox should not be checked}
    else
      step %Q{I check "ratings_#{rating}"}
      step %Q{the "ratings_#{rating}" checkbox should be checked}
     end
  end
end


# Check movies table if ratings are included/excluded (DRY)
Then /I should( not)? see the following ratings: (.*)/ do |no_find, rating_list|
  # find all ratings from the displayed movies in the table body and col 2 and map to ratings
  titles = page.all("table#movies tbody tr td[1]").map! {|t| t.text}
  ratings = page.all("table#movies tbody tr td[2]").map! {|t| t.text}
  # assue that the ratings are not included within the ratings_list
  is_in = false
  rating_list.split(",").each do |rating|
    rating = rating.gsub!(/"/,'')
    ratings.each do |r|
      if r != nil
        if r == rating
          is_in = true
        end
      end
    end
  end
  if no_find == " not"
    assert !is_in
  else
    assert is_in
  end
end

# Check/uncheck all ratings (DRY)
When /I (de)?select all ratings/ do |deselect|
  # generate a string that contains all ratings
  # this could possibly be done using string.join but 
  # I do it explicitly within a loop
  all_ratings = ""
  Movie.all_ratings.each do |r|
    if all_ratings.length > 0
      all_ratings = all_ratings + ","
    end
    all_ratings = all_ratings+ "\"" + r + "\"" 
  end
  if deselect == "de"
    printf "Deselecting all ratings checkboxes\n"
    step %Q{When I uncheck the following ratings: #{all_ratings}}
  else
    #printf "Selecting all ratings checkboxes\n"
    step %Q{When I check the following ratings: #{all_ratings}}
  end
end

# check fr all/no movies within one step (DRY)
Then /I should see (no|all)? movies/ do |no_all|
  count = 0
  
  if no_all == "no"
    count = 0
  end
  if no_all == "all"
    count = Movie.all.count
  end
  # add 1 for table header
  count = count + 1
  row_count = page.all('table#movies tr').count
  page.all('table#movies tr').count.should == count
end


Then /the director of "([^"]*)" should be "([^"]*)"$/ do |movie, director|
  assert page.body =~ /#{movie}.*Director.*#{director}/m
end

