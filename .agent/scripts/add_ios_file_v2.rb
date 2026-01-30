require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'DaysPlusWidgetExtension' }

if target
  # Just add to the project and target without complex group logic
  file_ref = project.new_file('DaysPlusWidget/SelectEventIntent.swift')
  target.add_file_references([file_ref])
  project.save
  puts "Added SelectEventIntent.swift to DaysPlusWidgetExtension"
else
  puts "Target DaysPlusWidgetExtension not found"
end
