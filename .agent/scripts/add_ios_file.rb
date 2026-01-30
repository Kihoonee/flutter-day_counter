require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the widget target
widget_target = project.targets.find { |t| t.name == 'DaysPlusWidgetExtension' }

if widget_target
  # Find or create the group
  group = project.main_group.find_subpath('DaysPlusWidget', true)
  
  # File path
  file_path = 'DaysPlusWidget/SelectEventIntent.swift'
  
  # Add file to group if not already there
  unless group.files.find { |f| f.path == 'SelectEventIntent.swift' }
    file_ref = group.new_file('SelectEventIntent.swift')
    widget_target.add_file_references([file_ref])
    project.save
    puts "Successfully added SelectEventIntent.swift to DaysPlusWidget target."
  else
    puts "SelectEventIntent.swift already exists in project."
  end
else
  puts "Error: Could not find DaysPlusWidget target."
end
