package repository

import (
	"aq3stat/internal/model"
	"aq3stat/pkg/database"
	"gorm.io/gorm"
)

// SearchEngineRepository handles database operations for search engines
type SearchEngineRepository struct {
	db *gorm.DB
}

// NewSearchEngineRepository creates a new search engine repository
func NewSearchEngineRepository() *SearchEngineRepository {
	return &SearchEngineRepository{
		db: database.DB,
	}
}

// Create creates a new search engine
func (r *SearchEngineRepository) Create(se *model.SearchEngine) error {
	return r.db.Create(se).Error
}

// FindByID finds a search engine by ID
func (r *SearchEngineRepository) FindByID(id int) (*model.SearchEngine, error) {
	var se model.SearchEngine
	err := r.db.First(&se, id).Error
	if err != nil {
		return nil, err
	}
	return &se, nil
}

// Update updates a search engine
func (r *SearchEngineRepository) Update(se *model.SearchEngine) error {
	return r.db.Save(se).Error
}

// Delete deletes a search engine
func (r *SearchEngineRepository) Delete(id int) error {
	return r.db.Delete(&model.SearchEngine{}, id).Error
}

// List returns a list of all search engines
func (r *SearchEngineRepository) List() ([]model.SearchEngine, error) {
	var searchEngines []model.SearchEngine
	err := r.db.Order("display_order ASC").Find(&searchEngines).Error
	if err != nil {
		return nil, err
	}
	return searchEngines, nil
}
