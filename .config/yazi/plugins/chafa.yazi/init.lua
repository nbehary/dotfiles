local M = {}

function M:peek(job)
	local child = Command("chafa")
		:args({
			"--format", "symbols",
			"--size", job.area.w .. "x" .. job.area.h,
			tostring(job.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return
	end

	local output = child:wait_output()
	if output then
		ya.preview_widgets(job, { ui.Text(output.stdout):area(job.area) })
	end
end

function M:seek(job)
end

return M
