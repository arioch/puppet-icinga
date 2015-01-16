### File managed with puppet ###
### Served by:        '<%= scope.lookupvar('::servername') %>'
### Module:           '<%= scope.to_hash['module_name'] %>'
### Template source:  '<%= template_source %>'

command[check_haproxy]=<%= @plugindir %>/check_haproxy.rb -u localhost -U <%= @username %> -P <%= @password %>
