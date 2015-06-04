#
# Schedule the following cron job, based on environment to run the tasks below
# rake environment RAILS_ENV=<env> reports:all
#
# Individual tasks can be run by 
# rake environment RAILS_ENV=<env> reports:<taskname> 
#

namespace :import do
  require 'net/https'
  require "rexml/document"
  desc "Import prices daily from Fanduel"
  task :fanduel => :environment do
    puts "Count: #{Price.all.length}"
    Price.delete_all("date < '#{Date.yesterday.to_time}' and site = 'fanduel'")
    puts "Count: #{Price.all.length}"
    logger = Logger.new("log/" + Rails.env.to_s + ".log")
    [Date.today, Date.tomorrow].each do |getdate|
      puts getdate
      url = URI.parse('https://www.fanduel.com/api/grindersplayerprices?date=' + getdate.to_s(:db))
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url.to_s)
      if url.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
  
      http.start do
        @res = http.request(req) 
  
      end
            
      doc = REXML::Document.new(@res.body)
      doc.elements.each("data/fixturelist") { |element| 
        sport = element.elements["sport"].text.downcase
        game_date = element.elements["game"].elements["start"].text
        salary_cap = element.elements["game"].elements["salarycap"].text
        format = element.elements["game"].elements["format"].text
        element.elements.each("player") { |player|
          price = Price.find_by_site_and_site_id_and_date("fanduel", player.elements["id"].text, game_date) || Price.new
          price.player = player.elements["name"].text
          price.sport = sport
          price.date = game_date
          price.position = player.elements["position"].text
          price.site_id = player.elements["id"].text
          price.site = "fanduel"
          price.team = player.elements["team"].text
          price.salary = player.elements["salary"].text
          price.salary_cap = salary_cap
          price.format = format
          my_projection = Projection.where("site = ? and player = ? and date = ? and sport = ?", price.site, price.player, price.date.to_date.to_time, price.sport).first
          unless my_projection.nil?
            price.projection = my_projection
          end
          price.save
        }
      }
    end
  end
  task :fantasy_aces => :environment do
    # No feed for FantasyAces, scrape from projections
    site = 'fantasy_aces'
    Price.where(site: site).destroy_all
    my_projections = Projection.where(site: site)
    my_projections.each do |projection|
          date = projection.date.to_date
          price = Price.find_by_site_and_player_and_date(site, projection.player, date) || Price.new
          price.player = projection.player
          price.sport = projection.sport
          price.date = date
          price.position = projection.position
          price.site_id = nil
          price.site = site
          price.team = projection.team
          price.salary = projection.cost
          price.salary_cap = "55000"
          price.format = "classic"
          price.projection = projection
          price.save if price.salary > 0
    end
    puts "Aces Count: " + my_projections.count.to_s
  end
  task :draft_kings => :environment do
    
  end
  task :all => [:fanduel, :fantasyaces, :draftkings]
  task :faclear => :environment do
    Price.where(site: "fantasy_aces").destroy_all
  end
