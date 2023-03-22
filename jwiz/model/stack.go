package model

import "jackalCLI/jwiz/pages"

func NewStack() Stack {
	return Stack{
		pages: make([]pages.Page, 0),
	}
}

func (s *Stack) Push(page pages.Page) {
	s.pages = append(s.pages, page)
}

func (s *Stack) Size() int {
	return len(s.pages)
}

func (s *Stack) Peek() pages.Page {
	return s.pages[len(s.pages)-1]
}

func (s *Stack) Pop() pages.Page {
	p := s.pages[len(s.pages)-1]
	s.pages = s.pages[:len(s.pages)-1]
	return p
}
