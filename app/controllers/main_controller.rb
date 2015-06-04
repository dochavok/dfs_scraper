class MainController < ApplicationController

  # GET /main
  # GET /main.json
  def index
  end
  
  def spreadsheet
    @site = params[:site]
    @date = params[:date]
    @sport = params[:sport]
    @prices = Price.where(site: @site, date: @date, sport: @sport).includes(:projection)
    @max_salary = Price.where(site: @site, sport: @sport).maximum(:salary).to_f
    @max_fpts = Projection.where(site: @site, sport: @sport.downcase).maximum(:fpts)
    
    respond_to do |format|

        format.html { render :spreadsheet }
        format.xlsx { 
           workbook = RubyXL::Workbook.new 
           worksheet = workbook['Sheet1'] 
           worksheet.sheet_name = 'Prices' 
          
           worksheet.add_cell(0, 0, 'Pos')  
           worksheet.add_cell(0, 1, 'Team')  
           worksheet.add_cell(0, 2, 'Site ID')  
           worksheet.add_cell(0, 3, 'Player')  
           worksheet.add_cell(0, 4, 'Salary')  
           worksheet.add_cell(0, 5, 'FPTS')  
           worksheet.add_cell(0, 6, 'Ratio')  
           worksheet.add_cell(0, 7, 'Score')  
           worksheet.add_cell(0, 8, 'Line')  
           worksheet.add_cell(0, 9, 'O/U')  
            
           row = 1 
             @prices.each do |price| 
               next if price.projection.nil? 
               worksheet.add_cell(row, 0, price.position)  
               worksheet.add_cell(row, 1, price.team)  
               worksheet.add_cell(row, 2, price.site_id)  
               worksheet.add_cell(row, 3, price.player)  
               worksheet.add_cell(row, 4, price.salary)  
               worksheet.add_cell(row, 5, price.projection.fpts)  
               worksheet.add_cell(row, 6, '', "((F#{row+1} * 1000) / E#{row+1})")  
               worksheet.add_cell(row, 7, ((((@max_salary*2 - price.salary) / @max_salary) ** 2 + (((@max_fpts*-1) - price.projection.fpts) / @max_fpts) ** 2) ** 0.5).round(2))  
               worksheet.add_cell(row, 8, (price.line.nil?) ? "" : price.line.team1_line)  
               worksheet.add_cell(row, 9, (price.line.nil?) ? "" : price.line.over_under)  
               row = row + 1 
             end 
            
           workbook.write("C:\\Users\\Craig\\Desktop\\test.xlsx") 
          
           send_data(workbook.stream.read)
          
          }
      
    end
    
  end
  
end