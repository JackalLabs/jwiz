package rpc_install

import (
	"log"
	"sort"

	"github.com/JackalLabs/jwiz/jwiz/model"
	"github.com/JackalLabs/jwiz/jwiz/pages"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/go-git/go-git/v5"

	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/storage/memory"
)

func New(parent *model.Model) pages.Page {
	m := RPCInstallPage{
		parentModel: parent,
	}

	m.Init()

	return &m
}

func (p *RPCInstallPage) View() string {

	return p.list.View()

}

func (p *RPCInstallPage) Update(msg tea.Msg) tea.Cmd {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		p.list.SetWidth(msg.Width)
		return nil

	case tea.KeyMsg:
		switch {
		case msg.String() == "enter":
			i, ok := p.list.SelectedItem().(item)
			if ok {
				p.choice = string(i)
			}

		default:
			var cmd tea.Cmd
			p.list, cmd = p.list.Update(msg)

			return cmd
		}
	}

	return nil
}

func (p *RPCInstallPage) Init() {
	// Create the remote with repository URL
	rem := git.NewRemote(memory.NewStorage(), &config.RemoteConfig{
		Name: "origin",
		URLs: []string{"https://github.com/JackalLabs/canine-chain"},
	})

	// We can then use every Remote functions to retrieve wanted information
	refs, err := rem.List(&git.ListOptions{})
	if err != nil {
		log.Fatal(err)
	}

	// Filters the references list and only keeps tags
	var tags []string
	for _, ref := range refs {
		if ref.Name().IsTag() {
			tags = append(tags, ref.Name().Short())
		}
	}

	if len(tags) == 0 {
		return
	}

	p.versions = make([]list.Item, len(tags))

	sort.Strings(tags)

	for i, tag := range tags {
		p.versions[len(tags)-i-1] = item(tag)
	}

	const defaultWidth = 30

	l := list.New(p.versions, itemDelegate{}, defaultWidth, listHeight)
	l.Title = "Which RPC node version?"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)
	l.Styles.Title = titleStyle
	l.Styles.PaginationStyle = paginationStyle
	l.Styles.HelpStyle = helpStyle
	l.SetShowHelp(false)

	p.list = l

}
