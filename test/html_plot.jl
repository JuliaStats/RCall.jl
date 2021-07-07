@test RCall._fix_svg_ids("id=\"glyph") != "id=\"glyph"
@test RCall._fix_svg_ids("href=\"#glyph") != "href=\"#glyph"

@test RCall._DEFAULT_FORMAT == :png

@test_throws ErrorException @html_plot R"plot(1, 2)" :png # : is not needed as the macro is already taking a Symbol
@test_throws ErrorException @html_plot R"plot(1, 2)" pdf # only svg and png are supported

@test @html_plot(R"plot(1, 2)") == @html_plot(R"plot(1, 2)", png) # png is the default format

let png_plot = @html_plot R"plot(1, 2)" png
    @test isa(png_plot, HTML)
    @test startswith(png_plot.content, "<img src='data:image/png;base64,")
    @test endswith(png_plot.content, "/>")
end

let svg_plot = @html_plot R"plot(1, 2)" svg
    @test isa(svg_plot, HTML)
    @test occursin("<svg ", svg_plot.content)
    @test occursin("</svg>", svg_plot.content)
end
