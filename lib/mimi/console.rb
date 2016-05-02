module Mimi
  module Console
    module Colors
      SEQUENCE = %w(31 32 33 34 35 36 37 31;1 32;1 33;1 34;1 35;1 36;1 37;1)

      # Returns ANSI escaped string.
      #
      def esc_string(esc, text)
        esc + text.to_s + "\e[0m"
      end

      def unesc_string(text)
        text.gsub(/\e[^m]+m/, '')
      end

      # Returns ANSI escaped string for the colored text.
      #
      def esc_color(color_code, text)
        esc_string "\e[#{color_code}m", text
      end

      # Returns ANSI escaped string for the red colored text.
      #
      def esc_red(text)
        esc_color 31, text
      end

      # Returns ANSI escaped string for the green colored text.
      #
      def esc_green(text)
        esc_color 32, text
      end

      # Returns ANSI escaped string for the yellow colored text.
      #
      def esc_yellow(text)
        esc_color 33, text
      end

      # Returns ANSI escaped string for the blue colored text.
      #
      def esc_blue(text)
        esc_color 34, text
      end

      # Returns ANSI escaped string for the bold text.
      #
      def esc_bold(text)
        esc_string "\e[01;37m", text
      end

      # Returns string padded to given number of characters, text can be escaped.
      #
      def esc_pad(text, num, color = nil)
        text = text.to_s
        esc_text = text
        case color
        when :red, :yellow, :green
          esc_text = send :"esc_#{color}", text
        end
        pad = esc_text.size - unesc_string(text).size
        num > 0 ? ("%-#{num + pad}s" % esc_text) : esc_text
      end

      # Returns string with formatted and padded fields
      # Each arg is an Array:
      # [<text>, [padding_num], [color]]
      #
      def esc_format(*args)
        out = []
        args.each do |arg|
          out << esc_pad(arg[0], arg[1] || 0, arg[2])
        end
        out.join(' ')
      end

      # Returns rows, as arrays strings, formatted as a table
      #
      # @param rows [Array<Array<String>>]
      #
      # @return [String]
      #
      def esc_format_table(rows, params = {})
        return nil if rows.empty?
        params = {
          delimiter: '  '
        }.merge(params)
        columns_count = rows.map(&:size).max
        columns = columns_count.times.map do |c|
          rows.map { |r| unesc_string(r[c].to_s).size }.max # width of the column
        end
        rows.map do |row|
          row.map.with_index do |t, i|
            esc_pad(t, columns[i])
          end.join(params[:delimiter])
        end.join("\n")
      end
    end # module Colors
  end # module Console
end # module Mimi
