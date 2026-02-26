package internal

type TagColor string

const (
	Red    TagColor = "red"
	Orange TagColor = "orange"
	Yellow TagColor = "yellow"
	Green  TagColor = "green"
	Blue   TagColor = "blue"
	Purple TagColor = "purple"
	White  TagColor = "white"
	Black  TagColor = "black"
)

type FiletypeIcon struct {
	Icon  string   `json:"icon"`
	color TagColor `json:"color"`
}

type PricetagDB struct {
	Tags  map[string]TagColor     `json:"tags"`
	Icons map[string]FiletypeIcon `json:"icons"`
	Paths map[string][]string     `json:"paths"`
}

func NewDB() *PricetagDB {
	return &PricetagDB{
		Tags:  make(map[string]TagColor),
		Icons: make(map[string]FiletypeIcon),
		Paths: make(map[string][]string),
	}
}
