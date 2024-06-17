package sue

import (
	"strings"
	"tool/cli"
	"tool/exec"
	"tool/file"
)

// Decrypt secret value from sops encrypted file
#Command: {
	#var: {
		enc: filename: *"sops.enc.yaml" | _
		package: *"sops" | _
		path: *["sops", "dec"] | _
		expression: *strings.Join(path, ".") | _
	}
	#local: {
		dec: {
			filename: strings.Replace(#var.enc.filename, ".enc.", ".dec.", 1)
			imported: strings.Join([filename, "cue"], ".")
		}
		path: strings.Join([for p in #var.path {#"--path "\#(p)""#}], " ")
	}
	"sue-encrypt": {
		encrypt: exec.Run & {
			cmd:    "sops --encrypt \(#local.dec.filename)"
			stdout: string
		}
		output: file.Create & {
			filename: #var.enc.filename
			contents: encrypt.stdout
		}
		print: cli.Print & {
			$after: output
			text:   "Encrypted \(#local.dec.filename) to \(#var.enc.filename)"
		}
	}
	sue: {
		decrypt: exec.Run & {
			cmd:    "sops --decrypt \(#var.enc.filename)"
			stdout: string
		}
		output: file.Create & {
			filename: #local.dec.filename
			contents: decrypt.stdout
		}
		import: exec.Run & {
			$after: output
			cmd:    "cue import \(output.filename) \(#local.path) --package \(#var.package) --force --outfile \(#local.dec.imported)"
		}
		export: exec.Run & {
			$after: import
			cmd:    "cue export --package \(#var.package) --expression \(#var.expression)"
		}
		remove: file.RemoveAll & {
			$after: import
			path:   output.filename
		}
	}
}
