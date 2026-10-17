-- Rust: rustaceanvim starts and configures rust-analyzer itself, so don't also enable it through mason-lspconfig.
-- It runs the rust-analyzer on PATH (`rustup component add rust-analyzer`), which matches the toolchain, and
-- debugs with Mason's codelldb, which it finds on its own. Clippy is the on-save checker when it's installed.
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- a filetype plugin that already loads lazily
}
