class Shortcode::Tag

  def initialize(name, opts=[])
    @name = name.downcase
    set_options opts
  end

  def set_options(opts)
    hash = {}
    opts.each { |o| hash[o[:key].to_sym] = o[:value] }
    @options = hash
  end

  def markup
    template_files.each do |path|
      return File.read(path) if File.file? path
    end
    raise Shortcode::TemplateNotFound, "Searched in:", template_files
  end

  def wrap(text='')
    @text = text
    render_template
  end

  private

    def render_template
      case Shortcode.template_parser
      when :haml
        Haml::Engine.new(markup, ugly: true).render(binding)
      when :erb
        ERB.new(markup).result(binding)
      else
        raise Shortcode::TemplateParserNotSupported, Shortcode.template_parser
      end
    end

    def template_files
      template_paths.map do |filename|
        File.join Shortcode.template_path, filename
      end
    end

    def template_paths
      [ "#{@name}.html.#{Shortcode.template_parser.to_s}", "#{@name}.#{Shortcode.template_parser.to_s}" ]
    end
end
