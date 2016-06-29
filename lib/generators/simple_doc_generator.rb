require 'rake'

class SimpleDocGenerator < Rails::Generators::Base

  def read_data
    routes = get_route_info
    src_locations = get_src_locations(routes)

    result = extract_doc_data(routes, src_locations)
    pretty_write(result[0], result[1], "docs/simple_docs.markdown")
    puts "[SimpleDoc] Success. #{result[0].count} routes now documented in 'docs/simple_docs.markdown'"
  end

  private

    def extract_doc_data(routes, src_locations)
      meta = {}
      meta[:undefined_actions] = []
      meta[:undefined_controllers] = []

      res = routes.map { |route|
        res = src_locations.find { |entry| entry[:controller] == route[:controller] }

        if res.nil?
          meta[:undefined_controllers] << "#{route[:controller]}"
          next
        end

        data = res[:actions].find { |row| row[:action] == route[:action] }

        if data.nil?
          meta[:undefined_actions] << "#{route[:controller]} => #{route[:action]}"
          next
        end

        contents = File.read(data[:file_path])
        parse(route, contents, data[:action])
        route
      }.select(&:present?)

      [res, meta]
    end

    def pretty_write(result, meta, output_path)
      data = "## #{Rails.application.class.parent_name} \n\n"

      data << result.map { |entry|
        out = "### #{entry[:verb].strip} #{entry[:endpoint].strip} \n"
        out << "#### Related Source Code\n" 
        if entry[:responses].count > 0
          out << "`#{entry[:responses].map { |l| l.strip }.join("`\n`")}`"
        else
          out << "No relevant source code"
        end
      }.join("\n\n\n")

      data << "\n\n"

      meta_data = "#### The following actions had routes defined but no implementation. \n"
      meta_data << "#{meta[:undefined_actions].map {|l| l.strip}.join("\n")}"
      
      data << meta_data

      File.open(File.join(Rails.root, output_path), "w") do |f|
          f.puts data
      end
    end

    def parse(route, contents, method)
      method_body = extract_method(contents, method)
      route[:responses] = get_responses(method_body)
    end

    def get_responses(method_body)
      valid_tokens = ["render", "respond_with"]
      method_body.each_line.select { |line|
        line.strip!
        valid_tokens.any? { |token| line.include? token }
      }
    end

    # Finds the line with the method name, extracts all src up to next method or EOF
    # Clearly, not very robust.
    def extract_method(contents, method)
      startPos = find_method_start(contents, method) 
      endPos = find_method_end(startPos, contents, method)
      contents[startPos..endPos]
    end

    def find_method_start(str, method)
      str.index(/\b?def #{method}\b/)
    end

    def find_method_end(method_sig_start, contents, method)
      method_body_start = contents.index("\n", method_sig_start) + 1
      next_method_start = contents.index(/\b+def\b+/, method_body_start)
      if next_method_start.nil? then contents.length else next_method_start end
    end

    def get_src_locations(routes)
      Rails.application.eager_load!
      ApplicationController.descendants.map { |controller|
        { controller: controller.name, actions: get_action_source_locations(controller.new) }
      }
    end

    # @return [{ action: <action>, location: [<path>, <line_no>]}]
    def get_action_source_locations(controller)
      # Remove inherited actions
      action_methods = controller.action_methods - ApplicationController.action_methods
      action_methods.map { |name| 
        { action: name, 
          file_path: controller.method(name).source_location[0],
          line_no: controller.method(name).source_location[1] }
      }
    end

    def get_route_info
      res = []

      out = `rake routes`
      out = out[out.index("\n") + 1, out.length] #skip first line
      out.each_line do |route|
        res << api_doc_for_route(route)
      end

      res
    end

    def api_doc_for_route(route)
      { verb: find_verb(route),
        endpoint: find_endpoint(route),
        controller: find_controller(route),
        action: find_controller_action(route) }
    end

    def find_controller_action(line)
      line.match(/#(\S+\b)/)[1]
    end

    def find_controller(line)
      name = line.match(/\/?(\w+)#/)[1]
      "#{name.capitalize}Controller"
    end

    def find_endpoint(line)
      line[/\/\S*/]
    end

    def find_verb(line)
      line[/\b(GET|POST|PATCH|DELETE|PUT)\b/]
    end


    def create_doc_file
      create_file "docs/simple_doc.markdown"
    end
end
