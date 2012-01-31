class DataSet
    attr_accessor :title, :legend, :data, :columns, :legend_ids, :chart_type

    def initialize title, legend, data, columns, legend_ids=nil
        @title = title
        @legend = legend
        @data = data
        @columns = columns
        @legend_ids = legend_ids
    end

    def chart_type
        @chart_type || "BarChart"
    end
end
