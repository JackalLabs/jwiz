package model

import (
	"github.com/JackalLabs/jwiz/jwiz/pages"

	"github.com/charmbracelet/bubbles/spinner"
)

type Stack struct {
	pages []pages.Page
}

type Model struct {
	pages   Stack
	spinner spinner.Model
}

type Constructor func(model *Model) pages.Page
