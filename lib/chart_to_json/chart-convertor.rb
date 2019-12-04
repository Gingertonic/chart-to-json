class ChartToJson::ChartConvertor
    attr_accessor :original

    def initialize(args)
        @original = File.open(args[0])
        @output = {
            data: {title: args[1], writers: args[2]},
            structure: [],
            sections: {}
        }
        @current_section =  nil
    end

    def convert 
        @original.each do |line|
            if line.include?("verse") || line.include?("chorus") || line.include?("intro")
                @current_section = line.chomp
                @output[:structure] << @current_section
                @output[:sections][@current_section.to_sym] = []
            else
                parseLine(line)
            end
        end 
        write_output_to_file
    end

    def parseLine(line)
        changes = line.split("(")
        obj_line = []
        changes.each_with_index do |change, i|
            if change.split(")").length >= 2
                parts = change.split(")")
                obj_line << {type: "chord", body: parts[0].chomp}
                parts[1]+="-" if parts[1][-1] != " " && i != changes.length - 1
                obj_line << {type: "lyric", body: parts[1].chomp}
            elsif !change.empty?
                change+="-" if change[-1] != " " && i != changes.length - 1
                obj_line << {type: "lyric", body: change.chomp}
            end 
        end
        @output[:sections][@current_section.to_sym] << obj_line
    end 

    def write_output_to_file
        # File.open("output.json", "wb") { |file| file.puts JSON.pretty_generate(@output) }
        File.open("output.json", "wb") { |file| file.puts @output.to_json }
        puts "Your output is available at output.json"
    end 

end

# bugs: parsing duplicate sections (eg choruses)