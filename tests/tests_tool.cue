package tests

import "github.com/abcue/sue"

command: sue.#Command & {
	#var: {
		enc: filename: "tests.enc.yaml"
		package: "tests"
		path: ["tests"]
	}
}
