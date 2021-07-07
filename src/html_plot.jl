using Base64

_open_device(format::Symbol, plot_file; kargs...) = rcall(format, plot_file; kargs...)

_close_device() = rcall(Symbol("dev.off"))

_DEFAULT_FORMAT = :png

function _open_temp_plot(format)
	temp_plot_file = tempname()
	if format == :svg
		_open_device(format, temp_plot_file)
	elseif format == :png
		_open_device(format, temp_plot_file, width=672, height=672, units="px", res=100)
	else
		throw(ErrorException(
				"`$format` is not supported, try with `png` or `svg`"
				))
	end
	temp_plot_file
end

_open_temp_plot() = _open_temp_plot(_DEFAULT_FORMAT)

function _close_and_show_temp_plot(temp_plot_file, format)
	_close_device()
	if isfile(temp_plot_file)
		if format == :png
			plot_base64 = Base64.base64encode(read(temp_plot_file))
			HTML("<img src='data:image/png;base64, $plot_base64'/>")
		elseif format == :svg
			svg_str = read(temp_plot_file, String)
			HTML(_fix_svg_ids(svg_str))
		end
	end
end

function _close_and_show_temp_plot(temp_plot_file)
	_close_and_show_temp_plot(temp_plot_file, _DEFAULT_FORMAT)
end


"""
It executes the R code and returns an `HTML` object containing the plot.
This macro is handy to inline R plots inside Pluto notebooks.

`@html_plot` can take two arguments; the first is the code block to evaluate 
to produce the R plot. The second argument is the plot format (optional); 
it could be `png` (the default) or `svg`. For example:

```julia
@html_plot R"plot(c(1,2,5,3,4), type='o', col='blue')"
```

To use the `svg` format:

```julia
@html_plot R"plot(c(1,2,5,3,4), type='o', col='blue')" svg
```

**NOTE:** To see a *ggplot2* plot, it is necessary to `print` it explicitly:

```julia
@html_plot R\"""
library(ggplot2)

plt <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = "fill"
  )

print(plt)
\"""
```

"""
macro html_plot(r_code, format...)
	quote
		temp_plot_file = _open_temp_plot($format...)
		$r_code
		_close_and_show_temp_plot(temp_plot_file, $format...)
	end
end
