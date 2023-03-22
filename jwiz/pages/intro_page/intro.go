package intro_page

import (
	"github.com/JackalLabs/jwiz/jwiz/model"
	"github.com/JackalLabs/jwiz/jwiz/pages"
	"github.com/JackalLabs/jwiz/jwiz/pages/rpc_install"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/erikgeiser/promptkit/selection"
)

func New(parent *model.Model) pages.Page {
	m := IntroPage{
		parentModel: parent,
		choices: map[string]model.Constructor{
			"Install RPC Node":         rpc_install.New,
			"Install Query Node":       New,
			"Install Storage Provider": New,
		},
	}

	m.Init()

	return &m
}

func (p *IntroPage) View() string {
	return p.selection.View()
}

func (p *IntroPage) Update(msg tea.Msg) tea.Cmd {
	keyMsg, ok := msg.(tea.KeyMsg)
	if !ok {
		return nil
	}

	switch {
	case keyMsg.String() == "enter":
		c, err := p.selection.Value()
		if err != nil {

			return tea.Quit
		}

		newPage := p.choices[c](p.parentModel)
		p.parentModel.SetCurrentPage(newPage)

	default:
		_, cmd := p.selection.Update(msg)

		return cmd
	}

	return nil
}

func (p *IntroPage) Init() {
	keys := make([]string, len(p.choices))
	i := 0
	for k := range p.choices {
		keys[i] = k
		i++
	}

	sel := selection.New("What would you like to do?", keys)
	sel.Filter = nil

	p.selection = selection.NewModel(sel)
	p.selection.Init()
}
