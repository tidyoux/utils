package utils

import (
	"io/ioutil"
	"os"
	"regexp"
)

type CommitHistory struct {
	ids   []string
	infos map[string]string
}

func NewCommitHistory() *CommitHistory {
	return &CommitHistory{
		infos: make(map[string]string),
	}
}

func (c *CommitHistory) Reset() {
	c.ids = nil
	c.infos = make(map[string]string)
}

func (c *CommitHistory) Parse(data string) error {
	c.Reset()

	reg, err := regexp.Compile("commit (\\w+)\n")
	if err != nil {
		return err
	}

	matchIndexes := reg.FindAllStringSubmatchIndex(data, -1)
	var lastIndex int
	var lastID string
	for _, indexes := range matchIndexes {
		if len(lastID) > 0 {
			c.infos[lastID] = data[lastIndex:indexes[0]]
		}
		lastID = data[indexes[2]:indexes[3]]
		c.ids = append(c.ids, lastID)

		lastIndex = indexes[0]
	}
	c.infos[lastID] = data[lastIndex:]
	return nil
}

func (c *CommitHistory) ParseByFile(filepath string) error {
	f, err := os.Open(filepath)
	if err != nil {
		return err
	}

	data, err := ioutil.ReadAll(f)
	if err != nil {
		return err
	}

	return c.Parse(string(data))
}

func (c *CommitHistory) CommitID(i int) string {
	if i < 0 || len(c.ids) <= i {
		return ""
	}
	return c.ids[len(c.ids)-i-1]
}

func (c *CommitHistory) CommitInfoByID(id string) string {
	ret, _ := c.infos[id]
	return ret
}

func (c *CommitHistory) CommitInfoByIndex(i int) string {
	id := c.CommitID(i)
	if len(id) == 0 {
		return ""
	}
	return c.CommitInfoByID(id)
}

func (c *CommitHistory) Exists(id string) bool {
	_, ok := c.infos[id]
	return ok
}

func (c *CommitHistory) Len() int {
	return len(c.ids)
}

func (c *CommitHistory) ForkPoint(other *CommitHistory) int {
	if c.Len() == 0 || other.Len() == 0 {
		return -1
	}

	k := -1
	for i := 0; i < c.Len(); i++ {
		if c.CommitID(i) != other.CommitID(i) {
			break
		}
		k = i
	}
	return k
}
