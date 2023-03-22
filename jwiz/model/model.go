package model

import (
	"fmt"
	"jackalCLI/jwiz/pages"

	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
)

func (m *Model) Init() tea.Cmd {
	return tea.Batch(m.spinner.Tick, tea.EnterAltScreen)
}

func (m *Model) SetCurrentPage(page pages.Page) {
	m.pages.Push(page)
}

func (m *Model) GetCurrentPage() pages.Page {
	return m.pages.Peek()
}

func (m *Model) GoBack() {
	if m.pages.Size() > 1 {
		m.pages.Pop()
	}
}

func InitialModel() *Model {

	s := spinner.New()
	s.Spinner = spinner.MiniDot

	return &Model{
		pages:   NewStack(),
		spinner: s,
	}
}

func (m *Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {

	// Is it a key press?
	case tea.KeyMsg:

		// Cool, what was the actual key pressed?
		switch msg.String() {
		// These keys should exit the program.
		case "ctrl+c", "q":
			return m, tea.Quit
		case "backspace", "b":
			m.GoBack()
			return m, nil
		}

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd

	}

	p := m.GetCurrentPage()
	if p == nil {
		return m, nil
	}

	p.Update(msg)

	return m, nil
}

func (m *Model) View() string {
	s := ""
	p := m.GetCurrentPage()
	if p == nil {
		s += fmt.Sprintf("%s %s", m.spinner.View(), "Loading...")
	} else {
		s += p.View()
	}

	// The footer
	s += "\n\nPress q to quit. Press backspace/b to go back.\n"
	return s
}
