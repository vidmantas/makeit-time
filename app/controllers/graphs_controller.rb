class GraphsController < ApplicationController
  EMPLOYEE_TOP_PROJECTS = 5
  INTENSITY_VERTICAL_THRESHOLD = 10
  
  def project_intensity
    # Data
    return unless assert_permission :projects_view, :id => params[:id]
    project = Project.find(params[:id])
    
    months    = []
    project.start_date.each_month_until(project.end_date) do |month|
      months << month.to_s[0..6]
    end
    
    manager_sector_data = project.graph_data_for_sector(project.manager.sector_id)
    other_sectors_data  = project.graph_data_for_sector_other_than(project.manager.sector_id)
    
    all_sectors_data = []
    manager_sector_data.each_with_index do |m, i|
      all_sectors_data[i] = manager_sector_data[i] +  other_sectors_data[i]
    end
    
    min = (manager_sector_data + other_sectors_data).min.to_i
    max = all_sectors_data.max.to_i
    step = (max - min) / 5
    
    # Graph
    total_line = LineDot.new
    total_line.text = "Visi"
    total_line.tip = "Visi (#x_label#)<br>#val# val."
    total_line.width = 4
    total_line.colour = '#5E4725'
    total_line.dot_size = 5
    total_line.values = all_sectors_data

    manager_line = LineDot.new
    manager_line.text = "Vadovo skyrius"
    manager_line.tip = "Vadovo skyrius (#x_label#)<br>#val# val."
    manager_line.width = 4
    manager_line.colour = '#6363AC'
    manager_line.dot_size = 5
    manager_line.values = manager_sector_data
    
    others_line = LineDot.new
    others_line.text = "Kiti skyriai"
    others_line.tip = "Kiti skyriai (#x_label#)<br>#val# val."
    others_line.width = 4
    others_line.colour = '#DFC329'
    others_line.dot_size = 5
    others_line.values = other_sectors_data
    
    y = YAxis.new
    y.set_range(min, max, step)
    y.colour = '#8393ca'
    y.grid_colour = '#8393ca'
    
    x_labels = XAxisLabels.new
    if months.length > INTENSITY_VERTICAL_THRESHOLD
      x_labels.set_vertical()
    end
    x_labels.labels = months
    
    x = XAxis.new
    x.colour = '#8393ca'
    x.grid_colour = '#8393ca'
    x.set_offset(false)
    x.set_labels(x_labels)
    
    y_legend = YLegend.new("Įdirbis (val.)")
    y_legend.set_style('{font-size: 12px; color: #000;}')

    chart = OpenFlashChart.new
    chart.bg_colour = '#ffffff'
    chart.set_y_legend(y_legend)
    chart.set_y_axis(y)
    chart.set_x_axis(x)

    chart.add_element(total_line)
    chart.add_element(manager_line)
    chart.add_element(others_line)

    render :text => chart.to_s
  end
  
  def project_sectors
    # Data
    return unless assert_permission :projects_view, :id => params[:id]
    project = Project.find(params[:id])
    values = []
    Sector.find(:all).each do |sector|
      if sector.visible
        sector_data = project.graph_data_for_sector(sector.id)
        hours = sector_data.sum
        if hours > 0
          values << PieValue.new(hours, sector.name)
        end
      end
    end

    # Pie
    pie = Pie.new
    pie.animate = false
    pie.tooltip = '#val# val. (#percent#)'
    pie.border = 2
    pie.label_colour = '#8393ca'
    pie.values = values
    
    # Chart
    chart = OpenFlashChart.new
    chart.bg_colour = '#ffffff'
    chart.add_element(pie)
    
    render :text => chart.to_s
  end
  
  def employee_top_projects
    # Data
    return unless assert_permission :employees_view, :id => params[:id]
    employee = Employee.find(params[:id])
    top = Employee.find_by_sql ["SELECT 
        p.name, SUM(t.hours_spent) AS hours
      FROM tasks t
      INNER JOIN projects p ON p.id = t.project_id
      WHERE t.employee_id = ?
      GROUP BY t.project_id
      ORDER BY hours DESC
      LIMIT ?", employee.id, EMPLOYEE_TOP_PROJECTS]
    
    values = []
    total_top = 0
    top.each do |p| 
      values << PieValue.new(p.hours.to_i, p.name)
      total_top += p.hours.to_i
    end
    
    others_total = employee.tasks.sum(:hours_spent).to_i - total_top
    values << PieValue.new(others_total, "Kiti projektai")
    
    # Pie
    pie = Pie.new
    pie.animate = false
    pie.tooltip = '#val# val. (#percent#)'
    pie.border = 2
    pie.label_colour = '#8393ca'
    pie.values = values
    
    # Chart
    chart = OpenFlashChart.new
    chart.bg_colour = '#ffffff'
    chart.add_element(pie)
    
    render :text => chart.to_s
  end
end
