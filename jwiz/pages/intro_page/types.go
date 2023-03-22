package intro_page

import (
	"jackalCLI/jwiz/model"

	"github.com/erikgeiser/promptkit/selection"
)

type IntroPage struct {
	parentModel *model.Model

	selection *selection.Model[string]
	choices   map[string]model.Constructor
}
