package main

import (
	"fmt"
	"os"

	"github.com/JackalLabs/jwiz/jwiz/model"
	"github.com/JackalLabs/jwiz/jwiz/pages/intro_page"

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