end
namespace "import:numberfire" do
  desc "Import numberfire"
  source = "numberfire"
  task :mlb => :environment do
    sport = "mlb"
    puts sport
    Projection.delete_all("date < '#{Date.yesterday.to_time}' and sport = '#{sport}'")
    ["batters", "pitchers"].each do |playertype|
      #https://www.numberfire.com/mlb/fantasy/fantasy-baseball-projections/batters?daily_site=fanduel
      url = URI.parse('https://www.numberfire.com/mlb/fantasy/fantasy-baseball-projections/' + playertype)
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url.to_s)
      if url.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.start do
        @res = http.request(req) 
      end
      string = @res.body.to_s
      matchdata = string.match(/NF_DATA = (.*);/)
      
      projection_data =  matchdata[1]
      hash = JSON.parse projection_data
      players = hash["players"]
      projections = hash["projections"]
      teams = hash["teams"]
      projections.each do |proj_data|
        player_data = players[proj_data["mlb_player_id"]]
        player =  player_data["name"]
        position = player_data["position"]
        
        date = proj_data["date"].to_time
        
        team = teams[proj_data["mlb_team_id"]]["abbrev"]
        if sport == "mlb"
          case team
          when "WSH"
            team = "WAS"
          when "LAD"
            team = "LOS"
          when "KC"
            team = "KAN"
          when "CHW"
            team = "CWS"
          when "SF"
            team = "SFG"
          when "TB"
            team = "TAM"
          when "SD"
            team = "SDP"
          else
          end
        end
        opponent = teams[proj_data["opponent_id"]]["abbrev"]
                if sport == "mlb"
          case opponent
          when "WSH"
            team = "WAS"
          when "LAD"
            team = "LOS"
          when "KC"
            team = "KAN"
          when "CHW"
            team = "CWS"
          when "SF"
            team = "SFG"
          when "TB"
            team = "TAM"
          when "SD"
            team = "SDP"
          else
          end
        end
        site_data = Hash.new
        ["fanduel", "draft_kings", "fantasy_feud", "draftday", "fantasy_aces", "fantasy_score", "draftster"].each do |site|
          projection = Projection.find_by_site_and_source_and_player_and_position_and_date(site, source, player, position, date) || 
                       Projection.new(site: site,
                                      source: source,
                                      player: player,
                                      position: position,
                                      date: date)
          projection.team = team
          projection.opponent = opponent
          projection.sport = sport
          projection.fpts = proj_data["#{site}_fp"]
          projection.cost = proj_data["#{site}_salary"]
          projection.save   
        end
          puts player    
      end
    end
  end
  task :nhl => :environment do
    puts "NHL"

  end
  task :nfl => :environment do
    puts "NFL"
  end
  task :nba => :environment do
    sport = "nba"
    puts sport
    Projection.delete_all("date < '#{Date.yesterday.to_time}' and sport = '#{sport}'")
    ["all"].each do |playertype|
      #https://www.numberfire.com/nba/daily-fantasy-basketball-projections/skaters/?daily_site=fanduel
      url = URI.parse('https://www.numberfire.com/nba/daily-fantasy-basketball-projections/' + playertype)
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url.to_s)
      if url.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.start do
        @res = http.request(req) 
      end
      string = @res.body.to_s
      matchdata = string.match(/NF_DATA = (.*);/)
      
      projection_data =  matchdata[1]
      hash = JSON.parse projection_data
      players = hash["players"]
      projections = hash["projections"]
      puts players.to_s
      exit
      teams = hash["teams"]
      projections.each do |proj_data|
        player_data = players[proj_data["nba_player_id"]]
        player =  player_data["name"]
        position = player_data["position"]
        
        date = proj_data["date"].to_time
        
        team = teams[proj_data["nba_team_id"]]["abbrev"]
        opponent = teams[proj_data["opponent_id"]]["abbrev"]
        site_data = Hash.new
        ["fanduel", "draft_kings", "fantasy_feud", "draftday", "fantasy_aces", "fantasy_score", "draftster"].each do |site|
          projection = Projection.find_by_site_and_source_and_player_and_position_and_date(site, source, player, position, date) || 
                       Projection.new(site: site,
                                      source: source,
                                      player: player,
                                      position: position,
                                      date: date)
          projection.team = team
          projection.opponent = opponent
          projection.sport = sport
          projection.fpts = proj_data["#{site}_fp"]
          projection.cost = proj_data["#{site}_salary"]
          projection.save   
        end
          puts player    
      end
    end
  end
  task :all => [:mlb, :nfl, :nba, :nhl]
end

