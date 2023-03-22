package main

import (
	"fmt"
	"jackalCLI/jwiz/model"
	"jackalCLI/jwiz/pages/intro_page"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	m := model.InitialModel()

	k := intro_page.New(m)

	m.SetCurrentPage(k)

	p := tea.NewProgram(m, tea.WithAltScreen())

	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
