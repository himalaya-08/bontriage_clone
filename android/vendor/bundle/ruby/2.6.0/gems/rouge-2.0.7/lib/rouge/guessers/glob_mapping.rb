module Rouge
  module Guessers
    # This class allows for custom behavior
    # with glob -> lexer name mappings
    class GlobMapping < Guesser
      def self.by_pairs(mapping, filename)
        glob_map = {}
        mapping.each do |(glob, lexer_name)|
          lexer = Lexer.find(lexer_name)

          # ignore unknown lexers
          next unless lexer

          glob_map[lexer.name] ||= []
          glob_map[lexer.name] << glob
        end

        new(glob_map, filename)
      end

      attr_reader :glob_map, :filename
      def initialize(glob_map, filename)
        @glob_map = glob_map
        @filename = filename
      end

      def filter(lexers)
        basename = File.basename(filename)

        collect_best(lexers) do |lexer|
          score = (@glob_map[lexer.name] || []).map do |pattern|
            if test_pattern(pattern, basename)
              # specificity is better the fewer wildcards there are
              -pattern.scan(/[*?\[]/).size
            end
          end.compact.min
        end
      end

      private
      def test_pattern(pattern, path)
        File.fnmatch?(pattern, path, File::FNM_DOTMATCH | File::FNM_CASEFOLD)
      end
    end
  end
end
