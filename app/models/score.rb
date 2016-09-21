
class Score < ApplicationRecord

  def self.get_average(category)
    case category
      when :crime
        avg = VotingDistrict.median(:crime)/VotingDistrict.average_area

      when :accidents
        avg = VotingDistrict.median(:accidents)/VotingDistrict.average_area

      when :parks
        # avg = VotingDistrict.median(:parks)/VotingDistrict.average_area
        avg = VotingDistrict.all.compact.sum{ |vd| vd.parks}/VotingDistrict.all.length

      when :subways
        avg = VotingDistrict.all.compact.sum{ |vd| vd.subways}/VotingDistrict.all.length
      when :bikes
        avg = VotingDistrict.all.compact.sum{ |vd| vd.bikes}/VotingDistrict.all.length
      when :restaurants
        avg = VotingDistrict.all.compact.sum{ |vd| vd.restaurants}/VotingDistrict.all.length
      else
        return "blah blah blah"
    end
  end

  def self.averages
    {accidents: get_average(:accidents), bikes: get_average(:bikes),
     crime: get_average(:crime), parks: get_average(:parks), restaurants: get_average(:restaurants), subways: get_average(:subways)}
  end

  def self.score(category, district)
    averages = {
      :accidents=>160.55194245292316,
      :bikes=>5,
      :crime=>321.1038849058463,
      :parks=>57,
      :restaurants=>53,
      :subways=>4
    }
    district_categories = VotingDistrict.pluck(category).compact
    average = averages[category]
    variance = (district_categories.map { |a| (a - average)**2 }.reduce(:+))/(district_categories.length)
    stdev = variance ** (0.5)
    value = district[category]
    distance = (value/stdev)
    if distance > 5
      distance = 5
    elsif distance < 0
      distance = 0
    end
    if category == :crime || category == :accidents
      if value < average
        50 + distance * 10
      else
        50 - distance * 10
      end
    else
      if value < average
        50 - distance * 10
      else
        50 + distance * 10
      end
    end
  end

  def self.own_scores(district)
      scores = {
        accidents: score(:accidents, district),
        crime: score(:crime, district),
        bikes: score(:bikes, district),
        parks: score(:parks, district),
        restaurants: score(:restaurants, district),
        subways: score(:subways, district)
      }
  end

end
