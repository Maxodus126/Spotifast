package cmd

import (
	"strings"
	"testing"
)

// psQuote must wrap its input as a single literal PowerShell token even when the
// input contains quote/statement characters, so config-provided launch flags
// cannot break out to run arbitrary commands. Inside a single-quoted PowerShell
// string only a single quote can terminate the token, so every internal single
// quote must be doubled.
func TestPSQuoteNeutralizesInjection(t *testing.T) {
	// recover inverts psQuote: strip the wrapping quotes and un-double.
	recover := func(q string) string {
		q = strings.TrimPrefix(q, "'")
		q = strings.TrimSuffix(q, "'")
		return strings.ReplaceAll(q, "''", "'")
	}

	attacks := []string{
		`--flag "; Start-Process calc; "`,
		`--flag '; Start-Process calc; '`,
		`--flag "$x"`,
		`--flag '` + "`" + `'`,
	}
	for _, attack := range attacks {
		q := psQuote(attack)
		if !strings.HasPrefix(q, "'") || !strings.HasSuffix(q, "'") {
			t.Fatalf("psQuote not single-quoted: %q", q)
		}
		if got := recover(q); got != attack {
			t.Fatalf("round-trip failed: got %q want %q (q=%q)", got, attack, q)
		}
	}

	// Plain flags survive intact.
	if got := psQuote("--remote-debugging-port=9222"); got != "'--remote-debugging-port=9222'" {
		t.Fatalf("plain flag mangled: %q", got)
	}
}
