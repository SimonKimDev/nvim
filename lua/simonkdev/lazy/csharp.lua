-- C#: roslyn.nvim runs Roslyn, the language server VS Code's C# extension uses, from Mason (lsp/mason.lua).
-- It picks the solution (.sln/.slnx) above the file; `:Roslyn target` switches between solutions.
-- Server settings live in lsp/lspconfig.lua; debugging is in simonkdev/dotnet.lua.
return {
	"seblyng/roslyn.nvim",
	lazy = false, -- only registers the "roslyn" LSP config; the server starts on the first C# buffer
	opts = {},
}
