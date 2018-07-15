package styled

import (
	"strings"
)

// FindTransformer looks up a transformer name and if successful returns a
// function that can be used to transform a styled Segment.
func FindTransformer(transformerName string) func(*Segment) {
	switch {
	// Catch special colors early
	case transformerName == "default":
		return func(s *Segment) { s.Foreground = "" }
	case transformerName == "bg-default":
		return func(s *Segment) { s.Background = "" }
	case strings.HasPrefix(transformerName, "bg-"):
		return buildColorTransformer(strings.TrimPrefix(transformerName, "bg-"), false)
	case strings.HasPrefix(transformerName, "no-"):
		return buildBoolTransformer(strings.TrimPrefix(transformerName, "no-"), false, false)
	case strings.HasPrefix(transformerName, "toggle-"):
		return buildBoolTransformer(strings.TrimPrefix(transformerName, "toggle-"), false, true)

	default:
		if f := buildColorTransformer(transformerName, true); f != nil {
			return f
		}
		return buildBoolTransformer(transformerName, true, false)
	}
}

func buildColorTransformer(transformerName string, setForeground bool) func(*Segment) {
	if isValidColorName(transformerName) {
		if setForeground {
			return func(s *Segment) { s.Foreground = transformerName }
		} else {
			return func(s *Segment) { s.Background = transformerName }
		}
	}

	return nil
}

func buildBoolTransformer(transformerName string, val, toggle bool) func(*Segment) {
	switch transformerName {
	case "bold":
		if toggle {
			return func(s *Segment) { s.Bold = !s.Bold }
		}
		return func(s *Segment) { s.Bold = val }
	case "dim":
		if toggle {
			return func(s *Segment) { s.Dim = !s.Dim }
		}
		return func(s *Segment) { s.Dim = val }
	case "italic":
		if toggle {
			return func(s *Segment) { s.Italic = !s.Italic }
		}
		return func(s *Segment) { s.Italic = val }
	case "underlined":
		if toggle {
			return func(s *Segment) { s.Underlined = !s.Underlined }
		}
		return func(s *Segment) { s.Underlined = val }
	case "blink":
		if toggle {
			return func(s *Segment) { s.Blink = !s.Blink }
		}
		return func(s *Segment) { s.Blink = val }
	case "inverse":
		if toggle {
			return func(s *Segment) { s.Inverse = !s.Inverse }
		}
		return func(s *Segment) { s.Inverse = val }
	}

	return nil
}
