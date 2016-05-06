<%=
  @module_statements = module_name_parts.reverse.reduce(['# Your code here']) do |a, e|
    # indent accumulator
    a = a.map { |l| '  ' + l }

    # wrap in module clause
    ["module #{e}", *a, "end # module #{e}"]
  end
  @module_statements.join("\n")
%>

require_relative '<%= file_basename %>/application'
require_relative '<%= file_basename %>/version'
