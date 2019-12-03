class ChartToJson::ChartConvertor
    attr_accessor :original

    def initialize(args)
        @original = args[0]
        @output = {
            data: {title: args[1], writers: args[2]},
            structure: ["fullSong"],
            sections: {
                fullSong: []
            }
        }
    end

    def convert 
        File.open(@original).each do |line|
            parseLine(line)
        end 
        p @output.to_json
    end

    def parseLine(line)
        changes = line.split("(")
        obj_line = []
        changes.each do |change|
            if change.length >= 2
                parts = change.split(")")
                # binding.pry
                obj_line << {type: "chord", body: parts[0]}
                obj_line << {type: "lyric", body: parts[1]}
            elsif !change.empty?
                obj_line << {type: "lyric", body: change}
            end 
        end
        @output[:sections][:fullSong] << obj_line
    end 

end