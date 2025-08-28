package tests

import (
	"strohalm-backend/db"
	"testing"
)

var TestDate = db.DateFormat

func FatalErr(t *testing.T, err error, msg ...string) {
	if err != nil {
		t.Fatal(msg, ": ", err)
	}
}
