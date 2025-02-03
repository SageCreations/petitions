package models

import "core:time/datetime"

Petition :: struct {
    id:             string,
    name:           string,
    description:    string,
    created_at:     datetime.DateTime,
    updated_at:     datetime.DateTime,
}