package pages

import (
	tea "github.com/charmbracelet/bubbletea"
)

type Page interface {
	View() string
	Update(msg tea.Msg) tea.Cmd
	Init()
}
