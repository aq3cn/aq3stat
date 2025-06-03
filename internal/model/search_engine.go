package model

import (
	"time"

	"gorm.io/gorm"
)

// SearchEngine represents a search engine configuration
type SearchEngine struct {
	ID           int            `gorm:"primaryKey;type:int" json:"id"`
	Name         string         `gorm:"size:100;not null" json:"name"`
	Domains      string         `gorm:"size:255;not null" json:"domains"` // Comma-separated list of domains
	QueryParams  string         `gorm:"size:100;not null" json:"query_params"` // Comma-separated list of query parameters
	DisplayOrder int            `gorm:"default:0" json:"display_order"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