namespace :lines do

  desc "Load daily lines"
  task :all => :environment do
    ["mlb","nba","nhl","nfl","ncf"].each do |sport|
      Line.delete_all("date < '#{Date.yesterday.to_time}' and sport = '#{sport}'")
      logger = Logger.new("log/" + Rails.env.to_s + ".log")
      
      xml_content = Net::HTTP.get(URI.parse("http://sportsfeeds.bovada.lv/basic/#{sport.upcase}.xml"))
  
      doc = REXML::Document.new(xml_content)
      doc.elements.each("Schedule/EventType") { |eventset| 
        sport = eventset.attributes["ID"].downcase
        puts "Loading: #{sport}"
        eventset.elements.each("Date") { |daterec|
          game_date = daterec.attributes["DTEXT"]
          game_date = game_date.to_time
          game_date = game_date.change(:year => Date.today.year)
          puts "- #{game_date}"
          daterec.elements.each("Event"){|eventrec|
            eventrec.elements["Line"].elements.each("Choice") { |choice|
              @over_under = choice.attributes["NUMBER"]
              unless @over_under.nil? 
                @over_under.gsub!(/½/, ".5")
              end
            }
            first_pass = true
            eventrec.elements.each("Competitor") {|competitorrec|
              linetype = competitorrec.elements["Line"].attributes["TYPE"]
              if first_pass == true
                @team1 = nil
                @team2 = nil
                @team1_line = nil
                @team2_line = nil
                @team1 = competitorrec.attributes["CODE1"]
                @team1 = "LAA" if @team1 == "ANA" && sport == "mlb"
  
                if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                  @team1_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"] || nil
                  @team1_line = 100 if @team1_line == "EVEN"
                end
                first_pass = false
                @line1 = Line.find_by_sport_and_team1_and_date(sport, @team1, game_date) || Line.new
                @line1.date = game_date
                @line1.over_under = @over_under
                @line1.sport = sport
                @line1.linetype = linetype
              else
                @team2 = competitorrec.attributes["CODE1"]
                @team2 = "LAA" if @team2 == "ANA" && sport == "mlb"
  
                if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                  @team2_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"]
                  @team2_line = 100 if @team2_line == "EVEN"
                end
                @line2 = Line.find_by_sport_and_team1_and_date(sport, @team2, game_date) || Line.new
                @line2.date = game_date
                @line2.over_under = @over_under
                @line2.sport = sport
                @line2.linetype = linetype
                
                @line1.team1 = @team1
                @line1.team2 = @team2
                @line1.team1_line = @team1_line
                @line1.team2_line = @team2_line
  
                @line2.team2 = @team1
                @line2.team1 = @team2
                @line2.team2_line = @team1_line
                @line2.team1_line = @team2_line
  
              unless (@line1.team1.nil? || @line2.team1.nil?)
                @line1.save
                @line2.save
              end
            end


          }
          if @line1.nil? || @line2.nil?
            puts "Line missing"
          else
            unless (@line1.team1.nil? || @line2.team1.nil?)
              puts "-- #{@line1.team1}/#{@line1.team2} - #{@line1.linetype} - #{@line1.team1_line}"
              puts "-- #{@line2.team1}/#{@line2.team2} - #{@line2.linetype} - #{@line2.team1_line}"
              puts "-----"
            else
              puts "--No teams found, skipping"
              puts "----"
            end  
          end         
          }
        
        }
      }
    end
  end
  task :nba => :environment do
    Line.delete_all("date < '#{Date.yesterday.to_time}' and sport = 'nba'")
    logger = Logger.new("log/" + Rails.env.to_s + ".log")

    # http://sportsfeeds.bovada.lv/basic/NFL.xml
    # http://sportsfeeds.bovada.lv/basic/NCF.xml
    
    xml_content = Net::HTTP.get(URI.parse('http://sportsfeeds.bovada.lv/basic/NBA.xml'))

    doc = REXML::Document.new(xml_content)
    doc.elements.each("Schedule/EventType") { |eventset| 
      sport = eventset.attributes["ID"].downcase
      puts sport
      eventset.elements.each("Date") { |daterec|
        game_date = daterec.attributes["DTEXT"]
        game_date = game_date.to_time
        game_date = game_date.change(:year => Date.today.year)
        puts "- #{game_date}"
        daterec.elements.each("Event"){|eventrec|
          eventrec.elements["Line"].elements.each("Choice") { |choice|
            @over_under = choice.attributes["NUMBER"]
          }
          first_pass = true
          eventrec.elements.each("Competitor") {|competitorrec|
            linetype = competitorrec.elements["Line"].attributes["TYPE"]
            if first_pass == true
              @team1 = nil
              @team2 = nil
              @team1_line = nil
              @team2_line = nil
              @team1 = competitorrec.attributes["CODE1"]

              if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                @team1_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"] || nil
                @team1_line = 100 if @team1_line == "EVEN"
              end
              first_pass = false
              @line1 = Line.find_by_sport_and_team1_and_date(sport, @team1, game_date) || Line.new
              @line1.date = game_date
              @line1.over_under = @over_under
              @line1.sport = sport
              @line1.linetype = linetype
            else
              @team2 = competitorrec.attributes["CODE1"]

              if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                @team2_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"]
                @team2_line = 100 if @team2_line == "EVEN"
              end
              @line2 = Line.find_by_sport_and_team1_and_date(sport, @team2, game_date) || Line.new
              @line2.date = game_date
              @line2.over_under = @over_under
              @line2.sport = sport
              @line2.linetype = linetype
              
              @line1.team1 = @team1
              @line1.team2 = @team2
              @line1.team1_line = @team1_line
              @line1.team2_line = @team2_line

              @line2.team2 = @team1
              @line2.team1 = @team2
              @line2.team2_line = @team1_line
              @line2.team1_line = @team2_line
              
              unless (@line1.team1.nil? || @line2.team1.nil?)
                @line1.save
                @line2.save
              end
            end


          }
          unless (@line1.team1.nil? || @line2.team1.nil?)
            puts "-- #{@line1.team1}/#{@line1.team2} - #{@line1.linetype} - #{@line1.team1_line}"
            puts "-- #{@line2.team1}/#{@line2.team2} - #{@line2.linetype} - #{@line2.team1_line}"
            puts "-----"
          end          
        }
      
      }
    }

  end
  task :nhl => :environment do
    Line.delete_all("date < '#{Date.yesterday.to_time}' and sport = 'nhl'")
    logger = Logger.new("log/" + Rails.env.to_s + ".log")

    # http://sportsfeeds.bovada.lv/basic/NFL.xml
    # http://sportsfeeds.bovada.lv/basic/NCF.xml
    
    xml_content = Net::HTTP.get(URI.parse('http://sportsfeeds.bovada.lv/basic/NHL.xml'))

    doc = REXML::Document.new(xml_content)
    doc.elements.each("Schedule/EventType") { |eventset| 
      sport = eventset.attributes["ID"].downcase
      puts sport
      eventset.elements.each("Date") { |daterec|
        game_date = daterec.attributes["DTEXT"]
        game_date = game_date.to_time
        game_date = game_date.change(:year => Date.today.year)
        puts "- #{game_date}"
        daterec.elements.each("Event"){|eventrec|
          eventrec.elements["Line"].elements.each("Choice") { |choice|
            @over_under = choice.attributes["NUMBER"]
          }
          first_pass = true
          eventrec.elements.each("Competitor") {|competitorrec|
            linetype = competitorrec.elements["Line"].attributes["TYPE"]
            if first_pass == true
              @team1 = nil
              @team2 = nil
              @team1_line = nil
              @team2_line = nil
              @team1 = competitorrec.attributes["CODE1"]

              if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                @team1_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"] || nil
                @team1_line = 100 if @team1_line == "EVEN"
              end
              first_pass = false
              @line1 = Line.find_by_sport_and_team1_and_date(sport, @team1, game_date) || Line.new
              @line1.date = game_date
              @line1.over_under = @over_under
              @line1.sport = sport
              @line1.linetype = linetype
            else
              @team2 = competitorrec.attributes["CODE1"]

              if competitorrec.elements["Line"].attributes["QUALITY"] == "Normal"
                @team2_line = competitorrec.elements["Line"].elements["Choice"].elements["Odds"].attributes["Line"]
                @team2_line = 100 if @team2_line == "EVEN"
              end
              @line2 = Line.find_by_sport_and_team1_and_date(sport, @team2, game_date) || Line.new
              @line2.date = game_date
              @line2.over_under = @over_under
              @line2.sport = sport
              @line2.linetype = linetype
              
              @line1.team1 = @team1
              @line1.team2 = @team2
              @line1.team1_line = @team1_line
              @line1.team2_line = @team2_line

              @line2.team2 = @team1
              @line2.team1 = @team2
              @line2.team2_line = @team1_line
              @line2.team1_line = @team2_line
              
              unless (@line1.team1.nil? || @line2.team1.nil?)
                @line1.save
                @line2.save
              end
            end


          }
          unless (@line1.team1.nil? || @line2.team1.nil?)
            puts "-- #{@line1.team1}/#{@line1.team2} - #{@line1.linetype} - #{@line1.team1_line}"
            puts "-- #{@line2.team1}/#{@line2.team2} - #{@line2.linetype} - #{@line2.team1_line}"
            puts "-----"
          else
            puts "--No teams found, skipping"
            puts "----"
          end          
        }
      
      }
    }

  end
  task :clear => :environment do
    Line.delete_all
  end

end
